import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/models/shop_kind.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/utils/listing_routing.dart';

enum UserRole { acheteur, vendeurParticulier, boutique, livreur, admin }

class MockUser {
  const MockUser({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.zoneId,
    this.address,
    this.deliverySla,
    this.shopName,
    this.shopKind,
    this.shopCategory,
    this.sellerProfileId,
    this.canBuy = true,
    this.canCreateListing = false,
  });

  final String id;
  final String name;
  final String phone;
  final UserRole role;
  final String? zoneId;
  final String? address;
  final String? deliverySla;
  final String? shopName;

  /// Only set for boutiques — proximite vs classic.
  final ShopKind? shopKind;

  /// e.g. "Épicerie sèche" for neighborhood shops.
  final String? shopCategory;

  /// Backend seller profile id when known from `GET /v1/me`.
  final String? sellerProfileId;

  final bool canBuy;
  final bool canCreateListing;

  SellerType? get sellerType => switch (role) {
        UserRole.vendeurParticulier => SellerType.particulier,
        UserRole.boutique => shopKind == ShopKind.enseigne
            ? SellerType.enseigne
            : SellerType.boutique,
        _ => null,
      };

  bool get isProximityShop =>
      role == UserRole.boutique && shopKind == ShopKind.proximite;

  bool get isPartnerEnseigne =>
      role == UserRole.boutique && shopKind == ShopKind.enseigne;

  ListingDestination get listingDestination => listingDestinationForUser(this);

  /// Maps user id to marketplace seller id (e.g. `user_session` → `seller_session`).
  String get sellerId =>
      sellerProfileId ?? 'seller_${id.replaceFirst('user_', '')}';

  bool get hasShop => role == UserRole.boutique && shopName != null;

  /// Livreur id for courier dashboard (`user_courier_a` → `courier_a`).
  String? get courierId =>
      role == UserRole.livreur ? id.replaceFirst('user_', '') : null;
}

extension UserRoleLabel on UserRole {
  bool get isSeller =>
      this == UserRole.vendeurParticulier || this == UserRole.boutique;
}

const mockUsers = <MockUser>[
  MockUser(
    id: 'user_marine',
    name: 'marinebchenais',
    phone: '+224 620 12 34 56',
    role: UserRole.acheteur,
    zoneId: 'zone_1',
    address: 'Kipé, près du marché',
  ),
  MockUser(
    id: 'user_aminata',
    name: 'aminata_v',
    phone: '+224 621 11 22 33',
    role: UserRole.vendeurParticulier,
    zoneId: 'zone_1',
    address: 'Lambanyi, rue 12',
    deliverySla: '24h',
  ),
  MockUser(
    id: 'user_ibrahim',
    name: 'ibrahim_shop',
    phone: '+224 622 22 33 44',
    role: UserRole.boutique,
    zoneId: 'zone_2',
    address: 'Madina centre',
    deliverySla: '48h',
    shopName: 'Ibrahim Shop',
    shopKind: ShopKind.standard,
  ),
  MockUser(
    id: 'user_quartier',
    name: 'epicerie_kipé',
    phone: '+224 623 00 11 22',
    role: UserRole.boutique,
    zoneId: 'zone_1',
    address: 'Kipé, marché central',
    deliverySla: '24h',
    shopName: 'Épicerie Kipé',
    shopKind: ShopKind.proximite,
    shopCategory: 'Épicerie sèche',
  ),
  MockUser(
    id: 'user_courier_a',
    name: 'Mamadou K.',
    phone: '+224 628 88 99 00',
    role: UserRole.livreur,
    zoneId: 'zone_1',
    canBuy: false,
    canCreateListing: false,
  ),
];

MockUser? userById(String id) {
  for (final user in mockUsers) {
    if (user.id == id) return user;
  }
  return null;
}

MockUser? userBySellerId(String sellerId) {
  for (final user in mockUsers) {
    if (user.sellerId == sellerId) return user;
  }
  return null;
}
