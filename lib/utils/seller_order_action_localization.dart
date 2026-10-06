import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/services/mock_order_service.dart';

extension SellerOrderActionLabel on SellerOrderAction {
  String localizedLabel(AppLocalizations t, {required bool isProximity}) {
    return switch (kind) {
      SellerOrderActionKind.startPreparing => t.startPreparing,
      SellerOrderActionKind.markReadyForPickup =>
        isProximity ? t.orderReadyForHandoff : t.parcelReady,
      SellerOrderActionKind.confirmHandoff => t.confirmHandoff,
    };
  }

  String localizedSuccessMessage(AppLocalizations t, {required bool isProximity}) {
    return switch (kind) {
      SellerOrderActionKind.startPreparing => t.sellerActionStartedPreparing,
      SellerOrderActionKind.markReadyForPickup => isProximity
          ? t.orderMarkedReadyProximity
          : t.parcelMarkedReady,
      SellerOrderActionKind.confirmHandoff => t.handoffConfirmed,
    };
  }
}
