import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/seller.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/screens/showcase_screen.dart';
import 'package:frip_cash/screens/seller_profile_screen.dart';
import 'package:frip_cash/services/favorites_store.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/product_lookup.dart';
import 'package:frip_cash/widgets/follow_button.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

List<Product> showcaseProductsForSeller(String sellerId) =>
    productsForSeller(sellerId, limit: homeSectionProductLimit);

/// Sellers spotlighted on home — derived from live catalog (no hard-coded demos).
List<String> get homeShowcaseSellerIds {
  final ids = <String>[];
  for (final p in ListingsRepository.instance.allCached) {
    if (!ids.contains(p.sellerId)) ids.add(p.sellerId);
    if (ids.length >= 4) break;
  }
  return ids;
}

/// Vinted-inspired multi-seller spotlight with horizontal item scroll.
class HomeShowcaseSection extends StatelessWidget {
  const HomeShowcaseSection({
    super.key,
    this.sellerIds,
    this.maxSellers = 4,
    this.topPadding = 28,
  });

  final List<String>? sellerIds;
  final int maxSellers;
  final double topPadding;

  List<SellerInfo> get _sellers {
    final result = <SellerInfo>[];
    final ids = sellerIds ?? homeShowcaseSellerIds;
    for (final id in ids) {
      final seller = sellerById(id);
      if (seller == null) continue;
      if (showcaseProductsForSeller(seller.id).isEmpty) continue;
      result.add(seller);
      if (result.length >= maxSellers) break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final sellers = _sellers;
    if (sellers.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: EdgeInsets.only(top: topPadding),
      child: Column(
        children: [
          Text(
            t.showcaseTitle,
            style: AppTypography.style(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < sellers.length; i++) ...[
            if (i > 0) const SizedBox(height: 22),
            ShowcaseSellerBlock(
              seller: sellers[i],
              products: showcaseProductsForSeller(sellers[i].id),
              onSellerTap: () => openSellerProfile(context, sellers[i].id),
              onProductTap: (product) => openProductDetail(context, product),
            ),
          ],
          const SizedBox(height: 16),
          Center(
            child: OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ShowcaseScreen(),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                side: const BorderSide(
                  color: AppColors.textPrimary,
                  width: 1.4,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
              ),
              child: Text(
                t.seeMore,
                style: AppTypography.style(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ShowcaseSellerBlock extends StatelessWidget {
  const ShowcaseSellerBlock({
    super.key,
    required this.seller,
    required this.products,
    this.onSellerTap,
    this.onProductTap,
  });

  final SellerInfo seller;
  final List<Product> products;
  final VoidCallback? onSellerTap;
  final ValueChanged<Product>? onProductTap;

  static const _productRowHeight = 252.0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          InkWell(
            onTap: onSellerTap,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: SafeNetworkImage(
                      url: seller.avatarUrl,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                      iconSize: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          seller.username,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.style(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            ...List.generate(5, (index) {
                              final filled = index < seller.rating.round();
                              return Icon(
                                filled ? Icons.star : Icons.star_border,
                                size: 14,
                                color: const Color(0xFFFFB800),
                              );
                            }),
                            const SizedBox(width: 4),
                            Text(
                              seller.rating.toStringAsFixed(1),
                              style: AppTypography.style(fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  FollowButton(sellerId: seller.id),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (products.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Text(
                t.noPublicListings,
                style: AppTypography.style(fontSize: 14),
              ),
            )
          else
            SizedBox(
              height: _productRowHeight,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: products.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return ShowcaseProductCard(
                    product: products[index],
                    onTap: onProductTap == null
                        ? null
                        : () => onProductTap!(products[index]),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}

class ShowcaseProductCard extends StatelessWidget {
  const ShowcaseProductCard({
    super.key,
    required this.product,
    this.onTap,
    this.width = 148,
  });

  final Product product;
  final VoidCallback? onTap;
  final double width;

  static const _imageAspectRatio = 0.92;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final sizeLabel = product.size.toLowerCase() == 'unique'
        ? t.oneSize
        : product.size;
    final headline = product.brand ?? product.title;

    return SizedBox(
      width: width,
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            AspectRatio(
              aspectRatio: _imageAspectRatio,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: SafeNetworkImage(
                      url: product.image,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    bottom: 8,
                    child: ListenableBuilder(
                      listenable: FavoritesStore.instance,
                      builder: (context, _) {
                        final liked =
                            FavoritesStore.instance.isFavorite(product.id);
                        return GestureDetector(
                          onTap: () =>
                              FavoritesStore.instance.toggle(product.id),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.95),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  liked
                                      ? Icons.favorite
                                      : Icons.favorite_border,
                                  size: 14,
                                  color: liked
                                      ? Colors.redAccent
                                      : AppColors.textPrimary,
                                ),
                                if (product.likes > 0) ...[
                                  const SizedBox(width: 4),
                                  Text(
                                    '${product.likes}',
                                    style: AppTypography.style(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              headline,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.style(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.15,
              ),
            ),
            Text(
              '$sizeLabel · ${product.condition}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.style(fontSize: 11, height: 1.15),
            ),
            Text(
              '${formatPrice(product.price)} GNF',
              style: AppTypography.style(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                height: 1.1,
              ),
            ),
            Text(
              '${formatPrice(product.priceWithShipping)} GNF ${t.includedSuffix}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.style(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.primary,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void openSellerProfile(BuildContext context, String sellerId) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => SellerProfileScreen(sellerId: sellerId),
    ),
  );
}
