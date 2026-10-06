import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/models/catalog_category.dart';
import 'package:frip_cash/models/shop_category.dart';

class CatalogApi {
  CatalogApi._();
  static final CatalogApi instance = CatalogApi._();

  final _client = ApiClient.instance;

  /// Public: `GET /catalog/categories`
  Future<List<CatalogCategory>> fetchCategories() async {
    try {
      final res = await _client.get<dynamic>('/catalog/categories');
      final raw = res.data;
      final list = <dynamic>[];
      if (raw is List) {
        list.addAll(raw);
      } else if (raw is Map) {
        final items = raw['items'] ?? raw['data'] ?? raw['categories'];
        if (items is List) list.addAll(items);
      }
      return list
          .whereType<Map>()
          .map((e) => CatalogCategory.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.id.isNotEmpty && c.isActive)
          .toList();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  /// Public: `GET /catalog/shop-categories?kind=PROXIMITE` — neighborhood shop types.
  Future<List<ShopCategory>> fetchShopCategories({
    String kind = 'PROXIMITE',
  }) async {
    try {
      final res = await _client.get<dynamic>(
        '/catalog/shop-categories',
        queryParameters: {'kind': kind},
      );
      final raw = res.data;
      final list = <dynamic>[];
      if (raw is List) {
        list.addAll(raw);
      } else if (raw is Map) {
        final items = raw['items'] ?? raw['data'] ?? raw['categories'];
        if (items is List) list.addAll(items);
      }
      final parsed = list
          .whereType<Map>()
          .map((e) => ShopCategory.fromJson(Map<String, dynamic>.from(e)))
          .where((c) => c.id.isNotEmpty && c.isActive)
          .toList();
      parsed.sort((a, b) {
        final byOrder = a.sortOrder.compareTo(b.sortOrder);
        if (byOrder != 0) return byOrder;
        return a.nameFr.compareTo(b.nameFr);
      });
      return parsed;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
