import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/seller_type.dart';

ListingDestination? listingDestinationFromApi(String? raw) {
  if (raw == null) return null;
  switch (raw.toUpperCase()) {
    case 'SECONDE_MAIN':
      return ListingDestination.secondeMain;
    case 'ARTICLES_NEUFS':
      return ListingDestination.articlesNeufs;
    case 'QUARTIER_BOUTIQUES':
      return ListingDestination.quartierBoutiques;
    case 'ENSEIGNES':
      return ListingDestination.enseignes;
    default:
      return null;
  }
}

String? listingDestinationToApi(ListingDestination? d) {
  if (d == null) return null;
  return switch (d) {
    ListingDestination.secondeMain => 'SECONDE_MAIN',
    ListingDestination.articlesNeufs => 'ARTICLES_NEUFS',
    ListingDestination.quartierBoutiques => 'QUARTIER_BOUTIQUES',
    ListingDestination.enseignes => 'ENSEIGNES',
  };
}

SellerType sellerTypeFromApi(String? raw, {String? badge}) {
  final s = (raw ?? '').toLowerCase();
  if (s.contains('enseigne')) return SellerType.enseigne;
  if (badge == 'Proximité' || s.contains('proxim')) {
    return SellerType.boutique;
  }
  if (s.contains('boutique') || s.contains('shop')) return SellerType.boutique;
  return SellerType.particulier;
}

Product productFromListingJson(Map<String, dynamic> json) {
  final media = json['media'];
  final urls = <String>[];
  if (media is List) {
    final rows = <({int order, String url})>[];
    for (final m in media) {
      if (m is! Map) continue;
      final url = (m['url'] ??
              m['secureUrl'] ??
              m['secure_url'] ??
              m['publicUrl'] ??
              m['public_url'] ??
              '')
          .toString();
      if (url.isEmpty) continue;
      final order = m['sortOrder'] is int
          ? m['sortOrder'] as int
          : int.tryParse('${m['sortOrder'] ?? 0}') ?? 0;
      rows.add((order: order, url: url));
    }
    rows.sort((a, b) => a.order.compareTo(b.order));
    urls.addAll(rows.map((r) => r.url));
  }
  final cover = urls.isNotEmpty
      ? urls.first
      : (json['coverUrl'] ?? json['imageUrl'] ?? json['image'] ?? '').toString();

  final display = _int(json['displayPriceGnf'] ?? json['priceGnf'] ?? json['price']);
  final net = json['netPriceGnf'] != null ? _int(json['netPriceGnf']) : null;
  final colorsRaw = json['colors'];
  final colors = colorsRaw is List
      ? colorsRaw.map((e) => e.toString()).toList()
      : null;

  final dest = listingDestinationFromApi(json['destination']?.toString());
  final badge = json['badge']?.toString();
  final sellerType = sellerTypeFromApi(
    json['sellerType']?.toString(),
    badge: badge,
  );

  final sellerMap = json['seller'] is Map
      ? Map<String, dynamic>.from(json['seller'] as Map)
      : json['sellerProfile'] is Map
          ? Map<String, dynamic>.from(json['sellerProfile'] as Map)
          : null;
  final sellerName = sellerMap == null
      ? null
      : (sellerMap['name'] ??
              sellerMap['displayName'] ??
              sellerMap['username'] ??
              sellerMap['pseudo'])
          ?.toString();
  final sellerAvatar = sellerMap == null
      ? null
      : (sellerMap['avatarUrl'] ?? sellerMap['avatar'])?.toString();
  final sellerRatingRaw = sellerMap?['rating'] ?? sellerMap?['avgRating'];
  final sellerRating = sellerRatingRaw is num
      ? sellerRatingRaw.toDouble()
      : double.tryParse('$sellerRatingRaw');
  final sellerReviewsRaw =
      sellerMap?['reviewCount'] ?? sellerMap?['reviewsCount'];
  final sellerReviewCount = sellerReviewsRaw is int
      ? sellerReviewsRaw
      : int.tryParse('$sellerReviewsRaw');

  return Product(
    id: (json['id'] ?? '').toString(),
    title: (json['title'] ?? '').toString(),
    price: display,
    netPrice: net,
    image: cover,
    images: urls.isEmpty ? null : urls,
    size: (json['size'] ?? 'One size').toString(),
    categoryId: (json['categoryId'] ?? json['category']?['id'] ?? 'mode')
        .toString(),
    sellerId: (json['sellerProfileId'] ??
            json['sellerId'] ??
            sellerMap?['id'] ??
            '')
        .toString(),
    sellerType: sellerType,
    stock: _int(json['stock'] ?? json['quantity'] ?? 1),
    brand: json['brand']?.toString(),
    shippingCost: _int(json['shippingCostGnf'] ?? json['shippingCost'] ?? 0),
    condition: (json['condition'] ?? json['conditionNote'] ?? 'Très bon état')
        .toString(),
    description: json['description']?.toString(),
    colors: colors,
    badge: badge,
    compareAtPrice: json['compareAtPriceGnf'] != null
        ? _int(json['compareAtPriceGnf'])
        : null,
    negotiable: json['negotiable'] == true,
    destination: dest,
    sellerName: sellerName,
    sellerAvatarUrl: sellerAvatar,
    sellerRating: sellerRating,
    sellerReviewCount: sellerReviewCount,
  );
}

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse('$v') ?? 0;
}

class ListingPage {
  const ListingPage({required this.items, this.nextCursor});
  final List<Product> items;
  final String? nextCursor;
}

class ListingsApi {
  ListingsApi._();
  static final ListingsApi instance = ListingsApi._();

  final _client = ApiClient.instance;

  Future<ListingPage> discover({
    String? destination,
    String? categoryId,
    String? sellerId,
    String? q,
    int? minPrice,
    int? maxPrice,
    bool inStockOnly = true,
    String sort = 'newest',
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/listings',
        queryParameters: {
          if (destination != null) 'destination': destination,
          if (categoryId != null) 'categoryId': categoryId,
          if (sellerId != null && sellerId.isNotEmpty) 'sellerId': sellerId,
          if (q != null && q.isNotEmpty) 'q': q,
          if (minPrice != null) 'minPrice': minPrice,
          if (maxPrice != null) 'maxPrice': maxPrice,
          'inStockOnly': inStockOnly,
          'sort': sort,
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      final data = Map<String, dynamic>.from(res.data ?? {});
      final rawItems = data['items'] ?? data['data'] ?? [];
      final items = <Product>[];
      if (rawItems is List) {
        for (final row in rawItems) {
          if (row is Map) {
            items.add(productFromListingJson(Map<String, dynamic>.from(row)));
          }
        }
      }
      return ListingPage(
        items: items,
        nextCursor: data['nextCursor']?.toString(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Product> getById(String id) async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/listings/$id');
      return productFromListingJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ListingPage> myListings({
    String? status,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/me/listings',
        queryParameters: {
          if (status != null) 'status': status,
          if (cursor != null) 'cursor': cursor,
          'limit': limit,
        },
      );
      final data = Map<String, dynamic>.from(res.data ?? {});
      final rawItems = data['items'] ?? data['data'] ?? [];
      final items = <Product>[];
      if (rawItems is List) {
        for (final row in rawItems) {
          if (row is Map) {
            items.add(productFromListingJson(Map<String, dynamic>.from(row)));
          }
        }
      }
      return ListingPage(
        items: items,
        nextCursor: data['nextCursor']?.toString(),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    try {
      final res =
          await _client.post<Map<String, dynamic>>('/listings', data: body);
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> patch(
    String id,
    Map<String, dynamic> body,
  ) async {
    try {
      final res = await _client.patch<Map<String, dynamic>>(
        '/listings/$id',
        data: body,
      );
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> addMedia(
    String id, {
    required String publicId,
    required String url,
    String mimeType = 'image/jpeg',
    int sortOrder = 0,
  }) async {
    try {
      await _client.post(
        '/listings/$id/media',
        data: {
          'publicId': publicId,
          'url': url,
          'mimeType': mimeType,
          'sortOrder': sortOrder,
        },
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Product> publish(String id) async {
    try {
      final res =
          await _client.post<Map<String, dynamic>>('/listings/$id/publish');
      return productFromListingJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Product> hide(String id) async {
    try {
      final res =
          await _client.post<Map<String, dynamic>>('/listings/$id/hide');
      return productFromListingJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Product> updatePrice(String id, int netPriceGnf) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/listings/$id/price',
        data: {'netPriceGnf': netPriceGnf},
      );
      return productFromListingJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Product> updateStock(
    String id, {
    int? set,
    int? delta,
    int? add,
  }) async {
    try {
      final body = <String, dynamic>{};
      if (set != null) body['set'] = set;
      if (delta != null) body['delta'] = delta;
      if (add != null) body['add'] = add;
      final res = await _client.post<Map<String, dynamic>>(
        '/listings/$id/stock',
        data: body,
      );
      return productFromListingJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<String> copy(String id) async {
    try {
      final res =
          await _client.post<Map<String, dynamic>>('/listings/$id/copy');
      final data = Map<String, dynamic>.from(res.data ?? {});
      return (data['draftId'] ?? data['listingId'] ?? data['id'] ?? '').toString();
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> delete(String id) async {
    try {
      await _client.delete('/listings/$id');
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> excelImport(List<Map<String, dynamic>> rows) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/me/seller/tools/excel-import',
        data: {'rows': rows},
      );
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<Map<String, dynamic>>> productLibrary() async {
    try {
      final res = await _client.get<dynamic>('/me/seller/tools/library');
      final data = res.data;
      if (data is List) {
        return [
          for (final row in data)
            if (row is Map) Map<String, dynamic>.from(row),
        ];
      }
      if (data is Map) {
        final items = data['items'] ?? data['products'] ?? [];
        if (items is List) {
          return [
            for (final row in items)
              if (row is Map) Map<String, dynamic>.from(row),
          ];
        }
      }
      return [];
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> publishLibrary(
    List<Map<String, dynamic>> items,
  ) async {
    try {
      final res = await _client.post<Map<String, dynamic>>(
        '/me/seller/tools/library/publish',
        data: {'items': items},
      );
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<void> setVacation(bool enabled) async {
    try {
      await _client.put(
        '/me/seller/tools/vacation',
        data: {'enabled': enabled},
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<SellerVacationSettings> fetchVacation() async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/me/seller/tools/vacation',
      );
      return SellerVacationSettings.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<SellerVacationSettings> putVacation({
    required bool enabled,
    DateTime? startsAt,
    DateTime? endsAt,
    bool hideListings = true,
    String? autoReplyMessage,
  }) async {
    try {
      final res = await _client.put<Map<String, dynamic>>(
        '/me/seller/tools/vacation',
        data: {
          'enabled': enabled,
          if (startsAt != null) 'startsAt': startsAt.toUtc().toIso8601String(),
          if (endsAt != null) 'endsAt': endsAt.toUtc().toIso8601String(),
          'hideListings': hideListings,
          if (autoReplyMessage != null) 'autoReplyMessage': autoReplyMessage,
        },
      );
      return SellerVacationSettings.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<SellerBundleSettings> fetchBundles() async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/me/seller/tools/bundles',
      );
      return SellerBundleSettings.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<SellerBundleSettings> putBundles({
    required bool enabled,
    required int minItems,
    required int discountPercent,
  }) async {
    try {
      final res = await _client.put<Map<String, dynamic>>(
        '/me/seller/tools/bundles',
        data: {
          'enabled': enabled,
          'minItems': minItems,
          'discountPercent': discountPercent,
        },
      );
      return SellerBundleSettings.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<List<int>> downloadExcelTemplate() async {
    try {
      final res = await _client.get<List<int>>(
        '/me/seller/tools/excel-template',
        options: Options(responseType: ResponseType.bytes),
      );
      final data = res.data;
      if (data == null) return const [];
      return List<int>.from(data);
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ExcelImportResult> uploadExcelImport({
    required List<int> bytes,
    required String filename,
  }) async {
    try {
      final form = FormData.fromMap({
        'file': MultipartFile.fromBytes(bytes, filename: filename),
      });
      final res = await _client.post<Map<String, dynamic>>(
        '/me/seller/tools/excel-import/upload',
        data: form,
      );
      return ExcelImportResult.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ExcelImportMeta> fetchExcelImportMeta() async {
    try {
      final res = await _client.get<Map<String, dynamic>>(
        '/me/seller/tools/excel-import/meta',
      );
      return ExcelImportMeta.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<Map<String, dynamic>> listingTaxonomy() async {
    try {
      final res =
          await _client.get<Map<String, dynamic>>('/catalog/listing-taxonomy');
      return Map<String, dynamic>.from(res.data ?? {});
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}

class SellerVacationSettings {
  const SellerVacationSettings({
    this.enabled = false,
    this.startsAt,
    this.endsAt,
    this.hideListings = true,
    this.autoReplyMessage,
  });

  final bool enabled;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final bool hideListings;
  final String? autoReplyMessage;

  factory SellerVacationSettings.fromJson(Map<String, dynamic> json) {
    DateTime? parse(dynamic v) {
      if (v == null) return null;
      return DateTime.tryParse(v.toString())?.toLocal();
    }

    return SellerVacationSettings(
      enabled: json['enabled'] == true,
      startsAt: parse(json['startsAt']),
      endsAt: parse(json['endsAt']),
      hideListings: json['hideListings'] != false,
      autoReplyMessage: json['autoReplyMessage']?.toString(),
    );
  }
}

class SellerBundleSettings {
  const SellerBundleSettings({
    this.enabled = false,
    this.minItems = 2,
    this.discountPercent = 10,
  });

  final bool enabled;
  final int minItems;
  final int discountPercent;

  factory SellerBundleSettings.fromJson(Map<String, dynamic> json) {
    int n(dynamic v, int fallback) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? fallback;
    return SellerBundleSettings(
      enabled: json['enabled'] == true,
      minItems: n(json['minItems'], 2),
      discountPercent: n(json['discountPercent'], 10),
    );
  }
}

class ExcelImportResult {
  const ExcelImportResult({
    this.jobId,
    this.imported = 0,
    this.updated = 0,
    this.failed = 0,
    this.errors = const [],
    this.lastImportAt,
  });

  final String? jobId;
  final int imported;
  final int updated;
  final int failed;
  final List<ExcelImportError> errors;
  final DateTime? lastImportAt;

  factory ExcelImportResult.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    final rawErrors = json['errors'];
    return ExcelImportResult(
      jobId: json['jobId']?.toString(),
      imported: n(json['imported']),
      updated: n(json['updated']),
      failed: n(json['failed']),
      errors: [
        if (rawErrors is List)
          for (final e in rawErrors)
            if (e is Map)
              ExcelImportError.fromJson(Map<String, dynamic>.from(e)),
      ],
      lastImportAt: json['lastImportAt'] != null
          ? DateTime.tryParse(json['lastImportAt'].toString())
          : null,
    );
  }
}

class ExcelImportError {
  const ExcelImportError({
    this.row,
    this.sku,
    this.code,
    this.message,
  });

  final int? row;
  final String? sku;
  final String? code;
  final String? message;

  factory ExcelImportError.fromJson(Map<String, dynamic> json) {
    return ExcelImportError(
      row: json['row'] is num
          ? (json['row'] as num).toInt()
          : int.tryParse('${json['row']}'),
      sku: json['sku']?.toString(),
      code: json['code']?.toString(),
      message: json['message']?.toString(),
    );
  }
}

class ExcelImportMeta {
  const ExcelImportMeta({
    this.lastImportAt,
    this.lastFileName,
    this.imported = 0,
    this.updated = 0,
    this.failed = 0,
  });

  final DateTime? lastImportAt;
  final String? lastFileName;
  final int imported;
  final int updated;
  final int failed;

  factory ExcelImportMeta.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) => v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    final summary = json['lastSummary'];
    final summaryMap =
        summary is Map ? Map<String, dynamic>.from(summary) : const {};
    return ExcelImportMeta(
      lastImportAt: json['lastImportAt'] != null
          ? DateTime.tryParse(json['lastImportAt'].toString())
          : null,
      lastFileName: json['lastFileName']?.toString(),
      imported: n(summaryMap['imported']),
      updated: n(summaryMap['updated']),
      failed: n(summaryMap['failed']),
    );
  }
}
