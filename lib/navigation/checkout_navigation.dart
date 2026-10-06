import 'package:flutter/material.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/fulfillment_mode.dart';
import 'package:frip_cash/screens/checkout_address_screen.dart';
import 'package:frip_cash/services/cart_store.dart';
import 'package:frip_cash/services/checkout_store.dart';
import 'package:frip_cash/theme/app_colors.dart';

Future<void> startCheckout(BuildContext context) async {
  final t = AppLocalizations.of(context)!;
  final checkout = CheckoutStore.instance;
  final cart = CartStore.instance;

  try {
    final validation = await cart.validate();
    if (!context.mounted) return;

    if (!validation.ok) {
      final mixed = validation.issues.any(
        (i) => i.code == 'MIXED_PROXIMITY_COURIER',
      );
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            mixed ? t.mixedCartBlocked : t.removeOutOfStockToContinue,
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.textPrimary,
        ),
      );
      return;
    }
  } on ApiException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
    return;
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.toString()),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
    return;
  }

  if (!context.mounted) return;

  if (checkout.hasMixedProximityCourierCart) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.mixedCartBlocked),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.textPrimary,
      ),
    );
    return;
  }

  if (checkout.isProximityCheckout) {
    checkout.setFulfillmentMode(FulfillmentMode.pickup);
  } else {
    checkout.setFulfillmentMode(FulfillmentMode.courier);
  }

  await Navigator.of(context).push(
    MaterialPageRoute<void>(builder: (_) => const CheckoutAddressScreen()),
  );
}
