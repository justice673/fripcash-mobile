import 'package:flutter/material.dart';
import 'package:frip_cash/api/checkout_api.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/models/fulfillment_mode.dart';
import 'package:frip_cash/screens/orange_money_payment_screen.dart';
import 'package:frip_cash/services/cart_store.dart';
import 'package:frip_cash/services/checkout_store.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class CheckoutSummaryScreen extends StatefulWidget {
  const CheckoutSummaryScreen({super.key});

  @override
  State<CheckoutSummaryScreen> createState() => _CheckoutSummaryScreenState();
}

class _CheckoutSummaryScreenState extends State<CheckoutSummaryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CheckoutStore.instance.refreshQuote();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cart = CartStore.instance;
    final checkout = CheckoutStore.instance;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.summaryTitle,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: ListenableBuilder(
        listenable: Listenable.merge([checkout, cart]),
        builder: (context, _) {
          final quote = checkout.quote;
          final groups = quote != null && quote.sellerGroups.isNotEmpty
              ? null
              : cart.groupedBySeller;
          final canPay = quote != null &&
              quote.canPay &&
              !checkout.quoting &&
              !cart.hasUnavailableItems;

          return Column(
            children: [
              Expanded(
                child: checkout.quoting && quote == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        children: [
                          if (quote != null && quote.sellerGroups.isNotEmpty)
                            for (final group in quote.sellerGroups) ...[
                              _QuoteSellerHeader(
                                sellerName: group.sellerName,
                                deliveryFeeGnf: group.deliveryFeeGnf,
                                isProximity: checkout.isProximityCheckout,
                              ),
                              ...group.lines.map(
                                (line) => _QuoteSummaryLine(line: line),
                              ),
                              const SizedBox(height: 12),
                            ]
                          else if (groups != null)
                            for (final group in groups) ...[
                              _SellerGroupHeader(sellerId: group.sellerId),
                              ...group.items
                                  .map((item) => _SummaryLine(item: item)),
                              const SizedBox(height: 12),
                            ],
                          if (checkout.isProximityCheckout) ...[
                            Container(
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(12),
                                border:
                                    Border.all(color: Colors.grey.shade200),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    checkout.fulfillmentMode ==
                                            FulfillmentMode.pickup
                                        ? Icons.storefront_outlined
                                        : Icons.moped_outlined,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      checkout.fulfillmentMode ==
                                              FulfillmentMode.pickup
                                          ? t.fulfillmentPickup
                                          : t.fulfillmentShopLocal,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                          ],
                          if (quote != null && quote.blocks.isNotEmpty)
                            Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(14),
                              decoration: BoxDecoration(
                                color: Colors.red.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                quote.blocks.contains('MIXED_PROXIMITY_COURIER')
                                    ? t.mixedCartBlocked
                                    : t.removeOutOfStockToContinue,
                                style: TextStyle(
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.primary.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified_user_outlined,
                                  color: AppColors.primary,
                                  size: 20,
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    t.buyerProtectionIncluded,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
              Container(
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
                    _TotalRow(
                      label: t.subtotal,
                      value: '${formatPrice(checkout.subtotalOrZero)} GNF',
                    ),
                    const SizedBox(height: 6),
                    _TotalRow(
                      label: t.deliveryFees,
                      value: checkout.isProximityCheckout ||
                              checkout.fulfillmentMode.skipsCourier ||
                              checkout.deliveryFeeOrZero == 0
                          ? t.freeDeliveryLabel
                          : '${formatPrice(checkout.deliveryFeeOrZero)} GNF',
                    ),
                    const SizedBox(height: 8),
                    _TotalRow(
                      label: t.total,
                      value: '${formatPrice(checkout.grandTotalOrZero)} GNF',
                      bold: true,
                      valueColor: AppColors.primary,
                    ),
                    const SizedBox(height: 14),
                    PillPrimaryButton(
                      label: t.payWithOrangeMoney,
                      onPressed: canPay
                          ? () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) =>
                                      const OrangeMoneyPaymentScreen(),
                                ),
                              );
                            }
                          : null,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _QuoteSellerHeader extends StatelessWidget {
  const _QuoteSellerHeader({
    required this.sellerName,
    required this.deliveryFeeGnf,
    required this.isProximity,
  });

  final String sellerName;
  final int deliveryFeeGnf;
  final bool isProximity;

  @override
  Widget build(BuildContext context) {
    final feeLabel = isProximity || deliveryFeeGnf == 0
        ? null
        : '${formatPrice(deliveryFeeGnf)} GNF';
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        feeLabel == null ? sellerName : '$sellerName · $feeLabel',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _QuoteSummaryLine extends StatelessWidget {
  const _QuoteSummaryLine({required this.line});

  final QuoteLine line;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cover = line.coverUrl;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: cover != null && cover.isNotEmpty
                ? Image.network(
                    cover,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 48,
                        height: 48,
                        color: Colors.grey.shade200,
                      );
                    },
                  )
                : Container(
                    width: 48,
                    height: 48,
                    color: Colors.grey.shade200,
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${t.qtyShort} ${line.qty} · ${formatPrice(line.unitDisplayPriceGnf)} GNF',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Text(
            '${formatPrice(line.lineTotalGnf)} GNF',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SellerGroupHeader extends StatelessWidget {
  const _SellerGroupHeader({required this.sellerId});

  final String sellerId;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final seller = sellersById[sellerId] ?? defaultSeller;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        '${seller.username} · ${t.deliverWithin} ${seller.deliverySla}',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }
}

class _SummaryLine extends StatelessWidget {
  const _SummaryLine({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final product = item.product;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.network(
              product.image,
              width: 48,
              height: 48,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 48,
                  height: 48,
                  color: Colors.grey.shade200,
                );
              },
            ),
          ),
          const SizedBox(width: 10),
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
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${t.qtyShort} ${item.quantity} · ${formatPrice(product.price)} GNF',
                  style: TextStyle(fontSize: 12, color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          Text(
            '${formatPrice(product.price * item.quantity)} GNF',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  const _TotalRow({
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
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: bold ? 15 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w400,
            color: AppColors.textPrimary,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: TextStyle(
            fontSize: bold ? 17 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
            color: valueColor ?? AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
