import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/models/shop_kind.dart';

/// Parsed `GET /api/v1/me` (and courier shape overlap).
class MeResponse {
  const MeResponse({
    required this.id,
    required this.displayName,
    required this.phone,
    required this.role,
    this.canBuy = true,
    this.zoneId,
    this.address,
    this.deliverySla,
    this.shopName,
    this.shopKind,
    this.shopCategory,
    this.sellerProfileId,
    this.canCreateListing = false,
    this.verificationStatus,
    this.productLibrary = false,
    this.excelImport = false,
    this.isCourier = false,
    this.courierId,
    this.raw = const {},
  });

  final String id;
  final String displayName;
  final String phone;
  final UserRole role;
  final bool canBuy;
  final String? zoneId;
  final String? address;
  final String? deliverySla;
  final String? shopName;
  final ShopKind? shopKind;
  final String? shopCategory;
  final String? sellerProfileId;
  final bool canCreateListing;
  final String? verificationStatus;
  final bool productLibrary;
  final bool excelImport;
  final bool isCourier;
  final String? courierId;
  final Map<String, dynamic> raw;

  bool get isVerificationPending =>
      verificationStatus == 'pending' || verificationStatus == 'PENDING';

  MockUser toMockUser() => MockUser(
        id: id,
        name: displayName,
        phone: phone,
        role: role,
        zoneId: zoneId,
        address: address,
        deliverySla: deliverySla,
        shopName: shopName,
        shopKind: shopKind,
        shopCategory: shopCategory,
        sellerProfileId: sellerProfileId,
        canBuy: canBuy,
        canCreateListing: canCreateListing,
      );

  factory MeResponse.fromJson(Map<String, dynamic> json) {
    final seller = _asMap(json['seller']);
    final caps = _asMap(seller['capabilities']);
    final shop = _asMap(seller['shop'] ?? json['shop']);

    final roleStr = (json['role'] ?? seller['role'] ?? 'acheteur').toString();
    final isCourier = roleStr == 'livreur' ||
        roleStr == 'courier' ||
        json['audience']?.toString().toUpperCase() == 'COURIER';

    final shopKindStr =
        (seller['shopKind'] ?? shop['kind'] ?? shop['shopKind'] ?? '')
            .toString()
            .toLowerCase();
    ShopKind? shopKind;
    if (shopKindStr.contains('proxim')) {
      shopKind = ShopKind.proximite;
    } else if (shopKindStr.contains('enseigne') ||
        shopKindStr.contains('partner')) {
      shopKind = ShopKind.enseigne;
    } else if (roleStr.contains('boutique') ||
        roleStr.contains('shop') ||
        seller.isNotEmpty) {
      if (roleStr.contains('particulier')) {
        shopKind = null;
      } else if (shopKindStr.isNotEmpty ||
          roleStr.contains('boutique') ||
          roleStr.contains('enseigne') ||
          roleStr.contains('proxim')) {
        shopKind = ShopKind.standard;
        if (shopKindStr.contains('proxim')) shopKind = ShopKind.proximite;
        if (shopKindStr.contains('enseigne')) shopKind = ShopKind.enseigne;
      }
    }

    UserRole role;
    if (isCourier) {
      role = UserRole.livreur;
    } else if (roleStr.contains('particulier') ||
        roleStr == 'vendeurParticulier') {
      role = UserRole.vendeurParticulier;
    } else if (roleStr.contains('boutique') ||
        roleStr.contains('enseigne') ||
        roleStr.contains('proxim') ||
        roleStr.contains('shop') ||
        shopKind != null) {
      role = UserRole.boutique;
    } else if (seller.isNotEmpty &&
        (caps['createListing'] == true || seller['id'] != null)) {
      // Seller object present without clear role string.
      role = shopKind != null
          ? UserRole.boutique
          : UserRole.vendeurParticulier;
    } else {
      role = UserRole.acheteur;
    }

    // Refine boutique shopKind from role string.
    if (role == UserRole.boutique) {
      if (roleStr.contains('proxim') || shopKindStr.contains('proxim')) {
        shopKind = ShopKind.proximite;
      } else if (roleStr.contains('enseigne')) {
        shopKind = ShopKind.enseigne;
      } else {
        shopKind ??= ShopKind.standard;
      }
    }

    final createListing = caps['createListing'] == true ||
        json['canCreateListing'] == true;
    final productLibrary = caps['productLibrary'] == true;
    final excelImport = caps['excelImport'] == true;

    return MeResponse(
      id: (json['id'] ?? json['userId'] ?? '').toString(),
      displayName: (json['displayName'] ??
              json['name'] ??
              shop['name'] ??
              seller['shopName'] ??
              '')
          .toString(),
      phone: (json['phone'] ?? json['phoneNumber'] ?? '').toString(),
      role: role,
      canBuy: json['canBuy'] != false && !isCourier,
      zoneId: (json['zoneId'] ?? seller['zoneId'] ?? shop['zoneId'])
          ?.toString(),
      address: (json['address'] ?? seller['address'] ?? shop['address'])
          ?.toString(),
      deliverySla:
          (json['deliverySla'] ?? seller['deliverySla'] ?? shop['deliverySla'])
              ?.toString(),
      shopName: (shop['name'] ??
              seller['shopName'] ??
              json['shopName'])
          ?.toString(),
      shopKind: shopKind,
      shopCategory: (seller['shopCategoryId'] ??
              shop['categoryId'] ??
              seller['shopCategory'])
          ?.toString(),
      sellerProfileId: (seller['id'] ?? seller['profileId'])?.toString(),
      canCreateListing: createListing,
      verificationStatus:
          (seller['verificationStatus'] ?? json['verificationStatus'])
              ?.toString(),
      productLibrary: productLibrary,
      excelImport: excelImport,
      isCourier: isCourier,
      courierId: (json['courierId'] ?? seller['courierId'])?.toString(),
      raw: json,
    );
  }

  static Map<String, dynamic> _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return {};
  }
}
