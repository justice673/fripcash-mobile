import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/navigation/checkout_navigation.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/services/cart_store.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/empty_state_lottie.dart';
import 'package:frip_cash/widgets/empty_state_view.dart';

void showCartSheet(BuildContext hostContext) {
  // Best-effort sync with Nest cart when available.
  CartStore.instance.refresh();
  showModalBottomSheet<void>(
    context: hostContext,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    // Keep the opener context for checkout — the sheet context is disposed on pop.
    builder: (sheetContext) => CartSheet(hostContext: hostContext),
  );
}

class CartSheet extends StatelessWidget {
  const CartSheet({super.key, required this.hostContext});

  /// Context that opened the sheet (still mounted after the sheet is dismissed).
  final BuildContext hostContext;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final height = MediaQuery.sizeOf(context).height * 0.78;

    return ListenableBuilder(
      listenable: CartStore.instance,
      builder: (context, _) {
        final cart = CartStore.instance;
        final items = cart.items;
        final hasStockIssue = cart.hasUnavailableItems;

        return SizedBox(
          height: height,
          child: Column(
            children: [
              const SizedBox(height: 8),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                child: Row(
                  children: [
                    const Icon(Icons.shopping_bag_outlined, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      '${t.myCart} (${cart.itemCount})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              if (hasStockIssue)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  color: Colors.red.shade50,
                  child: Text(
                    t.removeOutOfStockToContinue,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              Expanded(
                child: items.isEmpty
                    ? EmptyStateView(
                        illustration: const EmptyStateLottie(size: 160),
                        title: t.emptyCartTitle,
                        subtitle:
                            t.emptyCartSubtitle,
                        actionLabel: t.discoverItemsAction,
                        onAction: () => Navigator.of(context).pop(),
                      )
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                        children: [
                          if (cart.hasMultipleSellers)
                            for (final group in cart.groupedBySeller) ...[
                              _SellerSlaHeader(sellerId: group.sellerId),
                              ...group.items.map(
                                (item) => _CartItemTile(item: item),
                              ),
                              const SizedBox(height: 4),
                            ]
                          else
                            ...items.map(
                              (item) => _CartItemTile(item: item),
                            ),
                        ],
                      ),
              ),
              if (items.isNotEmpty)
                _CartSummary(
                  subtotal: cart.subtotal,
                  shipping: cart.shippingTotal,
                  total: cart.total,
                  canCheckout: !hasStockIssue,
                  onCheckout: hasStockIssue
                      ? null
                      : () async {
                          Navigator.of(context).pop();
                          await startCheckout(hostContext);
                        },
                ),
            ],
          ),
        );
      },
    );
  }
}

class _SellerSlaHeader extends StatelessWidget {
  const _SellerSlaHeader({required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context) {
    final note = CartStore.instance.slaNoteForSeller(sellerId);
    if (note == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        note,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _CartItemTile extends StatelessWidget {
  const _CartItemTile({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final product = item.product;
    final outOfStock = !product.inStock;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: outOfStock ? Colors.red.shade200 : Colors.grey.shade200,
        ),
        color: outOfStock ? Colors.red.shade50.withValues(alpha: 0.3) : null,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              openProductDetail(context, product);
            },
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.network(
                product.image,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 72,
                    height: 72,
                    color: Colors.grey.shade200,
                  );
                },
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            product.brand ?? product.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            '${product.condition}${product.size.isNotEmpty ? ' · ${product.size}' : ''}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          if (outOfStock)
                            Text(
                              t.outOfStock,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.red.shade700,
                              ),
                            ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        CartStore.instance.remove(product.id);
                      },
                      icon: Icon(
                        Icons.delete_outline,
                        size: 20,
                        color: AppColors.textPrimary,
                      ),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _QuantityButton(
                      icon: Icons.remove,
                      onTap: outOfStock
                          ? null
                          : () => CartStore.instance.updateQuantity(
                                product.id,
                                item.quantity - 1,
                              ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Text(
                        '${item.quantity}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    _QuantityButton(
                      icon: Icons.add,
                      onTap: outOfStock
                          ? null
                          : () => CartStore.instance.updateQuantity(
                                product.id,
                                item.quantity + 1,
                              ),
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${formatPrice(product.price * item.quantity)} GNF',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuantityButton extends StatelessWidget {
  const _QuantityButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 16,
          color: onTap == null ? Colors.grey.shade300 : null,
        ),
      ),
    );
  }
}

class _CartSummary extends StatelessWidget {
  const _CartSummary({
    required this.subtotal,
    required this.shipping,
    required this.total,
    required this.canCheckout,
    required this.onCheckout,
  });

  final int subtotal;
  final int shipping;
  final int total;
  final bool canCheckout;
  final VoidCallback? onCheckout;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        12 + MediaQuery.paddingOf(context).bottom,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Column(
        children: [
          _SummaryRow(
            label: t.subtotal,
            value: '${formatPrice(subtotal)} GNF',
          ),
          const SizedBox(height: 6),
          _SummaryRow(
            label: t.estimatedDeliveryFees,
            value: '${formatPrice(shipping)} GNF',
          ),
          const SizedBox(height: 8),
          _SummaryRow(
            label: t.total,
            value: '${formatPrice(total)} GNF',
            bold: true,
            valueColor: AppColors.primary,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: onCheckout,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    t.placeOrder,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.arrow_forward, size: 18),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool bold;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: bold ? 16 : 14,
      fontWeight: bold ? FontWeight.w700 : FontWeight.w500,
      color: valueColor ?? AppColors.textPrimary,
    );

    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textPrimary,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
        const Spacer(),
        Text(value, style: style),
      ],
    );
  }
}
