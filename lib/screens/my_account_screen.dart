import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/screens/become_seller_screen.dart';
import 'package:frip_cash/screens/bundle_discount_screen.dart';
import 'package:frip_cash/screens/buyer_offers_screen.dart';
import 'package:frip_cash/screens/help_screen.dart';
import 'package:frip_cash/screens/public_profile_screen.dart';
import 'package:frip_cash/screens/settings_screen.dart';
import 'package:frip_cash/screens/vacation_mode_screen.dart';
import 'package:frip_cash/screens/wallet_screen.dart';
import 'package:frip_cash/screens/welcome_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/seller_access.dart';

/// Depop-style My account — opened from profile hamburger.
class MyAccountScreen extends StatelessWidget {
  const MyAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    void open(Widget screen) {
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => screen),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        title: Text(
          t.myAccountTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
      ),
      body: ListenableBuilder(
        listenable: MockSession.instance,
        builder: (context, _) {
          final user = MockSession.instance.user;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: () => open(const WalletScreen()),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppColors.primary.withValues(alpha: 0.12),
                      Colors.white,
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.account_balance_wallet_outlined,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        t.fripCashBalance,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 17,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right,
                      color: AppColors.textPrimary.withValues(alpha: 0.35),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (!user.role.isSeller) ...[
            const SizedBox(height: 14),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => open(const BecomeSellerScreen()),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.sage.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: AppColors.sage,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.becomeSellerAccountTile,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.becomeSellerAccountSubtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textPrimary.withValues(alpha: 0.35),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (canCreateOrUpgradeShop && user.role.isSeller) ...[
            const SizedBox(height: 14),
            Material(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                onTap: () => open(const BecomeSellerScreen(shopOnly: true)),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE5E5E5)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.store_mall_directory_outlined,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              t.createShop,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.upgradeToShopSubtitle,
                              style: TextStyle(
                                fontSize: 13,
                                color: AppColors.textPrimary.withValues(
                                  alpha: 0.55,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: AppColors.textPrimary.withValues(alpha: 0.35),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          _SectionLabel(t.sellMoreSection),
          _AccountTile(
            icon: Icons.local_offer_outlined,
            label: t.myOffers,
            onTap: () => open(const BuyerOffersScreen()),
          ),
          if (canAccessSellerTools)
            _AccountTile(
              icon: Icons.card_giftcard_outlined,
              label: t.bundles,
              onTap: () => open(const BundleDiscountScreen()),
            ),
          const SizedBox(height: 18),
          _SectionLabel(t.supportSection),
          _AccountTile(
            icon: Icons.flag_outlined,
            label: t.soldItemIssues,
            onTap: () => open(const HelpScreen()),
          ),
          _AccountTile(
            icon: Icons.help_outline,
            label: t.helpAndSupport,
            onTap: () => open(const HelpScreen()),
          ),
          const SizedBox(height: 18),
          _SectionLabel(t.settingsSection),
          _AccountTile(
            icon: Icons.person_outline,
            label: t.accountDetails,
            onTap: () => open(const PublicProfileScreen()),
          ),
          _AccountTile(
            icon: Icons.payments_outlined,
            label: t.paymentSettings,
            onTap: () => open(const WalletScreen()),
          ),
          _AccountTile(
            icon: Icons.settings_outlined,
            label: t.preferences,
            onTap: () => open(const SettingsScreen()),
          ),
          if (canAccessSellerTools)
            _AccountTile(
              icon: Icons.beach_access_outlined,
              label: t.vacationMode,
              onTap: () => open(const VacationModeScreen()),
            ),
          _AccountTile(
            icon: Icons.lock_outline,
            label: t.privacy,
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (ctx) {
                  return AlertDialog(
                    title: Text(t.privacyPolicy),
                    content: SingleChildScrollView(
                      child: Text(t.legalPrivacyBody),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        child: Text(t.close),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 20),
          TextButton(
            onPressed: () async {
              await MockSession.instance.signOut();
              if (!context.mounted) return;
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute<void>(
                  builder: (_) => const WelcomeScreen(),
                ),
                (_) => false,
              );
            },
            child: Text(
              t.signOut,
              style: TextStyle(
                color: Colors.red.shade600,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            t.appVersionLabel('1.0.0'),
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary.withValues(alpha: 0.4),
            ),
          ),
        ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary.withValues(alpha: 0.5),
        ),
      ),
    );
  }
}

class _AccountTile extends StatelessWidget {
  const _AccountTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: AppColors.textPrimary, size: 24),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textPrimary.withValues(alpha: 0.35),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
