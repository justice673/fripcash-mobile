import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/services/favorites_store.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/utils/price_formatter.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({
    super.key,
    required this.product,
    this.onTap,
  });

  final Product product;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
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
                  top: 8,
                  right: 8,
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
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: AppIcon(
                            AppIcons.favorite,
                            size: 18,
                            filled: liked,
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
            '${formatPrice(product.price)} GNF',
            style: AppTypography.style(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            '${formatPrice(product.priceWithShipping)} GNF ${t.includedSuffix}',
            style: AppTypography.style(fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            product.brand != null
                ? '${product.brand} · ${product.title}'
                : product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.style(fontSize: 13),
          ),
          if (product.size.isNotEmpty)
            Text(
              '${t.size} ${product.size}',
              style: AppTypography.style(fontSize: 12),
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
    if (isNetworkImageSource(source) || isAssetImageSource(source)) {
      return SizedBox.expand(
        child: SafeNetworkImage(
          url: source,
          fit: BoxFit.cover,
          showLoadingIndicator: true,
        ),
      );
    }

    return _imageError();
  }

  Widget _imageError() {
    return ColoredBox(
      color: Colors.grey.shade200,
      child: const Icon(Icons.image_outlined, color: Colors.grey),
    );
  }
}
