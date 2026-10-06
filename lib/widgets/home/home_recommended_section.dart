import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/services/favorites_store.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

class HomeRecommendedSection extends StatelessWidget {
  const HomeRecommendedSection({
    super.key,
    required this.products,
    this.topPadding = 28,
  });

  final List<Product> products;
  final double topPadding;

  static List<Widget> buildSlivers({
    required BuildContext context,
    required List<Product> products,
    required String title,
    double topPadding = 28,
    ValueChanged<Product>? onProductTap,
  }) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppBreakpoints.productGridCrossAxisCount(context),
            crossAxisSpacing: 12,
            mainAxisSpacing:
                AppBreakpoints.productGridMainAxisSpacing(context),
            // Tighter meta under image → shorter cells.
            childAspectRatio: AppBreakpoints.isTablet(context) ? 0.78 : 0.72,
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) => RecommendedProductCard(
              product: products[index],
              onTap: onProductTap == null
                  ? null
                  : () => onProductTap(products[index]),
            ),
            childCount: products.length,
          ),
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(16, topPadding, 16, 12),
          child: Text(
            t.recommendedForYou,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: AppBreakpoints.productGridCrossAxisCount(context),
              crossAxisSpacing: 12,
              mainAxisSpacing:
                  AppBreakpoints.productGridMainAxisSpacing(context),
              childAspectRatio: AppBreakpoints.isTablet(context) ? 0.78 : 0.72,
            ),
            itemCount: products.length,
            itemBuilder: (context, index) {
              return RecommendedProductCard(product: products[index]);
            },
          ),
        ),
      ],
    );
  }
}

class RecommendedProductCard extends StatelessWidget {
  const RecommendedProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final headline = product.brand ?? product.title;

    return GestureDetector(
      onTap: onTap,
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
                  child: _ProductImage(source: product.image),
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
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.95),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            liked ? Icons.favorite : Icons.favorite_border,
                            size: 16,
                            color: liked
                                ? Colors.redAccent
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            headline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
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
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductImage extends StatelessWidget {
  const _ProductImage({required this.source});

  final String source;

  @override
  Widget build(BuildContext context) {
    if (source.startsWith('http')) {
      return SizedBox.expand(
        child: SafeNetworkImage(url: source, fit: BoxFit.cover),
      );
    }

    return Image.asset(
      source,
      width: double.infinity,
      height: double.infinity,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => _imageError(),
    );
  }

  Widget _imageError() {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}
