import 'package:flutter/material.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_orders.dart';
import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/mock/mock_shops.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/screens/main_shell.dart';
import 'package:frip_cash/screens/order_detail_screen.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/pickup_code_digits.dart';
import 'package:frip_cash/widgets/pill_button.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

/// Buyer screen after Orange Money pay for a neighborhood shop — in-store pickup.
class ProximityPickupScreen extends StatelessWidget {
  const ProximityPickupScreen({super.key, required this.order});

  final MockOrder order;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final code = order.pickupCode ?? '----';
    final shop = shopBySellerId(order.sellerId);
    final seller = sellersById[order.sellerId];
    final products = productsForOrder(order, ListingsRepository.instance.allCached);
    final shopName = shop?.name ?? seller?.username ?? t.shopRole;
    final address = shop?.addressLine ?? seller?.zone ?? '';
    final phone = seller?.phone;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(builder: (_) => const MainShell()),
              (_) => false,
            );
          },
        ),
        title: Text(
          t.pickupInStoreTitle,
          style: AppTypography.display(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(18, 20, 18, 18),
              decoration: BoxDecoration(
                color: AppColors.rosePoudre,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                children: [
                  Text(
                    t.pickupCodeLabel,
                    style: AppTypography.style(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  PickupCodeDigits(code: code),
                  const SizedBox(height: 12),
                  Text(
                    t.pickupOrderPaidLine(order.id),
                    textAlign: TextAlign.center,
                    style: AppTypography.style(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      onPressed: () => sharePickupCode(context, code),
                      style: FilledButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: AppColors.textPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        t.sharePickupCode,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      SafeNetworkImage(
                        url: shop?.logoUrl ??
                            seller?.avatarUrl ??
                            'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=200&h=200&fit=crop',
                        width: 52,
                        height: 52,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              shopName,
                              style: AppTypography.style(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (address.isNotEmpty)
                              Text(
                                address,
                                style: AppTypography.style(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  if (phone != null && phone.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    const Divider(height: 1),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(
                          Icons.phone_outlined,
                          size: 18,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            phone,
                            style: AppTypography.style(fontSize: 14),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('${t.callAction}: $phone'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          child: Text(
                            t.callAction,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 22),
            Text(
              t.yourOrderTitle,
              style: AppTypography.style(
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  for (final product in products) ...[
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          SafeNetworkImage(
                            url: product.image,
                            width: 40,
                            height: 40,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              product.title,
                              style: AppTypography.style(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Text(
                            'x1',
                            style: AppTypography.style(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            formatPrice(product.price),
                            style: AppTypography.style(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const Divider(height: 20),
                  Row(
                    children: [
                      Text(
                        t.paidViaOrangeMoney,
                        style: AppTypography.style(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${formatPrice(order.totalGnf)} GNF',
                        style: AppTypography.style(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.sage.withValues(alpha: 0.14),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.key_rounded, color: AppColors.gold, size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.pickupAnyoneTitle,
                          style: AppTypography.style(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.pickupAnyoneBody,
                          style: AppTypography.style(
                            fontSize: 13,
                            height: 1.35,
                            color: AppColors.textPrimary.withValues(alpha: 0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PillPrimaryButton(
              label: t.backToHome,
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const MainShell()),
                  (_) => false,
                );
              },
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => OrderDetailScreen(orderId: order.id),
                  ),
                );
              },
              child: Text(t.trackMyOrder),
            ),
          ],
        ),
      ),
    );
  }
}
