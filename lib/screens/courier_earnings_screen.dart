import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/courier_earnings_week.dart';
import 'package:frip_cash/screens/wallet_screen.dart';
import 'package:frip_cash/services/courier_repository.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/mock_wallet_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/widgets/courier_earnings_chart.dart';
import 'package:material_symbols_icons/symbols.dart';

class CourierEarningsScreen extends StatefulWidget {
  const CourierEarningsScreen({
    super.key,
    this.onOpenHistory,
  });

  final VoidCallback? onOpenHistory;

  @override
  State<CourierEarningsScreen> createState() => _CourierEarningsScreenState();
}

class _CourierEarningsScreenState extends State<CourierEarningsScreen> {
  @override
  void initState() {
    super.initState();
    runAfterFrame(() {
      MockWalletService.instance.syncForUser(MockSession.instance.user);
      CourierRepository.instance.refreshEarnings();
    });
  }

  void _openWallet(BuildContext context) {
    MockWalletService.instance.syncForUser(MockSession.instance.user);
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const WalletScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: const Color(0xFFF5F5F5),
      child: ListenableBuilder(
        listenable: Listenable.merge([
          MockWalletService.instance,
          CourierRepository.instance,
        ]),
        builder: (context, _) {
          final wallet = MockWalletService.instance;
          final repo = CourierRepository.instance;
          final earnings = wallet.courierEarnings ?? repo.earnings;

          final weekTotal = earnings?.weekGnf ?? 0;
          final today = earnings?.todayGnf ?? 0;
          final walletBalance = wallet.availableGnf;

          final weeks = earnings != null && earnings.entries.isNotEmpty
              ? [
                  for (var i = 0; i < earnings.entries.length; i++)
                    CourierEarningsWeek(
                      label: earnings.entries[i].label.isNotEmpty
                          ? earnings.entries[i].label
                          : t.courierWeekCurrent,
                      amountGnf: earnings.entries[i].amountGnf,
                      highlighted: i == 0,
                    ),
                ]
              : repo.weeklyChart(
                  currentWeekLabel: t.courierWeekCurrent,
                  week1Label: t.courierWeekJun29Jul5,
                  week2Label: t.courierWeekJun8Jun14,
                  week3Label: t.courierWeekMay18May24,
                  week4Label: t.courierWeekApr27May3,
                  week5Label: t.courierWeekApr6Apr12,
                );

          return ListView(
            padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 28),
            children: [
              Text(
                t.earnings,
                style: AppTypography.display(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 14),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  color: const Color(0xFF111111),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        AppIcon(
                          Symbols.calendar_month_rounded,
                          size: 16,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          t.courierThisWeek,
                          style: AppTypography.style(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Colors.white.withValues(alpha: 0.55),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${formatPrice(weekTotal)} GNF',
                      style: AppTypography.display(
                        fontSize: 32,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.8,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.courierPaidToWallet,
                      style: AppTypography.style(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.45),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        Expanded(
                          child: _StatPill(
                            icon: Symbols.today_rounded,
                            label: t.courierTodayEarnings,
                            value: '${formatPrice(today)} GNF',
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _StatPill(
                            icon: Symbols.account_balance_wallet_rounded,
                            label: t.availableBalance,
                            value: '${formatPrice(walletBalance)} GNF',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              _ActionCard(
                icon: Symbols.payments_rounded,
                title: t.courierPayoutDetails,
                subtitle: t.fripCashWallet,
                onTap: () => _openWallet(context),
              ),
              const SizedBox(height: 10),
              _WalletCard(
                balanceGnf: walletBalance,
                onTap: () => _openWallet(context),
              ),
              const SizedBox(height: 14),
              _WeeklyGoalCard(
                title: t.courierWeeklyGoalTitle,
                subtitle: t.courierWeeklyGoalSubtitle,
                actionLabel: t.courierGetStarted,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      t.courierEarningsHistory,
                      style: AppTypography.style(
                        fontWeight: FontWeight.w800,
                        fontSize: 18,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  if (widget.onOpenHistory != null)
                    TextButton(
                      onPressed: widget.onOpenHistory,
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                      child: Text(
                        t.courierViewAllHistory,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    CourierEarningsChart(weeks: weeks.reversed.toList()),
                    const SizedBox(height: 4),
                    ...weeks.map(
                      (week) => _WeeklyHistoryRow(
                        label: week.label,
                        amountGnf: week.amountGnf,
                        onTap: widget.onOpenHistory,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(icon, size: 14, color: AppColors.primary),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.style(
                    fontSize: 10,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.style(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Center(
                  child: AppIcon(
                    icon,
                    size: 22,
                    color: AppColors.primary,
                    filled: true,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.style(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.style(
                        fontSize: 12,
                        color: AppColors.textPrimary.withValues(alpha: 0.5),
                      ),
                    ),
                  ],
                ),
              ),
              AppIcon(
                AppIcons.chevronRight,
                size: 22,
                color: AppColors.textPrimary.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WalletCard extends StatelessWidget {
  const _WalletCard({
    required this.balanceGnf,
    required this.onTap,
  });

  final int balanceGnf;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 34,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryDark],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: AppIcon(
                  Symbols.account_balance_wallet_rounded,
                  color: Colors.white,
                  size: 18,
                  filled: true,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.fripCashWallet,
                      style: AppTypography.style(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    Text(
                      '${formatPrice(balanceGnf)} GNF',
                      style: AppTypography.style(
                        fontSize: 13,
                        color: AppColors.textPrimary.withValues(alpha: 0.55),
                      ),
                    ),
                  ],
                ),
              ),
              AppIcon(
                AppIcons.chevronRight,
                size: 22,
                color: AppColors.textPrimary.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeeklyGoalCard extends StatelessWidget {
  const _WeeklyGoalCard({
    required this.title,
    required this.subtitle,
    required this.actionLabel,
  });

  final String title;
  final String subtitle;
  final String actionLabel;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.style(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: AppTypography.style(
                    fontSize: 13,
                    color: AppColors.textPrimary.withValues(alpha: 0.65),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          AppLocalizations.of(context)!.challengeJoinedDemo,
                        ),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  icon: AppIcon(
                    Symbols.flag_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                  label: Text(
                    actionLabel,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: const BorderSide(color: AppColors.primary),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          AppIcon(
            Symbols.emoji_events_rounded,
            size: 48,
            color: AppColors.primary.withValues(alpha: 0.55),
            filled: true,
          ),
        ],
      ),
    );
  }
}

class _WeeklyHistoryRow extends StatelessWidget {
  const _WeeklyHistoryRow({
    required this.label,
    required this.amountGnf,
    this.onTap,
  });

  final String label;
  final int amountGnf;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: AppIcon(
                    Symbols.calendar_view_week_rounded,
                    size: 18,
                    color: AppColors.textPrimary.withValues(alpha: 0.55),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: AppTypography.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${formatPrice(amountGnf)} GNF',
                style: AppTypography.style(
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
              const SizedBox(width: 4),
              AppIcon(
                AppIcons.chevronRight,
                size: 20,
                color: AppColors.textPrimary.withValues(alpha: 0.3),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
