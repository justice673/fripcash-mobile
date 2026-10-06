import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_wallet_transactions.dart';
import 'package:frip_cash/screens/create_listing_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/services/mock_wallet_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/date_label_localization.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/widgets/profile_empty_illustrations.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  @override
  void initState() {
    super.initState();
    runAfterFrame(() {
      MockWalletService.instance.syncForUser(MockSession.instance.user);
    });
  }

  Future<void> _withdraw() async {
    final t = AppLocalizations.of(context)!;
    final wallet = MockWalletService.instance;
    if (!wallet.canWithdraw) return;

    final amountController = TextEditingController(
      text: wallet.availableGnf.toString(),
    );
    final phoneController = TextEditingController(
      text: wallet.defaultPayoutMsisdn ??
          MockSession.instance.user.phone,
    );

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.withdrawToOrangeMoney),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${t.availableBalance}: ${formatPrice(wallet.availableGnf)} GNF',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textPrimary.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: 'GNF',
                  hintText: formatPrice(wallet.minWithdrawalGnf),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: phoneController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  labelText: t.orangeMoneyNumber,
                  hintText: t.phoneNumberHint224,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(t.confirm),
            ),
          ],
        );
      },
    );

    final amountText = amountController.text.trim();
    final phone = phoneController.text.trim();
    amountController.dispose();
    phoneController.dispose();

    if (confirmed != true || !mounted) return;

    final amount = int.tryParse(amountText) ?? 0;
    try {
      await wallet.withdrawToOrangeMoney(
        amount,
        orangeMoneyPhone: phone,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(t.withdrawalInitiatedSimulation),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.message),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.fripCashBalance,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          IconButton(
            onPressed: () {
              MockWalletService.instance.syncForUser(
                MockSession.instance.user,
              );
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListenableBuilder(
        listenable: MockWalletService.instance,
        builder: (context, _) {
          final wallet = MockWalletService.instance;
          final pending = wallet.pendingEscrowGnf;
          final canWithdraw = wallet.canWithdraw;

          return RefreshIndicator(
            onRefresh: () =>
                MockWalletService.instance.syncForUser(
                  MockSession.instance.user,
                ),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                if (wallet.loading)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12),
                    child: LinearProgressIndicator(minHeight: 2),
                  ),
                if (wallet.error != null && !wallet.loading)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: AppColors.rosePoudre,
                      borderRadius: BorderRadius.circular(12),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.walletLoadError,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                MockWalletService.instance.syncForUser(
                                  MockSession.instance.user,
                                );
                              },
                              child: Text(t.retryAction),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(20, 22, 20, 28),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppColors.primary,
                        AppColors.primaryDark,
                        Color(0xFF6B2E1A),
                      ],
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(
                        right: -8,
                        bottom: -18,
                        child: Text(
                          'fripcash',
                          style: TextStyle(
                            fontSize: 42,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -1,
                            color: Colors.white.withValues(alpha: 0.12),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.availableBalance,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${formatPrice(wallet.availableGnf)} GNF',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Divider(color: Colors.white.withValues(alpha: 0.35)),
                          const SizedBox(height: 10),
                          Text(
                            t.pendingAmountGnf(formatPrice(pending)),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: canWithdraw ? _withdraw : null,
                    style: FilledButton.styleFrom(
                      backgroundColor: canWithdraw
                          ? AppColors.textPrimary
                          : const Color(0xFFF0F0F0),
                      foregroundColor:
                          canWithdraw ? Colors.white : _SellMuted.muted,
                      disabledForegroundColor: _SellMuted.muted,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: const StadiumBorder(),
                    ),
                    child: Text(
                      canWithdraw
                          ? t.withdrawToOrangeMoney
                          : t.noBalanceToWithdraw,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  children: [
                    Text(
                      t.latestTransactions,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (wallet.transactions.isNotEmpty)
                      Text(
                        t.seeAll,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary.withValues(alpha: 0.65),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                if (wallet.transactions.isEmpty) ...[
                  const Center(
                    child: ProfileEmptyIllustrations.balance,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.noTransactionsYet,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 18,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    t.noTransactionsHint,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.4,
                      color: AppColors.textPrimary.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const CreateListingScreen(),
                          ),
                        );
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 14,
                        ),
                        shape: const StadiumBorder(),
                      ),
                      child: Text(
                        t.sellAnItem,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ] else
                  for (final tx in wallet.transactions)
                    _TransactionTile(transaction: tx),
              ],
            ),
          );
        },
      ),
    );
  }
}

abstract final class _SellMuted {
  static const muted = Color(0xFF8A8A8A);
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final WalletTransaction transaction;

  IconData get _icon => switch (transaction.type) {
        WalletTransactionType.saleCredit => Icons.add_circle_outline,
        WalletTransactionType.withdrawal => Icons.phone_android,
        WalletTransactionType.deliveryFee => Icons.local_shipping_outlined,
        WalletTransactionType.escrowHold => Icons.lock_outline,
        WalletTransactionType.escrowRelease => Icons.lock_open_outlined,
        WalletTransactionType.refund => Icons.replay_outlined,
        WalletTransactionType.partialRefund =>
          Icons.replay_circle_filled_outlined,
        WalletTransactionType.platformCommission => Icons.percent_outlined,
        WalletTransactionType.adjustment => Icons.tune_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isCredit = transaction.isCredit;
    final color = isCredit ? AppColors.primary : AppColors.textPrimary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(_icon, size: 20, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                Text(
                  transaction.dateLabel.localizedDateLabel(t),
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textPrimary.withValues(alpha: 0.55),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${isCredit ? '+' : '-'}${formatPrice(transaction.amountGnf)}',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
