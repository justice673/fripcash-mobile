import 'package:flutter/foundation.dart';
import 'package:frip_cash/mock/mock_notifications.dart';
import 'package:frip_cash/mock/mock_offers.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/mock/mock_orders.dart';
import 'package:frip_cash/utils/app_localizations_lookup.dart';
import 'package:frip_cash/utils/order_status_localization.dart';

class MockNotificationService extends ChangeNotifier {
  MockNotificationService._();

  static final MockNotificationService instance = MockNotificationService._();

  final List<MockNotification> _items = [];

  List<MockNotification> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((n) => !n.isRead).length;

  void markRead(String id) {
    final index = _items.indexWhere((n) => n.id == id);
    if (index == -1) return;
    final current = _items[index];
    _items[index] = MockNotification(
      id: current.id,
      title: current.title,
      body: current.body,
      timeLabel: current.timeLabel,
      isRead: true,
      orderId: current.orderId,
    );
    notifyListeners();
  }

  void markAllRead() {
    for (var i = 0; i < _items.length; i++) {
      final n = _items[i];
      if (!n.isRead) {
        _items[i] = MockNotification(
          id: n.id,
          title: n.title,
          body: n.body,
          timeLabel: n.timeLabel,
          isRead: true,
          orderId: n.orderId,
        );
      }
    }
    notifyListeners();
  }

  void notifyStatusChange(MockOrder order, OrderStatus status) {
    final t = currentAppLocalizations();
    final title = switch (status) {
      OrderStatus.paid => t.orderConfirmedTitle,
      OrderStatus.readyForPickup => t.notifPackageReadyTitle,
      OrderStatus.delivered => t.notifOrderDeliveredTitle,
      OrderStatus.fundsReleased => t.notifFundsReleasedTitle,
      OrderStatus.feedbackPending => t.notifGiveFeedbackTitle,
      OrderStatus.disputed => t.notifDisputeOpenedTitle,
      OrderStatus.refunded => t.notifRefundIssuedTitle,
      _ => t.notifOrderUpdateTitle,
    };

    final body = switch (status) {
      OrderStatus.paid => t.notifStayReachableBody,
      OrderStatus.readyForPickup => t.notifCourierCanPickupBody,
      OrderStatus.delivered => t.notifRateSellerBody,
      OrderStatus.fundsReleased => t.notifFundsCreditedBody,
      OrderStatus.feedbackPending => t.notifHowWasExperienceBody,
      OrderStatus.disputed => t.notifDisputeOpenedBody,
      OrderStatus.refunded => t.notifRefundIssuedBody,
      _ => order.status.localizedLabel(t),
    };

    _items.insert(
      0,
      MockNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: title,
        body: body,
        timeLabel: t.notifJustNow,
        orderId: order.id,
      ),
    );
    notifyListeners();
  }

  void notifyOfferResponse({
    required ProductOffer offer,
    required bool accepted,
  }) {
    final t = currentAppLocalizations();
    _items.insert(
      0,
      MockNotification(
        id: 'notif_${DateTime.now().millisecondsSinceEpoch}',
        title: accepted ? t.notifOfferAcceptedTitle : t.notifOfferRefusedTitle,
        body: accepted
            ? t.notifOfferAcceptedBody(
                offer.productTitle,
                offer.offeredPrice.toString(),
              )
            : t.notifOfferRefusedBody(offer.productTitle),
        timeLabel: t.notifJustNow,
      ),
    );
    notifyListeners();
  }
}
