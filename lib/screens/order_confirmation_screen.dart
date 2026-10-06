import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/fulfillment_mode.dart';
import 'package:frip_cash/screens/main_shell.dart';
import 'package:frip_cash/services/mock_order_service.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/widgets/pill_button.dart';

class OrderConfirmationScreen extends StatelessWidget {
  const OrderConfirmationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final order = MockOrderService.instance.lastCreatedOrder;
    final isProximity = order?.isProximityFulfillment == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  size: 44,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                t.orderConfirmedTitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                isProximity
                    ? t.orderConfirmedProximitySubtitle
                    : t.orderConfirmedSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  height: 1.45,
                ),
              ),
              if (order != null) ...[
                const SizedBox(height: 28),
                if (order.pickupCode != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.35),
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          t.pickupCodeLabel,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.pickupCode!,
                          style: const TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 4,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.fulfillmentMode == FulfillmentMode.pickup
                              ? t.pickupCodeHintPickup
                              : t.pickupCodeHintDelivery,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.orderNumberLabel(order.id),
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        t.orderItemsSummary(
                          order.productIds.length,
                          formatPrice(order.totalGnf),
                        ),
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isProximity
                            ? (order.fulfillmentMode == FulfillmentMode.pickup
                                ? t.fulfillmentPickup
                                : t.fulfillmentShopLocal)
                            : t.estimatedDelivery24to48h,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const Spacer(),
              PillPrimaryButton(
                label: t.backToHome,
                onPressed: () {
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute<void>(builder: (_) => const MainShell()),
                    (_) => false,
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(t.orderTrackingSoon),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
                child: Text(t.trackMyOrder),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
