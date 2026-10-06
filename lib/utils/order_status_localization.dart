import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/order_status.dart';

extension OrderStatusLocalization on OrderStatus {
  String localizedLabel(AppLocalizations t) => switch (this) {
        OrderStatus.ordered => t.orderStatusOrdered,
        OrderStatus.paid => t.orderStatusPaid,
        OrderStatus.sellerNotified => t.orderStatusSellerNotified,
        OrderStatus.preparing => t.orderStatusPreparing,
        OrderStatus.readyForPickup => t.orderStatusReadyForPickup,
        OrderStatus.courierAssigned => t.orderStatusCourierAssigned,
        OrderStatus.collected => t.orderStatusCollected,
        OrderStatus.inTransit => t.orderStatusInTransit,
        OrderStatus.delivered => t.orderStatusDelivered,
        OrderStatus.fundsReleased => t.orderStatusFundsReleased,
        OrderStatus.feedbackPending => t.orderStatusFeedbackPending,
        OrderStatus.disputed => t.orderStatusDisputed,
        OrderStatus.refunded => t.orderStatusRefunded,
      };
}
