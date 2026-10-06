import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/services/mock_listing_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

void showSellerStockAdjustSheet(
  BuildContext context, {
  required List<Product> listings,
}) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (context) {
      return _SellerStockAdjustSheet(listings: listings);
    },
  );
}

class _SellerStockAdjustSheet extends StatelessWidget {
  const _SellerStockAdjustSheet({required this.listings});

  final List<Product> listings;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final alertListings = listings
        .where((p) => p.isLowStock || !p.inStock)
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              t.adjustStocksTitle,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              t.itemsInAlertOrOutOfStock,
              style: TextStyle(fontSize: 13, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 16),
            if (alertListings.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24),
                child: Text(
                  t.noItemInStockAlert,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              )
            else
              Flexible(
                child: ListenableBuilder(
                  listenable: MockListingService.instance,
                  builder: (context, _) {
                    return ListView.separated(
                      shrinkWrap: true,
                      itemCount: alertListings.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        final id = alertListings[index].id;
                        final sellerId = alertListings[index].sellerId;
                        final refreshed = MockListingService.instance
                            .listingsForSeller(sellerId);
                        final product = refreshed
                                .where((p) => p.id == id)
                                .firstOrNull ??
                            alertListings[index];
                        return _StockAdjustRow(product: product);
                      },
                    );
                  },
                ),
              ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.close),
            ),
          ],
        ),
      ),
    );
  }
}

class _StockAdjustRow extends StatelessWidget {
  const _StockAdjustRow({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          SafeNetworkImage(
            url: product.image,
            width: 44,
            height: 44,
            borderRadius: BorderRadius.circular(8),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  '${t.stock}: ${product.stock}',
                  style: TextStyle(
                    fontSize: 12,
                    color: product.inStock
                        ? Colors.orange.shade800
                        : Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: product.stock > 0
                ? () async {
                    try {
                      await MockListingService.instance
                          .adjustStockAsync(product.id, -1);
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(e.toString()),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                : null,
            icon: const Icon(Icons.remove_circle_outline),
            color: AppColors.textPrimary,
          ),
          IconButton(
            onPressed: () async {
              try {
                await MockListingService.instance
                    .adjustStockAsync(product.id, 1);
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(e.toString()),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Icon(Icons.add_circle_outline),
            color: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final iterator = this.iterator;
    if (!iterator.moveNext()) return null;
    return iterator.current;
  }
}
