import 'package:flutter/foundation.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/orders_api.dart';
import 'package:frip_cash/mock/mock_orders.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/models/order_status.dart';
import 'package:frip_cash/services/mock_notification_service.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/utils/seller_access.dart';

enum SellerOrderActionKind {
  startPreparing,
  markReadyForPickup,
  confirmHandoff,
}

class SellerOrderAction {
  const SellerOrderAction({
    required this.kind,
    required this.targetStatus,
  });

  final SellerOrderActionKind kind;
  final OrderStatus targetStatus;
}

class MockOrderService extends ChangeNotifier {
  MockOrderService._();

  static final MockOrderService instance = MockOrderService._();

  final List<MockOrder> _orders = [];
  MockOrder? lastCreatedOrder;
  bool _usingApi = false;
  bool _syncing = false;
  String? _error;

  bool get usingApi => _usingApi;
  bool get syncing => _syncing;
  String? get error => _error;

  List<MockOrder> get orders => List.unmodifiable(_orders);

  List<MockOrder> ordersForBuyer(MockUser user) {
    return _orders.where((order) => order.buyerId == user.id).toList();
  }

  List<MockOrder> ordersForSeller(String sellerId) {
    return _orders.where((order) => order.sellerId == sellerId).toList();
  }

  MockOrder? orderById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  List<MockOrder> ordersForBuyerName(String buyerName) {
    return _orders
        .where((order) => order.buyerName == buyerName)
        .toList();
  }

  void _upsert(MockOrder order) {
    final index = _orders.indexWhere((o) => o.id == order.id);
    if (index == -1) {
      _orders.insert(0, order);
    } else {
      _orders[index] = order;
    }
  }

  /// Local paid order after client-side payment simulation (no PSP).
  void rememberLocalPaidOrder(MockOrder order) {
    lastCreatedOrder = order;
    _upsert(order);
    notifyListeners();
  }

  void _replaceAllFromApi(List<ApiOrder> apiOrders, {required String as}) {
    final mapped = apiOrders.map(MockOrder.fromApi).toList();
    if (as == 'buyer') {
      final buyerId = MockSession.instance.user.id;
      _orders.removeWhere((o) => o.buyerId == buyerId);
    } else if (as == 'seller') {
      final sellerId = effectiveSellerId();
      _orders.removeWhere((o) => o.sellerId == sellerId);
    }
    for (final o in mapped) {
      _upsert(o);
    }
  }

  /// GET /orders?as=buyer — keeps previous server state on failure.
  Future<void> refreshBuyerOrders({String? filter, String? q}) async {
    _syncing = true;
    _error = null;
    notifyListeners();
    try {
      final page = await OrdersApi.instance.listPurchases(
        filter: filter,
        q: q,
      );
      _usingApi = true;
      if (filter == null || filter.isEmpty || filter == 'all') {
        _replaceAllFromApi(page.items, as: 'buyer');
      } else {
        for (final o in page.items) {
          _upsert(MockOrder.fromApi(o));
        }
      }
    } catch (e) {
      _error = e.toString();
      // Keep previous server state; do not invent orders.
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  /// GET /orders?as=seller
  Future<void> refreshSellerOrders({String? filter, String? q}) async {
    _syncing = true;
    _error = null;
    notifyListeners();
    try {
      final page = await OrdersApi.instance.listSales(
        filter: filter,
        q: q,
      );
      _usingApi = true;
      if (filter == null || filter.isEmpty || filter == 'all') {
        _replaceAllFromApi(page.items, as: 'seller');
      } else {
        for (final o in page.items) {
          _upsert(MockOrder.fromApi(o));
        }
      }
    } catch (e) {
      _error = e.toString();
      // Keep previous server state; do not invent orders.
    } finally {
      _syncing = false;
      notifyListeners();
    }
  }

  /// GET /orders/:id — returns null on failure (keeps previous local cache).
  Future<MockOrder?> refreshOrder(String id) async {
    try {
      final api = await OrdersApi.instance.getOrder(id);
      _usingApi = true;
      _error = null;
      final mapped = MockOrder.fromApi(api);
      _upsert(mapped);
      notifyListeners();
      return mapped;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return null;
    }
  }

  /// Whether the seller still has a fulfillment step to take.
  static bool orderNeedsSellerAction(MockOrder order) {
    if (order.nextActions.isNotEmpty) {
      return order.hasNextAction(OrderNextAction.startPreparing) ||
          order.hasNextAction(OrderNextAction.markReadyForPickup) ||
          order.hasNextAction(OrderNextAction.confirmHandoff) ||
          order.hasNextAction(OrderNextAction.sellerRefund) ||
          order.hasNextAction(OrderNextAction.openDispute);
    }
    if (order.status.isTerminalException || order.status.isPaymentReleased) {
      return false;
    }
    if (order.status.isDisputed) return true;
    return nextSellerAction(order) != null ||
        (order.status.index >= OrderStatus.readyForPickup.index &&
            order.status.index < OrderStatus.delivered.index &&
            !order.status.isPaymentReleased);
  }

  static bool orderAwaitingBuyerConfirmation(MockOrder order) {
    if (order.hasNextAction(OrderNextAction.confirmReceipt)) return true;
    return !order.status.isTerminalException &&
        !order.status.isPaymentReleased &&
        order.status.index >= OrderStatus.delivered.index;
  }

  /// Prefer server `nextActions`; fall back to local status machine for UI.
  static SellerOrderAction? nextSellerAction(MockOrder order) {
    if (order.nextActions.isNotEmpty) {
      if (order.hasNextAction(OrderNextAction.startPreparing)) {
        return const SellerOrderAction(
          kind: SellerOrderActionKind.startPreparing,
          targetStatus: OrderStatus.preparing,
        );
      }
      if (order.hasNextAction(OrderNextAction.markReadyForPickup)) {
        return const SellerOrderAction(
          kind: SellerOrderActionKind.markReadyForPickup,
          targetStatus: OrderStatus.readyForPickup,
        );
      }
      if (order.hasNextAction(OrderNextAction.confirmHandoff)) {
        return const SellerOrderAction(
          kind: SellerOrderActionKind.confirmHandoff,
          targetStatus: OrderStatus.delivered,
        );
      }
      return null;
    }

    if (order.status.isTerminalException || order.status.isPaymentReleased) {
      return null;
    }
    switch (order.status) {
      case OrderStatus.paid:
      case OrderStatus.sellerNotified:
        return const SellerOrderAction(
          kind: SellerOrderActionKind.startPreparing,
          targetStatus: OrderStatus.preparing,
        );
      case OrderStatus.preparing:
        return const SellerOrderAction(
          kind: SellerOrderActionKind.markReadyForPickup,
          targetStatus: OrderStatus.readyForPickup,
        );
      case OrderStatus.readyForPickup:
        if (order.isProximityFulfillment) {
          return const SellerOrderAction(
            kind: SellerOrderActionKind.confirmHandoff,
            targetStatus: OrderStatus.delivered,
          );
        }
        return null;
      default:
        return null;
    }
  }

  static bool canConfirmReceipt(MockOrder order) {
    if (order.hasNextAction(OrderNextAction.confirmReceipt)) return true;
    // Policy A (handoff): only from DELIVERED.
    return !order.status.isDisputed &&
        !order.status.isPaymentReleased &&
        order.status == OrderStatus.delivered;
  }

  static bool canOpenDispute(MockOrder order) {
    if (order.hasNextAction(OrderNextAction.openDispute)) return true;
    return !order.status.isTerminalException && !order.status.isPaymentReleased;
  }

  static bool canRateSeller(MockOrder order) {
    if (order.hasNextAction(OrderNextAction.rateSeller)) return true;
    return order.status.isPaymentReleased && order.ratingStars == null;
  }

  /// Seller CTA — API only. Returns false on failure (no local status mutation).
  Future<bool> applySellerAction(
    String orderId, {
    String? pickupCode,
  }) async {
    final order = orderById(orderId);
    if (order == null) return false;
    final action = nextSellerAction(order);
    if (action == null) return false;

    try {
      final ApiOrder api;
      switch (action.kind) {
        case SellerOrderActionKind.startPreparing:
          api = await OrdersApi.instance.prepare(orderId);
        case SellerOrderActionKind.markReadyForPickup:
          api = await OrdersApi.instance.markReady(orderId);
        case SellerOrderActionKind.confirmHandoff:
          final code = (pickupCode ?? '').trim();
          if (code.isEmpty) return false;
          api = await OrdersApi.instance.confirmHandoff(
            orderId,
            pickupCode: code,
          );
      }
      _usingApi = true;
      _error = null;
      _upsert(MockOrder.fromApi(api));
      MockNotificationService.instance.notifyStatusChange(
        orderById(orderId)!,
        orderById(orderId)!.status,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markDeliveredAsync(String orderId, {String? proofPhotoUrl}) async {
    try {
      final api = await OrdersApi.instance.markDelivered(
        orderId,
        proofPhotoUrl: proofPhotoUrl,
      );
      _usingApi = true;
      _error = null;
      _upsert(MockOrder.fromApi(api));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Buyer confirms the package is in hand → release escrow to seller.
  /// Policy A: only from `DELIVERED`. API only — no local mock mutation.
  Future<ConfirmReceiptResult> confirmReceipt(String orderId) async {
    final order = orderById(orderId);
    if (order == null) {
      return const ConfirmReceiptResult(
        ok: false,
        messageKey: ConfirmReceiptMessage.notFound,
      );
    }

    try {
      final result = await OrdersApi.instance.confirmReceipt(orderId);
      _usingApi = true;
      _error = null;
      var mapped = MockOrder.fromApi(result.order);
      if (result.escrowState != null) {
        mapped = mapped.copyWith(escrowState: result.escrowState);
      }
      _upsert(mapped);
      MockNotificationService.instance.notifyStatusChange(
        mapped,
        mapped.status,
      );
      notifyListeners();
      return const ConfirmReceiptResult(
        ok: true,
        messageKey: ConfirmReceiptMessage.released,
      );
    } on ApiException catch (e) {
      _error = e.toString();
      notifyListeners();
      final code = e.code.toUpperCase();
      if (code == 'DISPUTE_LOCKED') {
        return const ConfirmReceiptResult(
          ok: false,
          messageKey: ConfirmReceiptMessage.disputeLocked,
        );
      }
      if (code == 'ALREADY_RELEASED') {
        return const ConfirmReceiptResult(
          ok: false,
          messageKey: ConfirmReceiptMessage.alreadyConfirmed,
        );
      }
      if (code == 'INVALID_STATUS') {
        return const ConfirmReceiptResult(
          ok: false,
          messageKey: ConfirmReceiptMessage.notReady,
        );
      }
      return const ConfirmReceiptResult(
        ok: false,
        messageKey: ConfirmReceiptMessage.notFound,
      );
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return const ConfirmReceiptResult(
        ok: false,
        messageKey: ConfirmReceiptMessage.notFound,
      );
    }
  }

  /// Buyer (or seller) opens a dispute — payment stays locked for admin review.
  Future<bool> openDispute(
    String orderId, {
    String? reason,
    String openedVia = 'order_page',
    String role = 'buyer',
    String? reasonCode,
  }) async {
    final trimmed = reason?.trim() ?? '';
    if (trimmed.isEmpty) return false;

    try {
      final api = await OrdersApi.instance.openDispute(
        orderId,
        role: role,
        reason: trimmed,
        reasonCode: reasonCode,
        openedVia: openedVia,
      );
      _usingApi = true;
      _error = null;
      _upsert(MockOrder.fromApi(api));
      MockNotificationService.instance.notifyStatusChange(
        orderById(orderId)!,
        OrderStatus.disputed,
      );
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Persist buyer rating after funds released. API only.
  Future<bool> rateOrder(
    String orderId, {
    required int stars,
    String? comment,
  }) async {
    if (stars < 1 || stars > 5) return false;

    try {
      final api = await OrdersApi.instance.rateOrder(
        orderId,
        stars: stars,
        comment: comment,
      );
      _usingApi = true;
      _error = null;
      _upsert(MockOrder.fromApi(api));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> sellerRefund(String orderId, {int? amountGnf}) async {
    try {
      final api = await OrdersApi.instance.sellerRefund(
        orderId,
        amountGnf: amountGnf,
      );
      _usingApi = true;
      _error = null;
      _upsert(MockOrder.fromApi(api));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markCollectedAsync(String orderId) async {
    try {
      final api = await OrdersApi.instance.markCollected(orderId);
      _usingApi = true;
      _error = null;
      _upsert(MockOrder.fromApi(api));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> markInTransitAsync(String orderId) async {
    try {
      final api = await OrdersApi.instance.markInTransit(orderId);
      _usingApi = true;
      _error = null;
      _upsert(MockOrder.fromApi(api));
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Merge paid orders from checkout payment (API) into the local list.
  void ingestApiOrders(Iterable<ApiOrder> orders) {
    _usingApi = true;
    _error = null;
    for (final o in orders) {
      _upsert(MockOrder.fromApi(o));
    }
    if (orders.isNotEmpty) {
      lastCreatedOrder = MockOrder.fromApi(orders.first);
    }
    notifyListeners();
  }
}

enum ConfirmReceiptMessage {
  notFound,
  alreadyConfirmed,
  notReady,
  released,
  disputeLocked,
}

class ConfirmReceiptResult {
  const ConfirmReceiptResult({
    required this.ok,
    required this.messageKey,
  });

  final bool ok;
  final ConfirmReceiptMessage messageKey;
}
