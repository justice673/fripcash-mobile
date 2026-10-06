import 'package:flutter/material.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/widgets/home/home_recommended_section.dart';

/// Untitled product feed (Vinted-style continuous scroll).
///
/// Use [buildSlivers] inside a [CustomScrollView]. The parent owns paging
/// via [visibleCount] and loads more when the user nears the end.
abstract final class HomeFeedGrid {
  static const pageSize = 10;
  static const initialCount = 10;

  static List<Widget> buildSlivers({
    required BuildContext context,
    required List<Product> products,
    required int visibleCount,
    required bool isLoadingMore,
    ValueChanged<Product>? onProductTap,
    double topPadding = 20,
  }) {
    final count = visibleCount.clamp(0, products.length);
    if (count == 0 && !isLoadingMore) {
      return const [SliverToBoxAdapter(child: SizedBox.shrink())];
    }

    return [
      SliverPadding(
        padding: EdgeInsets.fromLTRB(16, topPadding, 16, 8),
        sliver: SliverGrid(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: AppBreakpoints.productGridCrossAxisCount(context),
            crossAxisSpacing: 12,
            mainAxisSpacing:
                AppBreakpoints.productGridMainAxisSpacing(context),
            childAspectRatio:
                AppBreakpoints.productGridChildAspectRatio(context),
          ),
          delegate: SliverChildBuilderDelegate(
            (context, index) {
              final product = products[index];
              return RecommendedProductCard(
                product: product,
                onTap: onProductTap == null
                    ? null
                    : () => onProductTap(product),
              );
            },
            childCount: count,
          ),
        ),
      ),
      if (isLoadingMore)
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(
              child: SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2.4),
              ),
            ),
          ),
        )
      else
        const SliverToBoxAdapter(child: SizedBox(height: 8)),
    ];
  }
}
