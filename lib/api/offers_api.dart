import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/models/offer.dart';

class OffersPage {
  const OffersPage({
    required this.items,
    this.nextCursor,
    this.pendingCount,
  });

  final List<ProductOffer> items;
  final String? nextCursor;
  final int? pendingCount;
}

class OffersApi {
  OffersApi._();
  static final OffersApi instance = OffersApi._();

  final _client = ApiClient.instance;

  String _idempotencyKey() =>
      'offer_${DateTime.now().microsecondsSinceEpoch}';

  Future<ProductOffer> create({
    required String listingId,
    required int offeredPriceGnf,
  }) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/listings/$listingId/offers',
        data: {'offeredPriceGnf': offeredPriceGnf},
      );
      return ProductOffer.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<OffersPage> listMine({String status = 'ALL', int limit = 30}) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/me/offers',
        queryParameters: {'status': status, 'limit': limit},
      );
      return _page(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<OffersPage> listSeller({
    String status = 'PENDING',
    String? listingId,
    int limit = 30,
  }) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/me/seller/offers',
        queryParameters: {
          'status': status,
          'limit': limit,
          if (listingId != null && listingId.isNotEmpty) 'listingId': listingId,
        },
      );
      return _page(res.data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ProductOffer> accept(String offerId) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/offers/$offerId/accept',
        headers: {'Idempotency-Key': _idempotencyKey()},
      );
      return ProductOffer.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ProductOffer> refuse(String offerId, {String? reason}) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/offers/$offerId/refuse',
        data: {
          if (reason != null && reason.isNotEmpty) 'reason': reason,
        },
      );
      return ProductOffer.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ProductOffer> cancel(String offerId) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/offers/$offerId/cancel',
      );
      return ProductOffer.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  OffersPage _page(Map<String, dynamic>? data) {
    final map = Map<String, dynamic>.from(data ?? {});
    final raw = map['items'];
    final items = <ProductOffer>[];
    if (raw is List) {
      for (final row in raw) {
        if (row is! Map) continue;
        final o = ProductOffer.fromJson(Map<String, dynamic>.from(row));
        if (o.id.isEmpty) continue;
        items.add(o);
      }
    }
    return OffersPage(
      items: items,
      nextCursor: map['nextCursor']?.toString(),
      pendingCount: map['pendingCount'] is num
          ? (map['pendingCount'] as num).toInt()
          : int.tryParse('${map['pendingCount']}'),
    );
  }
}
