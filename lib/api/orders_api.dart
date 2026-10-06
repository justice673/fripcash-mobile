import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/checkout_api.dart' show fulfillmentModeFromApi;
import 'package:frip_cash/models/fulfillment_mode.dart';
import 'package:frip_cash/models/order_status.dart';

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse('$v') ?? 0;
}

double? _doubleOrNull(dynamic v) {
  if (v == null) return null;
  if (v is double) return v;
  if (v is num) return v.toDouble();
  return double.tryParse('$v');
}

/// API order status values (SCREAMING_SNAKE per Flutter handoff; camelCase tolerated).
OrderStatus orderStatusFromApi(String? raw) {
  final s = (raw ?? '').trim();
  switch (s.toUpperCase().replaceAll('-', '_')) {
    case 'ORDERED':
      return OrderStatus.ordered;
    case 'PAID':
      return OrderStatus.paid;
    case 'SELLER_NOTIFIED':
    case 'SELLERNOTIFIED':
      return OrderStatus.sellerNotified;
    case 'PREPARING':
      return OrderStatus.preparing;
    case 'READY_FOR_PICKUP':
    case 'READYFORPICKUP':
      return OrderStatus.readyForPickup;
    case 'COURIER_ASSIGNED':
    case 'COURIERASSIGNED':
      return OrderStatus.courierAssigned;
    case 'COLLECTED':
      return OrderStatus.collected;
    case 'IN_TRANSIT':
    case 'INTRANSIT':
      return OrderStatus.inTransit;
    case 'DELIVERED':
      return OrderStatus.delivered;
    case 'FUNDS_RELEASED':
    case 'FUNDSRELEASED':
      return OrderStatus.fundsReleased;
    case 'FEEDBACK_PENDING':
    case 'FEEDBACKPENDING':
      return OrderStatus.feedbackPending;
    case 'DISPUTED':
      return OrderStatus.disputed;
    case 'REFUNDED':
      return OrderStatus.refunded;
    default:
      // camelCase fallbacks
      switch (s) {
        case 'ordered':
          return OrderStatus.ordered;
        case 'paid':
          return OrderStatus.paid;
        case 'sellerNotified':
          return OrderStatus.sellerNotified;
        case 'preparing':
          return OrderStatus.preparing;
        case 'readyForPickup':
          return OrderStatus.readyForPickup;
        case 'courierAssigned':
          return OrderStatus.courierAssigned;
        case 'collected':
          return OrderStatus.collected;
        case 'inTransit':
          return OrderStatus.inTransit;
        case 'delivered':
          return OrderStatus.delivered;
        case 'fundsReleased':
          return OrderStatus.fundsReleased;
        case 'feedbackPending':
          return OrderStatus.feedbackPending;
        case 'disputed':
          return OrderStatus.disputed;
        case 'refunded':
          return OrderStatus.refunded;
        default:
          return OrderStatus.ordered;
      }
  }
}

/// CTA keys from order DTO `nextActions`.
enum OrderNextAction {
  startPreparing,
  markReadyForPickup,
  confirmHandoff,
  confirmReceipt,
  openDispute,
  rateSeller,
  sellerRefund,
}

OrderNextAction? orderNextActionFromApi(String? raw) {
  switch ((raw ?? '').trim()) {
    case 'startPreparing':
      return OrderNextAction.startPreparing;
    case 'markReadyForPickup':
      return OrderNextAction.markReadyForPickup;
    case 'confirmHandoff':
      return OrderNextAction.confirmHandoff;
    case 'confirmReceipt':
      return OrderNextAction.confirmReceipt;
    case 'openDispute':
      return OrderNextAction.openDispute;
    case 'rateSeller':
      return OrderNextAction.rateSeller;
    case 'sellerRefund':
      return OrderNextAction.sellerRefund;
    default:
      return null;
  }
}

enum EscrowState {
  held,
  locked,
  released,
  unknown,
}

EscrowState escrowStateFromApi(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'held':
      return EscrowState.held;
    case 'locked':
      return EscrowState.locked;
    case 'released':
      return EscrowState.released;
    default:
      return EscrowState.unknown;
  }
}

/// Snapshotted line — prefer [unitDisplayPriceGnf] for buyer money UI.
class ApiOrderLine {
  const ApiOrderLine({
    required this.listingId,
    required this.title,
    required this.qty,
    required this.unitDisplayPriceGnf,
    this.unitNetPriceGnf,
    this.commissionRate,
    this.coverUrl,
    this.lineTotalDisplayGnf,
  });

  final String listingId;
  final String title;
  final int qty;
  final int unitDisplayPriceGnf;
  final int? unitNetPriceGnf;
  final double? commissionRate;
  final String? coverUrl;
  final int? lineTotalDisplayGnf;

  int get displayLineTotalGnf =>
      lineTotalDisplayGnf ?? (unitDisplayPriceGnf * qty);

  factory ApiOrderLine.fromJson(Map<String, dynamic> json) {
    final qty = _int(json['qty'] ?? json['quantity'] ?? 1);
    final unitDisplay = _int(
      json['unitDisplayPriceGnf'] ??
          json['displayPriceGnf'] ??
          json['unitPriceGnf'],
    );
    return ApiOrderLine(
      listingId: (json['listingId'] ?? json['productId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      qty: qty < 1 ? 1 : qty,
      unitDisplayPriceGnf: unitDisplay,
      unitNetPriceGnf: json['unitNetPriceGnf'] != null
          ? _int(json['unitNetPriceGnf'])
          : null,
      commissionRate: _doubleOrNull(json['commissionRate']),
      coverUrl: (json['coverUrl'] ?? json['imageUrl'])?.toString(),
      lineTotalDisplayGnf: json['lineTotalDisplayGnf'] != null
          ? _int(json['lineTotalDisplayGnf'])
          : null,
    );
  }
}

class ApiOrderEscrow {
  const ApiOrderEscrow({
    required this.state,
    this.heldAmountGnf,
  });

  final EscrowState state;
  final int? heldAmountGnf;

  factory ApiOrderEscrow.fromJson(Map<String, dynamic>? json) {
    if (json == null) {
      return const ApiOrderEscrow(state: EscrowState.unknown);
    }
    return ApiOrderEscrow(
      state: escrowStateFromApi(json['state']?.toString()),
      heldAmountGnf:
          json['heldAmountGnf'] != null ? _int(json['heldAmountGnf']) : null,
    );
  }
}

class ApiOrderDispute {
  const ApiOrderDispute({
    this.id,
    this.reason,
    this.openedAt,
    this.openedVia,
  });

  final String? id;
  final String? reason;
  final String? openedAt;
  final String? openedVia;

  factory ApiOrderDispute.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const ApiOrderDispute();
    return ApiOrderDispute(
      id: json['id']?.toString(),
      reason: (json['reason'] ?? json['reasonText'])?.toString(),
      openedAt: json['openedAt']?.toString(),
      openedVia: json['openedVia']?.toString(),
    );
  }
}

class ApiOrderRating {
  const ApiOrderRating({
    required this.stars,
    this.comment,
    this.createdAt,
  });

  final int stars;
  final String? comment;
  final String? createdAt;

  factory ApiOrderRating.fromJson(Map<String, dynamic> json) {
    return ApiOrderRating(
      stars: _int(json['stars']),
      comment: json['comment']?.toString(),
      createdAt: json['createdAt']?.toString(),
    );
  }
}

class ApiOrderTimelineEvent {
  const ApiOrderTimelineEvent({
    required this.status,
    this.at,
    this.actorRole,
    this.from,
  });

  final OrderStatus status;
  final String? at;
  final String? actorRole;
  final OrderStatus? from;

  factory ApiOrderTimelineEvent.fromJson(Map<String, dynamic> json) {
    return ApiOrderTimelineEvent(
      status: orderStatusFromApi(
        (json['to'] ?? json['status'] ?? json['toStatus'])?.toString(),
      ),
      at: (json['at'] ?? json['createdAt'])?.toString(),
      actorRole: json['actorRole']?.toString(),
      from: json['from'] != null
          ? orderStatusFromApi(json['from']?.toString())
          : null,
    );
  }
}

class ApiOrder {
  const ApiOrder({
    required this.id,
    required this.status,
    required this.fulfillmentMode,
    required this.buyerUserId,
    required this.sellerProfileId,
    required this.buyerName,
    required this.buyerPhone,
    required this.buyerZoneId,
    required this.buyerAddressLine,
    required this.deliveryFeeGnf,
    required this.subtotalGnf,
    required this.totalGnf,
    required this.lines,
    required this.nextActions,
    this.paymentIntentId,
    this.pickupCode,
    this.buyerLandmark,
    this.sellerNetTotalGnf,
    this.sellerName,
    this.courierId,
    this.courierName,
    this.slaOverdue = false,
    this.escrow,
    this.dispute,
    this.rating,
    this.createdAt,
    this.paidAt,
    this.deliveredAt,
    this.fundsReleasedAt,
  });

  final String id;
  final String? paymentIntentId;
  final OrderStatus status;
  final FulfillmentMode fulfillmentMode;
  final String? pickupCode;
  final String buyerUserId;
  final String sellerProfileId;
  final String buyerName;
  final String buyerPhone;
  final String buyerZoneId;
  final String buyerAddressLine;
  final String? buyerLandmark;
  final int deliveryFeeGnf;
  final int subtotalGnf;
  final int totalGnf;
  final int? sellerNetTotalGnf;
  final String? sellerName;
  final String? courierId;
  final String? courierName;
  final bool slaOverdue;
  final List<ApiOrderLine> lines;
  final List<OrderNextAction> nextActions;
  final ApiOrderEscrow? escrow;
  final ApiOrderDispute? dispute;
  final ApiOrderRating? rating;
  final String? createdAt;
  final String? paidAt;
  final String? deliveredAt;
  final String? fundsReleasedAt;

  bool get hasAction => nextActions.isNotEmpty;

  bool hasNextAction(OrderNextAction action) => nextActions.contains(action);

  factory ApiOrder.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    final lines = <ApiOrderLine>[];
    if (rawLines is List) {
      for (final line in rawLines) {
        if (line is Map) {
          lines.add(ApiOrderLine.fromJson(Map<String, dynamic>.from(line)));
        }
      }
    }

    final rawActions = json['nextActions'];
    final actions = <OrderNextAction>[];
    if (rawActions is List) {
      for (final a in rawActions) {
        final parsed = orderNextActionFromApi(a?.toString());
        if (parsed != null) actions.add(parsed);
      }
    }

    final disputeRaw = json['dispute'];
    final escrowRaw = json['escrow'];
    final ratingRaw = json['rating'];

    return ApiOrder(
      id: (json['id'] ?? '').toString(),
      paymentIntentId: json['paymentIntentId']?.toString(),
      status: orderStatusFromApi(json['status']?.toString()),
      fulfillmentMode:
          fulfillmentModeFromApi(json['fulfillmentMode']?.toString()),
      pickupCode: json['pickupCode']?.toString(),
      buyerUserId:
          (json['buyerUserId'] ?? json['buyerId'] ?? '').toString(),
      sellerProfileId:
          (json['sellerProfileId'] ?? json['sellerId'] ?? '').toString(),
      buyerName: (json['buyerName'] ?? '').toString(),
      buyerPhone: (json['buyerPhone'] ?? '').toString(),
      buyerZoneId: (json['buyerZoneId'] ?? '').toString(),
      buyerAddressLine: (json['buyerAddressLine'] ??
              json['buyerAddress'] ??
              '')
          .toString(),
      buyerLandmark: json['buyerLandmark']?.toString(),
      deliveryFeeGnf: _int(json['deliveryFeeGnf']),
      subtotalGnf: _int(json['subtotalGnf']),
      totalGnf: _int(json['totalGnf'] ?? json['grandTotalGnf']),
      sellerNetTotalGnf: json['sellerNetGnf'] != null ||
              json['sellerNetTotalGnf'] != null
          ? _int(json['sellerNetGnf'] ?? json['sellerNetTotalGnf'])
          : null,
      sellerName: (json['sellerName'] ?? json['seller']?['name'] ?? json['seller']?['username'])
          ?.toString(),
      courierId: json['courierId']?.toString(),
      courierName: json['courierName']?.toString(),
      slaOverdue: json['slaOverdue'] == true,
      lines: lines,
      nextActions: actions,
      escrow: escrowRaw is Map
          ? ApiOrderEscrow.fromJson(Map<String, dynamic>.from(escrowRaw))
          : null,
      dispute: disputeRaw is Map
          ? ApiOrderDispute.fromJson(Map<String, dynamic>.from(disputeRaw))
          : (json['disputeReason'] != null
              ? ApiOrderDispute(reason: json['disputeReason']?.toString())
              : null),
      rating: ratingRaw is Map
          ? ApiOrderRating.fromJson(Map<String, dynamic>.from(ratingRaw))
          : null,
      createdAt: json['createdAt']?.toString(),
      paidAt: json['paidAt']?.toString(),
      deliveredAt: json['deliveredAt']?.toString(),
      fundsReleasedAt: json['fundsReleasedAt']?.toString(),
    );
  }
}

class ApiOrderListPage {
  const ApiOrderListPage({
    required this.items,
    this.nextCursor,
  });

  final List<ApiOrder> items;
  final String? nextCursor;

  factory ApiOrderListPage.fromJson(dynamic data) {
    if (data is List) {
      return ApiOrderListPage(
        items: [
          for (final o in data)
            if (o is Map) ApiOrder.fromJson(Map<String, dynamic>.from(o)),
        ],
      );
    }
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final raw = map['items'] ?? map['orders'] ?? map['data'];
      final items = <ApiOrder>[];
      if (raw is List) {
        for (final o in raw) {
          if (o is Map) {
            items.add(ApiOrder.fromJson(Map<String, dynamic>.from(o)));
          }
        }
      }
      return ApiOrderListPage(
        items: items,
        nextCursor: (map['nextCursor'] ?? map['cursor'])?.toString(),
      );
    }
    return const ApiOrderListPage(items: []);
  }
}

class ConfirmReceiptApiResult {
  const ConfirmReceiptApiResult({
    required this.order,
    this.escrowState,
  });

  final ApiOrder order;
  final EscrowState? escrowState;
}

/// Nest orders & fulfillment API (`/api/v1/orders…`).
class OrdersApi {
  OrdersApi._();
  static final OrdersApi instance = OrdersApi._();

  final _client = ApiClient.instance;

  Future<ApiOrderListPage> listOrders({
    required String as, // buyer | seller
    String? filter,
    String? q,
    int? limit,
    String? cursor,
  }) async {
    try {
      final res = await _client.get<dynamic>(
        '/orders',
        queryParameters: {
          'as': as,
          if (filter != null && filter.isNotEmpty) 'filter': filter,
          if (q != null && q.isNotEmpty) 'q': q,
          if (limit != null) 'limit': limit,
          if (cursor != null && cursor.isNotEmpty) 'cursor': cursor,
        },
      );
      return ApiOrderListPage.fromJson(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrderListPage> listPurchases({
    String? filter,
    String? q,
    int? limit,
  }) =>
      listOrders(as: 'buyer', filter: filter, q: q, limit: limit);

  Future<ApiOrderListPage> listSales({
    String? filter,
    String? q,
    int? limit,
  }) =>
      listOrders(as: 'seller', filter: filter, q: q, limit: limit);

  Future<ApiOrder> getOrder(String id) async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/orders/$id');
      return ApiOrder.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<ApiOrderTimelineEvent>> getTimeline(String id) async {
    try {
      final res = await _client.get<dynamic>('/orders/$id/timeline');
      final data = res.data;
      final list = data is Map && data['events'] is List
          ? data['events'] as List
          : data is Map && data['items'] is List
              ? data['items'] as List
              : data is List
                  ? data
                  : const [];
      return [
        for (final e in list)
          if (e is Map)
            ApiOrderTimelineEvent.fromJson(Map<String, dynamic>.from(e)),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrder> prepare(String id) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/orders/$id/prepare',
        data: const {},
      );
      return _orderFromActionResponse(res.data, id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrder> markReady(String id) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/orders/$id/ready',
        data: const {},
      );
      return _orderFromActionResponse(res.data, id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Proximity handoff — typed [pickupCode] required.
  Future<ApiOrder> confirmHandoff(
    String id, {
    required String pickupCode,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/orders/$id/confirm-handoff',
        data: {'pickupCode': pickupCode},
      );
      return _orderFromActionResponse(res.data, id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ConfirmReceiptApiResult> confirmReceipt(String id) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/orders/$id/confirm-receipt',
        data: const {},
      );
      final data = Map<String, dynamic>.from(res.data ?? {});
      final orderRaw = data['order'];
      final order = orderRaw is Map
          ? ApiOrder.fromJson(Map<String, dynamic>.from(orderRaw))
          : ApiOrder.fromJson(data);
      EscrowState? escrow;
      final escrowRaw = data['escrow'];
      if (escrowRaw is Map) {
        escrow = escrowStateFromApi(escrowRaw['state']?.toString());
      } else {
        escrow = order.escrow?.state;
      }
      return ConfirmReceiptApiResult(order: order, escrowState: escrow);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrder> openDispute(
    String id, {
    required String role,
    required String reason,
    String? reasonCode,
    String openedVia = 'order_page',
  }) async {
    try {
      final body = <String, dynamic>{
        'role': role,
        'reason': reason,
        'openedVia': openedVia,
      };
      if (reasonCode != null && reasonCode.isNotEmpty) {
        body['reasonCode'] = reasonCode;
      }
      final res = await _client.post<Map<String, dynamic>>(
        '/orders/$id/disputes',
        data: body,
      );
      return _orderFromActionResponse(res.data, id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrder> rateOrder(
    String id, {
    required int stars,
    String? comment,
  }) async {
    try {
      final body = <String, dynamic>{'stars': stars};
      if (comment != null && comment.trim().isNotEmpty) {
        body['comment'] = comment.trim();
      }
      final res = await _client.post<Map<String, dynamic>>(
        '/orders/$id/ratings',
        data: body,
      );
      return _orderFromActionResponse(res.data, id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrder> sellerRefund(
    String id, {
    int? amountGnf,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/orders/$id/seller-refund',
        data: {'amountGnf': amountGnf},
      );
      return _orderFromActionResponse(res.data, id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrder> markCollected(String id) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/orders/$id/collected',
        data: const {},
      );
      return _orderFromActionResponse(res.data, id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrder> markInTransit(String id) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/orders/$id/in-transit',
        data: const {},
      );
      return _orderFromActionResponse(res.data, id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrder> markDelivered(
    String id, {
    String? proofPhotoUrl,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (proofPhotoUrl != null && proofPhotoUrl.isNotEmpty) {
        body['proofPhotoUrl'] = proofPhotoUrl;
      }
      final res = await _client.post<Map<String, dynamic>>(
        '/orders/$id/delivered',
        data: body,
      );
      return _orderFromActionResponse(res.data, id);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrder> acceptCourierMission(String orderId) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/courier/missions/$orderId/accept',
        data: const {},
      );
      return _orderFromActionResponse(res.data, orderId);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiOrder> _orderFromActionResponse(
    Map<String, dynamic>? data,
    String fallbackId,
  ) async {
    if (data == null || data.isEmpty) {
      return getOrder(fallbackId);
    }
    final orderRaw = data['order'];
    if (orderRaw is Map) {
      return ApiOrder.fromJson(Map<String, dynamic>.from(orderRaw));
    }
    if (data.containsKey('id') || data.containsKey('status')) {
      return ApiOrder.fromJson(data);
    }
    return getOrder(fallbackId);
  }
}
