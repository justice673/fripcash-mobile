import 'package:flutter/foundation.dart';
import 'package:frip_cash/mock/mock_orders.dart';
import 'package:frip_cash/mock/mock_zones.dart';
import 'package:frip_cash/models/courier_earnings_week.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/services/mock_order_service.dart';
import 'package:frip_cash/utils/date_label_localization.dart';

/// Local courier helpers for UI that still need zone labels / order filters.
/// Mission mutations and invented earnings live in [CourierRepository] (API only).
class MockCourierService extends ChangeNotifier {
  MockCourierService._();

  static final MockCourierService instance = MockCourierService._();

  bool _isAvailable = true;

  bool get isAvailable => _isAvailable;

  void setAvailability(bool value) {
    _isAvailable = value;
    notifyListeners();
  }

  String zoneLabel(String zoneId) => zoneById(zoneId)?.name ?? zoneId;

  List<MockOrder> activeMissions({
    required String courierId,
    required String courierZoneId,
  }) {
    return MockOrderService.instance.orders.where((order) {
      if (!order.isActiveCourierMission) return false;
      final assigned = order.courierId;
      if (assigned != null) return assigned == courierId;
      if (!_isAvailable) return false;
      return order.buyerZoneId == courierZoneId;
    }).toList()
      ..sort((a, b) => a.status.index.compareTo(b.status.index));
  }

  List<MockOrder> completedMissions(String courierId) {
    return MockOrderService.instance.orders
        .where((order) =>
            order.courierId == courierId &&
            order.status.index >= OrderStatus.delivered.index)
        .toList();
  }

  int todayEarningsGnf(String courierId) {
    return MockOrderService.instance.orders
        .where((order) =>
            order.courierId == courierId &&
            order.status.index >= OrderStatus.delivered.index &&
            isTodayDateLabel(order.createdAtLabel))
        .fold<int>(0, (sum, order) => sum + order.deliveryFeeGnf);
  }

  int thisWeekEarningsGnf(String courierId) {
    return completedMissions(courierId)
        .fold<int>(0, (sum, order) => sum + order.deliveryFeeGnf);
  }

  int courierWalletBalanceGnf(String courierId) => 0;

  List<CourierEarningsWeek> weeklyEarningsHistory(
    String courierId, {
    required String currentWeekLabel,
    required String week1Label,
    required String week2Label,
    required String week3Label,
    required String week4Label,
    required String week5Label,
  }) {
    final thisWeek = thisWeekEarningsGnf(courierId);
    return [
      CourierEarningsWeek(
        label: currentWeekLabel,
        amountGnf: thisWeek,
        highlighted: true,
      ),
    ];
  }
}
