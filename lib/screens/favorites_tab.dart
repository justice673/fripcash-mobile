import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/services/favorites_store.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/empty_state_lottie.dart';
import 'package:frip_cash/widgets/empty_state_view.dart';
import 'package:frip_cash/widgets/seller_type_badge.dart';

class FavoritesTab extends StatelessWidget {
  const FavoritesTab({super.key, this.onExplore});

  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final canPop = Navigator.canPop(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: canPop
          ? AppBar(
              backgroundColor: AppColors.background,
              foregroundColor: AppColors.textPrimary,
              elevation: 0,
              surfaceTintColor: Colors.white,
              title: Text(
                t.favoritesNav,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            )
          : null,
      body: SafeArea(
        top: !canPop,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!canPop)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: Text(
                t.favoritesNav,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          Expanded(
            child: ListenableBuilder(
              listenable: FavoritesStore.instance,
              builder: (context, _) {
                final favorites = FavoritesStore.instance.favorites;
                if (favorites.isEmpty) {
                  return _EmptyFavorites(
                    onExplore: onExplore ?? () {},
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount:
                        AppBreakpoints.productGridCrossAxisCount(context),
                    crossAxisSpacing: 12,
                    mainAxisSpacing:
                        AppBreakpoints.productGridMainAxisSpacing(context),
                    childAspectRatio:
                        AppBreakpoints.productGridChildAspectRatio(context),
                  ),
                  itemCount: favorites.length,
                  itemBuilder: (context, index) {
                    return FavoriteProductCard(product: favorites[index]);
                  },
                );
              },
            ),
          ),
        ],
        ),
      ),
    );
  }
}

class FavoriteProductCard extends StatelessWidget {
  const FavoriteProductCard({super.key, required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final sizeLabel = product.size.toLowerCase() == 'unique'
        ? t.oneSize
        : product.size;
    final headline = product.brand ?? product.title;
    final meta = product.brand != null
        ? product.condition
        : '$sizeLabel · ${product.condition}';
    final seller = sellerForProduct(product.id);

    return GestureDetector(
      onTap: () => openProductDetail(context, product),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.image,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return ColoredBox(
                        color: Colors.grey.shade200,
                        child: const Icon(Icons.image_outlined),
                      );
                    },
                  ),
                ),
                if (product.badge != null)
                  Positioned(
                    left: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        product.badge!,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                if (product.stock <= 5)
                  Positioned(
                    left: 8,
                    top: product.badge != null ? 36 : 8,
                    child: StockBadge(stock: product.stock),
                  ),
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: GestureDetector(
                    onTap: () => FavoritesStore.instance.toggle(product.id),
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
                          const Icon(
                            Icons.favorite,
                            size: 14,
                            color: Colors.redAccent,
                          ),
                          if (product.likes > 0) ...[
                            const SizedBox(width: 4),
                            Text(
                              '${product.likes}',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          SellerTypeBadge(type: seller.type, compact: true),
          const SizedBox(height: 2),
          Text(
            headline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              height: 1.15,
            ),
          ),
          Text(
            meta,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '${formatPrice(product.price)} GNF',
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          Row(
            children: [
              Flexible(
                child: Text(
                  '${formatPrice(product.priceWithShipping)} GNF ${t.includedSuffix}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 2),
              Icon(
                Icons.verified_user_outlined,
                size: 13,
                color: AppColors.primary.withValues(alpha: 0.8),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyFavorites extends StatelessWidget {
  const _EmptyFavorites({required this.onExplore});

  final VoidCallback onExplore;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return EmptyStateView(
      illustration: const EmptyStateLottie(size: 160),
      title: t.noFavoritesYet,
      subtitle: t.noFavoritesSubtitle,
      actionLabel: t.discoverItemsAction,
      onAction: onExplore,
    );
  }
}
