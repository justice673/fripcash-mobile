import 'package:flutter/material.dart';
import 'package:frip_cash/api/courier_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/courier_mission_detail_screen.dart';
import 'package:frip_cash/services/courier_repository.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/date_label_localization.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:material_symbols_icons/symbols.dart';

class CourierHistoryScreen extends StatefulWidget {
  const CourierHistoryScreen({super.key});

  @override
  State<CourierHistoryScreen> createState() => _CourierHistoryScreenState();
}

class _CourierHistoryScreenState extends State<CourierHistoryScreen> {
  List<CourierMission> _completed = const [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _reload());
  }

  Future<void> _reload() async {
    final list = await CourierRepository.instance.refreshMissions(
      filter: 'completed',
    );
    if (!mounted) return;
    setState(() => _completed = List.of(list));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final topInset = MediaQuery.paddingOf(context).top;

    return ColoredBox(
      color: const Color(0xFFF5F5F5),
      child: ListenableBuilder(
        listenable: CourierRepository.instance,
        builder: (context, _) {
          // Prefer last completed fetch; when repo holds completed filter results, use those.
          final repoMissions = CourierRepository.instance.missions;
          final fromRepo = repoMissions
              .where((m) => m.status == MissionStatus.delivered)
              .toList();
          final completed =
              fromRepo.isNotEmpty ? fromRepo : _completed;
          final totalEarned = completed.fold<int>(
            0,
            (sum, m) => sum + m.deliveryFeeGnf,
          );

          return RefreshIndicator(
            onRefresh: _reload,
            child: ListView(
              padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 28),
              children: [
                Text(
                  t.history,
                  style: AppTypography.display(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  t.courierHistorySubtitle,
                  style: AppTypography.style(
                    fontSize: 13,
                    color: AppColors.textPrimary.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF111111),
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _HistoryStat(
                          icon: Symbols.local_shipping_rounded,
                          label: t.courierTotalDeliveries,
                          value: '${completed.length}',
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 46,
                        color: Colors.white.withValues(alpha: 0.12),
                      ),
                      Expanded(
                        child: _HistoryStat(
                          icon: Symbols.payments_rounded,
                          label: t.courierTotalEarned,
                          value: '${formatPrice(totalEarned)} GNF',
                          emphasize: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  t.courierDeliveryHistory,
                  style: AppTypography.style(
                    fontWeight: FontWeight.w800,
                    fontSize: 17,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 12),
                if (completed.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 48),
                    child: Column(
                      children: [
                        AppIcon(
                          Symbols.history_rounded,
                          size: 48,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.noDeliveryHistoryYet,
                          textAlign: TextAlign.center,
                          style: AppTypography.style(
                            color: AppColors.textPrimary
                                .withValues(alpha: 0.55),
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  ...completed.map(
                    (mission) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HistoryCard(mission: mission),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HistoryStat extends StatelessWidget {
  const _HistoryStat({
    required this.icon,
    required this.label,
    required this.value,
    this.emphasize = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool emphasize;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppIcon(
                icon,
                size: 15,
                color: emphasize ? AppColors.primary : Colors.white70,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.style(
                    fontSize: 12,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.style(
              fontSize: emphasize ? 18 : 26,
              fontWeight: FontWeight.w800,
              color: emphasize ? AppColors.primary : Colors.white,
              letterSpacing: -0.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.mission});

  final CourierMission mission;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final repo = CourierRepository.instance;
    final pickupZone = repo.zoneLabel(mission.pickupZoneId);
    final deliveryZone = repo.zoneLabel(mission.deliveryZoneId);

    return Material(
      color: const Color(0xFFF3F4F6),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  CourierMissionDetailScreen(missionId: mission.actionId),
            ),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: Center(
                  child: AppIcon(
                    Symbols.check_circle_rounded,
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
                      '#${mission.orderId}',
                      style: AppTypography.style(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        AppIcon(
                          Symbols.schedule_rounded,
                          size: 13,
                          color: AppColors.textPrimary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          mission.createdAtLabel.localizedDateLabel(t),
                          style: AppTypography.style(
                            fontSize: 12,
                            color:
                                AppColors.textPrimary.withValues(alpha: 0.5),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        AppIcon(
                          Symbols.route_rounded,
                          size: 13,
                          color: AppColors.textPrimary.withValues(alpha: 0.4),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '$pickupZone → $deliveryZone',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.style(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary
                                  .withValues(alpha: 0.65),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '+${formatPrice(mission.deliveryFeeGnf)}',
                    style: AppTypography.style(
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  AppIcon(
                    AppIcons.chevronRight,
                    size: 20,
                    color: AppColors.textPrimary.withValues(alpha: 0.3),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
