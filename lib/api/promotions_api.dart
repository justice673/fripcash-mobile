import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/models/promotion.dart';

class PromotionsApi {
  PromotionsApi._();
  static final PromotionsApi instance = PromotionsApi._();

  final _client = ApiClient.instance;

  /// Public: `GET /promotions?surface=HOME_APP|HOME_WEB&limit=`
  Future<PromotionsFeed> fetchPublic({
    String surface = 'HOME_APP',
    int limit = 12,
  }) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/promotions',
        queryParameters: {
          'surface': surface,
          'limit': limit.clamp(1, 50),
        },
      );
      final data = Map<String, dynamic>.from(res.data ?? {});
      final rawItems = data['items'];
      final list = <FeaturedPromotion>[];
      if (rawItems is List) {
        for (final row in rawItems) {
          if (row is! Map) continue;
          final promo = FeaturedPromotion.fromJson(
            Map<String, dynamic>.from(row),
          );
          if (promo.id.isEmpty) continue;
          list.add(promo);
        }
      }
      list.sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

      final serverNow = DateTime.tryParse(
            (data['serverNow'] ?? '').toString(),
          )?.toUtc() ??
          DateTime.now().toUtc();

      return PromotionsFeed(
        items: List.unmodifiable(list),
        serverNow: serverNow,
        fetchedAt: DateTime.now().toUtc(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
