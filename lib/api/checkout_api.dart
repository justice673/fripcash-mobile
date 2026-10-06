import 'dart:math';

import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/models/checkout_address.dart';
import 'package:frip_cash/models/fulfillment_mode.dart';

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse('$v') ?? 0;
}

String fulfillmentModeToApi(FulfillmentMode mode) => switch (mode) {
      FulfillmentMode.courier => 'courier',
      FulfillmentMode.pickup => 'pickup',
      FulfillmentMode.shopLocalDelivery => 'shopLocalDelivery',
    };

FulfillmentMode fulfillmentModeFromApi(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'pickup':
      return FulfillmentMode.pickup;
    case 'shoplocaldelivery':
    case 'shop_local_delivery':
      return FulfillmentMode.shopLocalDelivery;
    default:
      return FulfillmentMode.courier;
  }
}

Map<String, dynamic> checkoutAddressToJson(
  CheckoutAddress address, {
  required FulfillmentMode fulfillmentMode,
}) {
  if (fulfillmentMode == FulfillmentMode.pickup) {
    return {
      'name': address.name,
      'phone': address.phone,
    };
  }
  return {
    'name': address.name,
    'phone': address.phone,
    'zoneId': address.zoneId,
    'quartier': address.quartier,
    'manualAddress': address.manualAddress,
    'landmark': address.landmark,
  };
}

class QuoteLine {
  const QuoteLine({
    required this.listingId,
    required this.title,
    required this.qty,
    required this.unitDisplayPriceGnf,
    required this.lineTotalGnf,
    this.coverUrl,
  });

  final String listingId;
  final String title;
  final int qty;
  final int unitDisplayPriceGnf;
  final int lineTotalGnf;
  final String? coverUrl;

  factory QuoteLine.fromJson(Map<String, dynamic> json) {
    return QuoteLine(
      listingId: (json['listingId'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      qty: _int(json['qty'] ?? json['quantity'] ?? 1),
      unitDisplayPriceGnf: _int(json['unitDisplayPriceGnf']),
      lineTotalGnf: _int(json['lineTotalGnf']),
      coverUrl: json['coverUrl']?.toString(),
    );
  }
}

class QuoteSellerGroup {
  const QuoteSellerGroup({
    required this.sellerId,
    required this.sellerName,
    required this.deliveryFeeGnf,
    required this.lines,
  });

  final String sellerId;
  final String sellerName;
  final int deliveryFeeGnf;
  final List<QuoteLine> lines;

  factory QuoteSellerGroup.fromJson(Map<String, dynamic> json) {
    final rawLines = json['lines'];
    final lines = <QuoteLine>[];
    if (rawLines is List) {
      for (final line in rawLines) {
        if (line is Map) {
          lines.add(QuoteLine.fromJson(Map<String, dynamic>.from(line)));
        }
      }
    }
    return QuoteSellerGroup(
      sellerId: (json['sellerId'] ?? '').toString(),
      sellerName: (json['sellerName'] ?? '').toString(),
      deliveryFeeGnf: _int(json['deliveryFeeGnf']),
      lines: lines,
    );
  }
}

class CheckoutQuote {
  const CheckoutQuote({
    required this.currency,
    required this.subtotalGnf,
    required this.deliveryFeeGnf,
    required this.grandTotalGnf,
    required this.fulfillmentMode,
    required this.sellerGroups,
    required this.blocks,
    this.expiresAt,
    this.cartRevision,
  });

  final String currency;
  final int subtotalGnf;
  final int deliveryFeeGnf;
  final int grandTotalGnf;
  final FulfillmentMode fulfillmentMode;
  final List<QuoteSellerGroup> sellerGroups;
  final List<String> blocks;
  final String? expiresAt;
  final String? cartRevision;

  bool get canPay => blocks.isEmpty;

  factory CheckoutQuote.fromJson(
    Map<String, dynamic> json, {
    String? cartRevision,
  }) {
    final rawGroups = json['sellerGroups'];
    final groups = <QuoteSellerGroup>[];
    if (rawGroups is List) {
      for (final g in rawGroups) {
        if (g is Map) {
          groups.add(QuoteSellerGroup.fromJson(Map<String, dynamic>.from(g)));
        }
      }
    }
    final rawBlocks = json['blocks'];
    final blocks = <String>[];
    if (rawBlocks is List) {
      for (final b in rawBlocks) {
        if (b is Map && b['code'] != null) {
          blocks.add(b['code'].toString());
        } else if (b != null) {
          blocks.add(b.toString());
        }
      }
    }
    return CheckoutQuote(
      currency: (json['currency'] ?? 'GNF').toString(),
      subtotalGnf: _int(json['subtotalGnf']),
      deliveryFeeGnf: _int(json['deliveryFeeGnf']),
      grandTotalGnf: _int(json['grandTotalGnf']),
      fulfillmentMode: fulfillmentModeFromApi(json['fulfillmentMode']?.toString()),
      sellerGroups: groups,
      blocks: blocks,
      expiresAt: json['expiresAt']?.toString(),
      cartRevision: cartRevision ?? json['cartRevision']?.toString(),
    );
  }
}

enum PaymentStatus {
  pendingCustomerApproval,
  processing,
  succeeded,
  failed,
  cancelled,
  expired,
  unknown,
}

PaymentStatus paymentStatusFromApi(String? raw) {
  switch ((raw ?? '').toLowerCase()) {
    case 'pending_customer_approval':
      return PaymentStatus.pendingCustomerApproval;
    case 'processing':
      return PaymentStatus.processing;
    case 'succeeded':
      return PaymentStatus.succeeded;
    case 'failed':
      return PaymentStatus.failed;
    case 'cancelled':
    case 'canceled':
      return PaymentStatus.cancelled;
    case 'expired':
      return PaymentStatus.expired;
    default:
      return PaymentStatus.unknown;
  }
}

extension PaymentStatusX on PaymentStatus {
  bool get isTerminal =>
      this == PaymentStatus.succeeded ||
      this == PaymentStatus.failed ||
      this == PaymentStatus.cancelled ||
      this == PaymentStatus.expired;

  bool get isPending =>
      this == PaymentStatus.pendingCustomerApproval ||
      this == PaymentStatus.processing ||
      this == PaymentStatus.unknown;
}

class PaymentIntent {
  const PaymentIntent({
    required this.paymentIntentId,
    required this.status,
    required this.amountGnf,
    required this.currency,
    required this.orangeMoneyPhone,
    required this.orderIds,
    this.expiresAt,
    this.pollUrl,
    this.pickupCodes,
  });

  final String paymentIntentId;
  final PaymentStatus status;
  final int amountGnf;
  final String currency;
  final String orangeMoneyPhone;
  final List<String> orderIds;
  final String? expiresAt;
  final String? pollUrl;

  /// Optional map orderId → pickup code when present on poll response.
  final Map<String, String>? pickupCodes;

  factory PaymentIntent.fromJson(Map<String, dynamic> json) {
    final rawOrders = json['orderIds'];
    final orderIds = <String>[];
    if (rawOrders is List) {
      for (final id in rawOrders) {
        orderIds.add(id.toString());
      }
    }
    final clientAction = json['clientAction'];
    String? pollUrl;
    if (clientAction is Map) {
      pollUrl = clientAction['pollUrl']?.toString();
    }
    pollUrl ??= json['pollUrl']?.toString();

    Map<String, String>? pickupCodes;
    final rawCodes = json['pickupCodes'] ?? json['orders'];
    if (rawCodes is Map) {
      pickupCodes = {
        for (final e in rawCodes.entries)
          e.key.toString(): e.value.toString(),
      };
    } else if (rawCodes is List) {
      pickupCodes = {};
      for (final o in rawCodes) {
        if (o is Map && o['id'] != null && o['pickupCode'] != null) {
          pickupCodes[o['id'].toString()] = o['pickupCode'].toString();
        }
      }
    }

    return PaymentIntent(
      paymentIntentId: (json['paymentIntentId'] ?? json['id'] ?? '').toString(),
      status: paymentStatusFromApi(json['status']?.toString()),
      amountGnf: _int(json['amountGnf'] ?? json['grandTotalGnf']),
      currency: (json['currency'] ?? 'GNF').toString(),
      orangeMoneyPhone: (json['orangeMoneyPhone'] ?? '').toString(),
      orderIds: orderIds,
      expiresAt: json['expiresAt']?.toString(),
      pollUrl: pollUrl,
      pickupCodes: pickupCodes,
    );
  }
}

class DeliveryZone {
  const DeliveryZone({
    required this.id,
    required this.name,
    this.quartiers = const [],
  });

  final String id;
  final String name;
  final List<String> quartiers;

  factory DeliveryZone.fromJson(Map<String, dynamic> json) {
    final raw = json['quartiers'] ?? json['neighborhoods'];
    final quartiers = <String>[];
    if (raw is List) {
      for (final q in raw) {
        quartiers.add(q.toString());
      }
    }
    return DeliveryZone(
      id: (json['id'] ?? json['zoneId'] ?? '').toString(),
      name: (json['name'] ?? json['label'] ?? json['id'] ?? '').toString(),
      quartiers: quartiers,
    );
  }
}

/// Generates a UUID v4-ish string for Idempotency-Key without extra deps.
String newIdempotencyKey() {
  final r = Random.secure();
  final bytes = List<int>.generate(16, (_) => r.nextInt(256));
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  bytes[8] = (bytes[8] & 0x3f) | 0x80;
  String hex(int b) => b.toRadixString(16).padLeft(2, '0');
  final h = bytes.map(hex).join();
  return '${h.substring(0, 8)}-${h.substring(8, 12)}-'
      '${h.substring(12, 16)}-${h.substring(16, 20)}-${h.substring(20)}';
}

class CheckoutApi {
  CheckoutApi._();
  static final CheckoutApi instance = CheckoutApi._();

  final _client = ApiClient.instance;

  Future<CheckoutQuote> quote({
    required String cartRevision,
    required FulfillmentMode fulfillmentMode,
    required CheckoutAddress address,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/checkout/quote',
        data: {
          'cartRevision': cartRevision,
          'fulfillmentMode': fulfillmentModeToApi(fulfillmentMode),
          'address': checkoutAddressToJson(
            address,
            fulfillmentMode: fulfillmentMode,
          ),
        },
      );
      return CheckoutQuote.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
        cartRevision: cartRevision,
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PaymentIntent> createPayment({
    required String cartRevision,
    required FulfillmentMode fulfillmentMode,
    required CheckoutAddress address,
    required String orangeMoneyPhone,
    required int quoteGrandTotalGnf,
    String? idempotencyKey,
  }) async {
    try {
      final key = idempotencyKey ?? newIdempotencyKey();
      final res = await _client.post<Map<String, dynamic>>(
        '/checkout/payments',
        data: {
          'cartRevision': cartRevision,
          'fulfillmentMode': fulfillmentModeToApi(fulfillmentMode),
          'address': checkoutAddressToJson(
            address,
            fulfillmentMode: fulfillmentMode,
          ),
          'orangeMoneyPhone': orangeMoneyPhone,
          'quoteGrandTotalGnf': quoteGrandTotalGnf,
        },
        headers: {'Idempotency-Key': key},
      );
      return PaymentIntent.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<PaymentIntent> getPaymentStatus(String paymentIntentId) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/checkout/payments/$paymentIntentId',
      );
      return PaymentIntent.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Polls until terminal status or [timeout].
  Future<PaymentIntent> pollPaymentStatus(
    String paymentIntentId, {
    Duration interval = const Duration(seconds: 2),
    Duration timeout = const Duration(minutes: 3),
    bool Function()? shouldCancel,
  }) async {
    final deadline = DateTime.now().add(timeout);
    PaymentIntent latest = await getPaymentStatus(paymentIntentId);
    while (!latest.status.isTerminal) {
      if (shouldCancel?.call() == true) return latest;
      if (DateTime.now().isAfter(deadline)) {
        return latest;
      }
      await Future<void>.delayed(interval);
      if (shouldCancel?.call() == true) return latest;
      latest = await getPaymentStatus(paymentIntentId);
    }
    return latest;
  }

  /// Prefer geo `GET /catalog/zones` (same book as admin shipping-rates +
  /// seller `zoneId`). Fall back to legacy logical delivery-zones.
  Future<List<DeliveryZone>> fetchDeliveryZones() async {
    try {
      final geo = await _fetchGeoZonesAsDelivery();
      if (geo.isNotEmpty) return geo;
    } catch (_) {
      // Fall through to legacy catalog.
    }
    try {
      final res =
          await _client.get<dynamic>('/catalog/delivery-zones');
      final data = res.data;
      final list = data is Map && data['zones'] is List
          ? data['zones'] as List
          : data is List
              ? data
              : const [];
      return [
        for (final z in list)
          if (z is Map)
            DeliveryZone.fromJson(Map<String, dynamic>.from(z)),
      ];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<DeliveryZone>> _fetchGeoZonesAsDelivery() async {
    final res = await _client.get<dynamic>('/catalog/zones');
    final data = res.data;
    final list = data is List
        ? data
        : (data is Map
            ? (data['items'] ?? data['zones'] ?? data['data'] ?? [])
            : const []);
    if (list is! List) return const [];
    final zones = <DeliveryZone>[];
    for (final z in list) {
      if (z is! Map) continue;
      final m = Map<String, dynamic>.from(z);
      if (m['isActive'] == false) continue;
      final id = (m['id'] ?? '').toString();
      if (id.isEmpty) continue;
      final name = (m['nameFr'] ?? m['name'] ?? m['code'] ?? id).toString();
      zones.add(DeliveryZone(id: id, name: name, quartiers: const []));
    }
    zones.sort((a, b) => a.name.compareTo(b.name));
    return zones;
  }

  Future<Map<String, dynamic>> fetchShippingRates() async {
    try {
      final res =
          await _client.get<Map<String, dynamic>>('/catalog/shipping-rates');
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
