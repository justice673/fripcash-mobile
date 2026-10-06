import 'package:dio/dio.dart';
import 'package:frip_cash/api/api_client.dart';
import 'package:frip_cash/api/listings_api.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/models/seller_type.dart';

int _int(dynamic v) {
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse('$v') ?? 0;
}

bool _isProximityShopKind(String? raw) {
  final s = (raw ?? '').toLowerCase();
  return s.contains('proxim');
}

/// Server cart line mapped for Flutter UI.
class ApiCartItem {
  const ApiCartItem({
    required this.id,
    required this.listingId,
    required this.sellerProfileId,
    required this.sellerName,
    required this.shopKind,
    required this.title,
    required this.coverUrl,
    required this.unitDisplayPriceGnf,
    required this.quantity,
    required this.stockAvailable,
    required this.inStock,
    required this.shippingCostGnf,
    this.brand,
    this.destination,
  });

  final String id;
  final String listingId;
  final String sellerProfileId;
  final String sellerName;
  final String shopKind;
  final String title;
  final String? brand;
  final String coverUrl;
  final int unitDisplayPriceGnf;
  final int quantity;
  final int stockAvailable;
  final bool inStock;
  final int shippingCostGnf;
  final String? destination;

  bool get isProximity => _isProximityShopKind(shopKind);

  factory ApiCartItem.fromJson(Map<String, dynamic> json) {
    return ApiCartItem(
      id: (json['id'] ?? '').toString(),
      listingId: (json['listingId'] ?? '').toString(),
      sellerProfileId: (json['sellerProfileId'] ?? json['sellerId'] ?? '')
          .toString(),
      sellerName: (json['sellerName'] ?? '').toString(),
      shopKind: (json['shopKind'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      brand: json['brand']?.toString(),
      coverUrl: (json['coverUrl'] ?? json['imageUrl'] ?? '').toString(),
      unitDisplayPriceGnf: _int(json['unitDisplayPriceGnf'] ?? json['priceGnf']),
      quantity: _int(json['quantity'] ?? 1),
      stockAvailable: _int(json['stockAvailable'] ?? json['stock'] ?? 0),
      inStock: json['inStock'] != false,
      shippingCostGnf: _int(json['shippingCostGnf'] ?? 0),
      destination: json['destination']?.toString(),
    );
  }

  Product toProduct() {
    final dest = listingDestinationFromApi(destination);
    final proximity =
        isProximity || dest == ListingDestination.quartierBoutiques;
    return Product(
      id: listingId,
      title: title,
      price: unitDisplayPriceGnf,
      image: coverUrl,
      size: 'One size',
      categoryId: 'mode',
      sellerId: sellerProfileId,
      sellerType: proximity ? SellerType.boutique : SellerType.particulier,
      stock: inStock ? (stockAvailable > 0 ? stockAvailable : quantity) : 0,
      brand: brand,
      shippingCost: shippingCostGnf,
      badge: proximity ? 'Proximité' : null,
      destination: dest,
    );
  }
}

class ApiCart {
  const ApiCart({
    required this.id,
    required this.buyerUserId,
    required this.revision,
    required this.currency,
    required this.items,
    required this.subtotalEstimateGnf,
    required this.shippingEstimateGnf,
    required this.grandEstimateGnf,
    this.updatedAt,
  });

  final String id;
  final String buyerUserId;
  final String revision;
  final String currency;
  final List<ApiCartItem> items;
  final int subtotalEstimateGnf;
  final int shippingEstimateGnf;
  final int grandEstimateGnf;
  final String? updatedAt;

  factory ApiCart.fromJson(Map<String, dynamic> json) {
    final rawItems = json['items'];
    final items = <ApiCartItem>[];
    if (rawItems is List) {
      for (final item in rawItems) {
        if (item is Map) {
          items.add(ApiCartItem.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return ApiCart(
      id: (json['id'] ?? '').toString(),
      buyerUserId: (json['buyerUserId'] ?? '').toString(),
      revision: (json['revision'] ?? '').toString(),
      currency: (json['currency'] ?? 'GNF').toString(),
      items: items,
      subtotalEstimateGnf: _int(json['subtotalEstimateGnf']),
      shippingEstimateGnf: _int(json['shippingEstimateGnf']),
      grandEstimateGnf: _int(json['grandEstimateGnf']),
      updatedAt: json['updatedAt']?.toString(),
    );
  }
}

class CartValidationIssue {
  const CartValidationIssue({
    required this.code,
    this.listingId,
    this.itemId,
    this.oldPrice,
    this.newPrice,
    this.stock,
    this.quantity,
  });

  final String code;
  final String? listingId;
  final String? itemId;
  final int? oldPrice;
  final int? newPrice;
  final int? stock;
  final int? quantity;

  factory CartValidationIssue.fromJson(Map<String, dynamic> json) {
    return CartValidationIssue(
      code: (json['code'] ?? 'UNKNOWN').toString(),
      listingId: json['listingId']?.toString(),
      itemId: json['itemId']?.toString(),
      oldPrice: json['oldPrice'] != null ? _int(json['oldPrice']) : null,
      newPrice: json['newPrice'] != null ? _int(json['newPrice']) : null,
      stock: json['stock'] != null ? _int(json['stock']) : null,
      quantity: json['quantity'] != null ? _int(json['quantity']) : null,
    );
  }
}

class CartValidationResult {
  const CartValidationResult({
    required this.ok,
    required this.revision,
    required this.issues,
    this.cart,
  });

  final bool ok;
  final String revision;
  final List<CartValidationIssue> issues;
  final ApiCart? cart;

  factory CartValidationResult.fromJson(Map<String, dynamic> json) {
    final rawIssues = json['issues'];
    final issues = <CartValidationIssue>[];
    if (rawIssues is List) {
      for (final issue in rawIssues) {
        if (issue is Map) {
          issues.add(
            CartValidationIssue.fromJson(Map<String, dynamic>.from(issue)),
          );
        }
      }
    }
    final cartRaw = json['cart'];
    return CartValidationResult(
      ok: json['ok'] == true,
      revision: (json['revision'] ?? '').toString(),
      issues: issues,
      cart: cartRaw is Map
          ? ApiCart.fromJson(Map<String, dynamic>.from(cartRaw))
          : null,
    );
  }
}

class CartApi {
  CartApi._();
  static final CartApi instance = CartApi._();

  final _client = ApiClient.instance;

  Future<ApiCart> getCart() async {
    try {
      final res = await _client.get<Map<String, dynamic>>('/cart');
      return ApiCart.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiCart> addItem({
    required String listingId,
    int? quantity,
    String? offerId,
    String? checkoutToken,
  }) async {
    try {
      final body = <String, dynamic>{'listingId': listingId};
      if (quantity != null) body['quantity'] = quantity;
      if (offerId != null && offerId.isNotEmpty) body['offerId'] = offerId;
      if (checkoutToken != null && checkoutToken.isNotEmpty) {
        body['checkoutToken'] = checkoutToken;
      }
      final res = await _client.post<Map<String, dynamic>>(
        '/cart/items',
        data: body,
      );
      return ApiCart.fromJson(Map<String, dynamic>.from(res.data ?? {}));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiCart> updateItemQuantity({
    required String itemId,
    required int quantity,
  }) async {
    try {
      final res = await _client.patch<Map<String, dynamic>>(
        '/cart/items/$itemId',
        data: {'quantity': quantity},
      );
      final data = res.data;
      if (data == null || data.isEmpty) return getCart();
      return ApiCart.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiCart> removeItem(String itemId) async {
    try {
      final res =
          await _client.delete<Map<String, dynamic>>('/cart/items/$itemId');
      final data = res.data;
      if (data == null || data.isEmpty) return getCart();
      return ApiCart.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<ApiCart> clearCart() async {
    try {
      final res = await _client.delete<Map<String, dynamic>>('/cart');
      final data = res.data;
      if (data == null || data.isEmpty) {
        return const ApiCart(
          id: '',
          buyerUserId: '',
          revision: '',
          currency: 'GNF',
          items: [],
          subtotalEstimateGnf: 0,
          shippingEstimateGnf: 0,
          grandEstimateGnf: 0,
        );
      }
      return ApiCart.fromJson(Map<String, dynamic>.from(data));
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }

  Future<CartValidationResult> validate() async {
    try {
      final res =
          await _client.post<Map<String, dynamic>>('/cart/validate', data: {});
      return CartValidationResult.fromJson(
        Map<String, dynamic>.from(res.data ?? {}),
      );
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    }
  }
}
