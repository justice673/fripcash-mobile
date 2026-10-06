import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

/// Compact "Recently added" product strip matching the homepage mockup.
class HomeRecentlyAddedSection extends StatelessWidget {
  const HomeRecentlyAddedSection({
    super.key,
    required this.products,
    this.onProductTap,
    this.onViewAll,
  });

  final List<Product> products;
  final ValueChanged<Product>? onProductTap;
  final VoidCallback? onViewAll;

  static const _tints = <Color>[
    Color(0xFFE8F5F3),
    Color(0xFFFCE8EF),
    Color(0xFFE6F4FF),
    Color(0xFFFFF3E0),
    Color(0xFFF3E8FF),
  ];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    if (products.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    t.recentlyAddedTitle,
                    style: AppTypography.style(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: onViewAll,
                  child: Text(
                    t.viewAll,
                    style: AppTypography.style(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary.withValues(alpha: 0.45),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: 196,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
              itemCount: products.length.clamp(0, 12),
              separatorBuilder: (context, index) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final product = products[index];
                final tint = _tints[index % _tints.length];
                return _RecentlyAddedCard(
                  product: product,
                  tint: tint,
                  onTap: onProductTap == null
                      ? null
                      : () => onProductTap!(product),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _RecentlyAddedCard extends StatelessWidget {
  const _RecentlyAddedCard({
    required this.product,
    required this.tint,
    this.onTap,
  });

  final Product product;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 132,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: tint,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                    child: ColoredBox(
                      color: Colors.white.withValues(alpha: 0.35),
                      child: isNetworkImageSource(product.image)
                          ? SafeNetworkImage(
                              url: product.image,
                              fit: BoxFit.cover,
                            )
                          : Image.asset(
                              product.image,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  ColoredBox(
                                color: Colors.white.withValues(alpha: 0.5),
                              ),
                            ),
                    ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              product.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTypography.style(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${formatPrice(product.price)} GNF',
              style: AppTypography.style(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
