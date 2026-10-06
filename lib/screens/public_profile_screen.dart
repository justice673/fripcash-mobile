import 'package:flutter/material.dart';
import 'package:frip_cash/api/me_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/services/mock_listing_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/seller_access.dart';
import 'package:frip_cash/utils/share_links.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

class PublicProfileScreen extends StatelessWidget {
  const PublicProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: MockSession.instance,
      builder: (context, _) {
        final t = AppLocalizations.of(context)!;
        final user = MockSession.instance.user;
        final displayName = user.shopName ?? user.name;
        final roleLabel = switch (user.role) {
          UserRole.acheteur => t.buyerRole,
          UserRole.vendeurParticulier => t.individualSellerRole,
          UserRole.boutique => t.shopRole,
          UserRole.livreur => t.courierRole,
          UserRole.admin => t.adminRole,
        };
        final listings = user.role.isSeller
            ? MockListingService.instance.listingsForSeller(user.sellerId)
            : <Product>[];

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            foregroundColor: AppColors.textPrimary,
            elevation: 0,
            title: Text(
              t.myPublicProfile,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            actions: [
              if (user.role.isSeller)
                IconButton(
                  tooltip: t.share,
                  icon: const Icon(Icons.ios_share_outlined),
                  onPressed: () async {
                    String? url;
                    try {
                      url = (await MeApi.instance.fetchSellerShare())
                          .publicShopUrl;
                    } catch (_) {
                      url = null;
                    }
                    if (!context.mounted) return;
                    await shareShop(
                      context,
                      sellerId: effectiveSellerId(user),
                      shopName: displayName,
                      publicUrl: url,
                    );
                  },
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SafeNetworkImage(
                      url: '',
                      width: 72,
                      height: 72,
                      fit: BoxFit.cover,
                      iconSize: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            roleLabel,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              if (user.role.isSeller) ...[
                const SizedBox(height: 24),
                Text(
                  '${t.listings} (${listings.length})',
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                if (listings.isEmpty)
                  Text(
                    t.noPublicListings,
                    style: TextStyle(color: AppColors.textPrimary),
                  )
                else
                  for (final product in listings.take(6))
                    _ListingRow(product: product),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ListingRow extends StatelessWidget {
  const _ListingRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => openProductDetail(context, product),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SafeNetworkImage(
                  url: product.image,
                  width: 52,
                  height: 52,
                  fit: BoxFit.cover,
                  iconSize: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  product.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Text(
                '${formatPrice(product.price)} GNF',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
