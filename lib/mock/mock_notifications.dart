import 'package:frip_cash/l10n/app_localizations.dart';

class MockNotification {
  const MockNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.timeLabel,
    this.isRead = false,
    this.orderId,
  });

  final String id;
  final String title;
  final String body;
  final String timeLabel;
  final bool isRead;
  final String? orderId;
}

List<MockNotification> buildInitialMockNotifications(AppLocalizations t) => [
      MockNotification(
        id: 'notif_1',
        title: t.orderConfirmedTitle,
        body: t.notifStayReachableBody,
        timeLabel: t.notifHoursAgo(2),
        orderId: 'ord_1001',
      ),
      MockNotification(
        id: 'notif_2',
        title: t.notifNewOrderReceivedTitle,
        body: t.notifPrepareParcelBody,
        timeLabel: t.notifHoursAgo(5),
        orderId: 'ord_1002',
        isRead: true,
      ),
      MockNotification(
        id: 'notif_3',
        title: t.notifOrderDeliveredTitle,
        body: t.notifRateSellerBody,
        timeLabel: t.notifYesterday,
        orderId: 'ord_1003',
        isRead: true,
      ),
      MockNotification(
        id: 'notif_4',
        title: t.notifPackageReadyTitle,
        body: t.notifPickupParcelOrderBody('ord_1002'),
        timeLabel: t.notifHoursAgo(3),
        orderId: 'ord_1002',
      ),
      MockNotification(
        id: 'notif_5',
        title: t.notifSlaReminderLateTitle,
        body: t.notifSlaReminderLateBody('ord_1002', '24h'),
        timeLabel: t.notifHoursAgo(1),
        orderId: 'ord_1002',
      ),
    ];
