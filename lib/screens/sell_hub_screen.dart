import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/screens/become_seller_screen.dart';
import 'package:frip_cash/screens/create_listing_screen.dart';
import 'package:frip_cash/screens/excel_import_screen.dart';
import 'package:frip_cash/screens/my_listings_screen.dart';
import 'package:frip_cash/screens/product_library_screen.dart';
import 'package:frip_cash/screens/seller_dashboard_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/seller_access.dart';

/// Role-scoped Sell tab — only actions that role is allowed to perform.
class SellHubScreen extends StatelessWidget {
  const SellHubScreen({super.key});

  void _openBecomeSeller(BuildContext context, {SignUpRole? role}) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BecomeSellerScreen(initialRole: role),
      ),
    );
  }

  void _startIndividualListing(BuildContext context) {
    _openBecomeSeller(context, role: SignUpRole.particulier);
  }

  void _open(BuildContext context, Widget screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => screen),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MockSession.instance,
      builder: (context, _) {
        final t = AppLocalizations.of(context)!;
        final user = MockSession.instance.user;
        final kind = sellerProfileKind(user);
        final isRealSeller = user.role.isSeller;
        final isBuyer = user.role == UserRole.acheteur && !hasSellerAccess;

        // Shared Ma boutique shell for particulier / boutique / enseigne.
        if (!isBuyer && (isRealSeller || hasSellerAccess)) {
          return const SellerDashboardScreen();
        }

        final subtitle = switch (kind) {
          _ when isBuyer => t.publishQuickly,
          SellerProfileKind.boutiqueProximite => t.proximitySellSubtitle,
          SellerProfileKind.boutiqueStandard => t.manageListingsSubtitle,
          SellerProfileKind.boutiqueEnseigne => t.manageListingsSubtitle,
          SellerProfileKind.particulier => t.manageListingsSubtitle,
        };

        return SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              Text(
                t.sellTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textPrimary.withValues(alpha: 0.65),
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 24),
              if (isBuyer)
                ..._buyerCards(context, t)
              else if (kind == SellerProfileKind.boutiqueProximite)
                ..._proximityShopCards(context, t)
              else if (kind == SellerProfileKind.boutiqueStandard ||
                  kind == SellerProfileKind.boutiqueEnseigne ||
                  user.role == UserRole.boutique)
                ..._standardShopCards(context, t)
              else if (isRealSeller || hasSellerAccess)
                ..._particulierCards(context, t),
            ],
          ),
        );
      },
    );
  }

  /// Buyer: only onboarding into selling — no seller workspace.
  List<Widget> _buyerCards(BuildContext context, AppLocalizations t) {
    return [
      _SellOptionCard(
        icon: Icons.person_outline,
        title: t.sellAsIndividual,
        subtitle: t.sellAsIndividualSubtitle,
        onTap: () => _startIndividualListing(context),
      ),
      const SizedBox(height: 12),
      _SellOptionCard(
        icon: Icons.storefront_outlined,
        title: t.createShop,
        subtitle: t.createShopSubtitle,
        onTap: () => _openBecomeSeller(context),
      ),
    ];
  }

  /// Individual seller: listings + dashboard only.
  List<Widget> _particulierCards(BuildContext context, AppLocalizations t) {
    return [
      _SellOptionCard(
        icon: Icons.dashboard_outlined,
        title: t.sellerDashboardTitle,
        subtitle: t.sellerDashboardSubtitle,
        onTap: () => _open(context, const SellerDashboardScreen()),
      ),
      const SizedBox(height: 12),
      _SellOptionCard(
        icon: Icons.add_circle_outline,
        title: t.newListing,
        subtitle: t.sellAsIndividualSubtitle,
        onTap: () => _open(context, const CreateListingScreen()),
      ),
      const SizedBox(height: 12),
      _SellOptionCard(
        icon: Icons.inventory_2_outlined,
        title: t.myListings,
        subtitle: t.manageListingsSubtitle,
        onTap: () => _open(context, const MyListingsScreen()),
      ),
    ];
  }

  /// Classic boutique: dashboard, listings, Excel — no library / no “become seller”.
  List<Widget> _standardShopCards(BuildContext context, AppLocalizations t) {
    return [
      _SellOptionCard(
        icon: Icons.dashboard_outlined,
        title: t.sellerDashboardTitle,
        subtitle: t.sellerDashboardSubtitle,
        onTap: () => _open(context, const SellerDashboardScreen()),
      ),
      const SizedBox(height: 12),
      _SellOptionCard(
        icon: Icons.add_circle_outline,
        title: t.newListing,
        subtitle: t.addManuallySubtitle,
        onTap: () => _open(context, const CreateListingScreen()),
      ),
      const SizedBox(height: 12),
      _SellOptionCard(
        icon: Icons.inventory_2_outlined,
        title: t.myListings,
        subtitle: t.manageListingsSubtitle,
        onTap: () => _open(context, const MyListingsScreen()),
      ),
      const SizedBox(height: 12),
      _SellOptionCard(
        icon: Icons.upload_file_outlined,
        title: t.importExcelCatalog,
        subtitle: t.importExcelSubtitle,
        onTap: () => _open(context, const ExcelImportScreen()),
      ),
    ];
  }

  /// Neighborhood shop: Excel + library + manual (proximity tools only).
  List<Widget> _proximityShopCards(BuildContext context, AppLocalizations t) {
    return [
      _SellOptionCard(
        icon: Icons.dashboard_outlined,
        title: t.sellerDashboardTitle,
        subtitle: t.sellerDashboardSubtitle,
        onTap: () => _open(context, const SellerDashboardScreen()),
      ),
      const SizedBox(height: 12),
      _SellOptionCard(
        icon: Icons.upload_file_outlined,
        title: t.importExcelCatalog,
        subtitle: t.importExcelSubtitle,
        onTap: () => _open(context, const ExcelImportScreen()),
      ),
      const SizedBox(height: 12),
      _SellOptionCard(
        icon: Icons.menu_book_outlined,
        title: t.addFromLibrary,
        subtitle: t.addFromLibrarySubtitle,
        onTap: () => _open(context, const ProductLibraryScreen()),
      ),
      const SizedBox(height: 12),
      _SellOptionCard(
        icon: Icons.edit_outlined,
        title: t.addManually,
        subtitle: t.addManuallySubtitle,
        onTap: () => _open(context, const CreateListingScreen()),
      ),
      const SizedBox(height: 12),
      _SellOptionCard(
        icon: Icons.inventory_2_outlined,
        title: t.myListings,
        subtitle: t.manageListingsSubtitle,
        onTap: () => _open(context, const MyListingsScreen()),
      ),
    ];
  }
}

class _SellOptionCard extends StatelessWidget {
  const _SellOptionCard({
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
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textPrimary.withValues(alpha: 0.65),
                        height: 1.3,
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
    );
  }
}
