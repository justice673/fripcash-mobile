import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/services/seller_verification_service.dart';

class MockShop {
  const MockShop({
    required this.id,
    required this.name,
    required this.logoUrl,
    required this.description,
    required this.rating,
    required this.reviewCount,
    required this.deliverySla,
    required this.sellerId,
    this.type = SellerType.boutique,
    this.trustBadges = const [],
    this.addressLine,
    this.coverImageUrl,
    this.enseigneCategoryId,
    this.deliveryHours = 24,
    this.deliverableZoneIds = const ['zone_1', 'zone_2'],
    this.quartier,
    this.commune,
    this.walkMinutes,
    this.productCount,
    this.opensAtHour,
    this.pickupByCode = false,
  });

  final String id;
  final String name;
  final String logoUrl;
  final String description;
  final double rating;
  final int reviewCount;
  final String deliverySla;
  final String sellerId;
  final SellerType type;
  final List<String> trustBadges;
  /// Street / neighborhood line for in-store pickup cards.
  final String? addressLine;
  /// Hero image on enseigne listing cards (falls back to [logoUrl]).
  final String? coverImageUrl;
  /// What the enseigne sells — see [enseigneCategoryIds].
  final String? enseigneCategoryId;
  /// Express delivery window in hours (for sorting).
  final int deliveryHours;
  /// Zones where this enseigne can deliver.
  final List<String> deliverableZoneIds;

  /// Neighborhood-shop fields (boutiques de quartier).
  final String? quartier;
  final String? commune;
  final int? walkMinutes;
  final int? productCount;
  final int? opensAtHour;
  final bool pickupByCode;

  String get heroImageUrl => coverImageUrl ?? logoUrl;

  bool deliversToZone(String zoneId) => deliverableZoneIds.contains(zoneId);

  bool get isQuartierShop => quartier != null;
}

const mockPopularShops = <MockShop>[
  MockShop(
    id: 'shop_ibrahim',
    name: 'Ibrahim Shop',
    logoUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1441986300917-64676bd600d8?w=800&h=400&fit=crop',
    description: 'Chaussures et accessoires pour toute la famille.',
    rating: 4.7,
    reviewCount: 54,
    deliverySla: '48h',
    sellerId: 'seller_ibrahim',
    addressLine: 'Kipé, Ratoma',
    trustBadges: ['Livraison rapide'],
  ),
  MockShop(
    id: 'shop_mariam',
    name: 'Mariam Mode',
    logoUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1441986300917-64676bd600d8?w=800&h=400&fit=crop',
    description: 'Prêt-à-porter et accessoires',
    rating: 5,
    reviewCount: 86,
    deliverySla: '24h',
    sellerId: 'seller_mariam',
    addressLine: 'Kipé, Ratoma',
    trustBadges: ['Publications fréquentes', 'Vendeur vérifié'],
  ),
  MockShop(
    id: 'shop_mode_plus',
    name: 'Mode Plus GN',
    logoUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1441986300917-64676bd600d8?w=800&h=400&fit=crop',
    description: 'Chaussures et maroquinerie',
    rating: 4.4,
    reviewCount: 23,
    deliverySla: '48h',
    sellerId: 'seller_mode_plus',
    addressLine: 'Lambanyi, Ratoma',
  ),
  MockShop(
    id: 'shop_kipe',
    name: 'Alimentation Bah',
    logoUrl:
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
    description: 'Épicerie et produits secs',
    rating: 4.8,
    reviewCount: 112,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_quartier',
    trustBadges: ['Boutique de proximité', '5% commission'],
    addressLine: 'rue du marché',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 4,
    productCount: 214,
    opensAtHour: 8,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_madina_epicerie',
    name: 'Chez Aïssatou Madina',
    logoUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&h=400&fit=crop',
    description: 'Épicerie et produits du quotidien',
    rating: 4.6,
    reviewCount: 14,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_madina_epicerie',
    trustBadges: ['Boutique de proximité'],
    addressLine: 'marché central',
    quartier: 'Madina',
    commune: 'Matoto',
    walkMinutes: 6,
    productCount: 98,
    opensAtHour: 7,
    pickupByCode: true,
  ),
];

/// Boutiques de quartier — pickup by code, filtered by neighborhood.
const mockQuartierShops = <MockShop>[
  MockShop(
    id: 'shop_kipe',
    name: 'Alimentation Bah',
    logoUrl:
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
    description: 'Épicerie et produits secs',
    rating: 4.8,
    reviewCount: 112,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_quartier',
    trustBadges: ['Boutique de proximité'],
    addressLine: 'rue du marché',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 4,
    productCount: 214,
    opensAtHour: 8,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_fatou_kipe',
    name: 'Chez Fatou',
    logoUrl:
        'https://images.unsplash.com/photo-1578916171728-46686e9ac587?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1578916171728-46686e9ac587?w=800&h=400&fit=crop',
    description: 'Entretien et boissons',
    rating: 4.5,
    reviewCount: 67,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_fatou_kipe',
    addressLine: 'angle rue 12',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 7,
    productCount: 156,
    opensAtHour: 8,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_sory_kipe',
    name: 'Sory Market',
    logoUrl:
        'https://images.unsplash.com/photo-1601593346740-925612772716?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1601593346740-925612772716?w=800&h=400&fit=crop',
    description: 'Épicerie et produits secs',
    rating: 4.3,
    reviewCount: 41,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_sory_kipe',
    addressLine: 'près du carrefour',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 9,
    productCount: 178,
    opensAtHour: 7,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_diallo_kipe',
    name: 'Épicerie Diallo',
    logoUrl:
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1586201375761-83865001e31c?w=800&h=400&fit=crop',
    description: 'Riz, huile et conserves',
    rating: 4.7,
    reviewCount: 89,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_diallo_kipe',
    addressLine: 'marché Kipé',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 5,
    productCount: 192,
    opensAtHour: 8,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_mariam_kipe',
    name: 'Boutique Mariam',
    logoUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&h=400&fit=crop',
    description: 'Produits frais et surgelés',
    rating: 4.6,
    reviewCount: 53,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_mariam_kipe',
    addressLine: 'rue principale',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 6,
    productCount: 134,
    opensAtHour: 9,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_alpha_kipe',
    name: 'Alpha Provisions',
    logoUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=400&fit=crop',
    description: 'Épicerie générale',
    rating: 4.4,
    reviewCount: 36,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_alpha_kipe',
    addressLine: 'lot 24',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 11,
    productCount: 167,
    opensAtHour: 8,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_saliou_kipe',
    name: 'Chez Saliou',
    logoUrl:
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1558618666-fcd25c85cd64?w=800&h=400&fit=crop',
    description: 'Boissons et snacks',
    rating: 4.2,
    reviewCount: 29,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_saliou_kipe',
    addressLine: 'face mosquée',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 8,
    productCount: 88,
    opensAtHour: 7,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_nene_kipe',
    name: 'Néné Shop',
    logoUrl:
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1578662996442-48f60103fc96?w=800&h=400&fit=crop',
    description: 'Entretien et hygiène',
    rating: 4.9,
    reviewCount: 24,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_nene_kipe',
    addressLine: 'ruelle 3',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 3,
    productCount: 76,
    opensAtHour: 8,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_ousmane_kipe',
    name: 'Ousmane Épicerie',
    logoUrl:
        'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=800&h=400&fit=crop',
    description: 'Épicerie et produits secs',
    rating: 4.1,
    reviewCount: 18,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_ousmane_kipe',
    addressLine: 'derrière l\'école',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 12,
    productCount: 142,
    opensAtHour: 8,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_kadiatou_kipe',
    name: 'Kadiatou Market',
    logoUrl:
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=800&h=400&fit=crop',
    description: 'Petit-déjeuner et épicerie',
    rating: 4.5,
    reviewCount: 44,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_kadiatou_kipe',
    addressLine: 'station Total',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 10,
    productCount: 121,
    opensAtHour: 6,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_ibrahim_kipe',
    name: 'Ibrahim Proxi',
    logoUrl:
        'https://images.unsplash.com/photo-1601593346740-925612772716?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1601593346740-925612772716?w=800&h=400&fit=crop',
    description: 'Épicerie de nuit',
    rating: 4.0,
    reviewCount: 15,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_ibrahim_kipe',
    addressLine: 'carrefour Kipé',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 5,
    productCount: 95,
    opensAtHour: 18,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_fanta_kipe',
    name: 'Fanta Boutique',
    logoUrl:
        'https://images.unsplash.com/photo-1578916171728-46686e9ac587?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1578916171728-46686e9ac587?w=800&h=400&fit=crop',
    description: 'Entretien et boissons',
    rating: 4.6,
    reviewCount: 32,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_fanta_kipe',
    addressLine: 'rue du stade',
    quartier: 'Kipé',
    commune: 'Ratoma',
    walkMinutes: 13,
    productCount: 108,
    opensAtHour: 8,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_madina_epicerie',
    name: 'Chez Aïssatou Madina',
    logoUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&h=400&fit=crop',
    description: 'Épicerie et produits du quotidien',
    rating: 4.6,
    reviewCount: 14,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_madina_epicerie',
    addressLine: 'marché central',
    quartier: 'Madina',
    commune: 'Matoto',
    walkMinutes: 6,
    productCount: 98,
    opensAtHour: 7,
    pickupByCode: true,
  ),
  MockShop(
    id: 'shop_lambanyi_1',
    name: 'Provisions Lambanyi',
    logoUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1542838132-92c53300491e?w=800&h=400&fit=crop',
    description: 'Épicerie générale',
    rating: 4.3,
    reviewCount: 22,
    deliverySla: 'Retrait / proximité',
    sellerId: 'seller_lambanyi_1',
    addressLine: 'marché Lambanyi',
    quartier: 'Lambanyi',
    commune: 'Ratoma',
    walkMinutes: 5,
    productCount: 115,
    opensAtHour: 8,
    pickupByCode: true,
  ),
];

/// Neighborhood shops in [quartier], sorted by walking distance.
List<MockShop> quartierShopsForNeighborhood(String quartier) {
  final verification = SellerVerificationService.instance;
  final list = mockQuartierShops
      .where(
        (s) =>
            s.quartier == quartier &&
            verification.isDirectoryVisible(s.sellerId),
      )
      .toList(growable: false);
  list.sort(
    (a, b) => (a.walkMinutes ?? 99).compareTo(b.walkMinutes ?? 99),
  );
  return list;
}

String communeLabelForQuartier(String quartier, MockShop? sample) {
  if (sample?.commune != null) return sample!.commune!;
  return switch (quartier) {
    'Kaloum' => 'Kaloum',
    'Madina' || 'Matoto' => 'Matoto',
    'Dixinn' => 'Dixinn',
    _ => 'Ratoma',
  };
}

const mockPartnerBrands = <MockShop>[
  MockShop(
    id: 'brand_carrefour_kaloum',
    name: 'Carrefour Kaloum',
    logoUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=800&h=400&fit=crop',
    description: 'Épicerie et produits frais',
    rating: 4.4,
    reviewCount: 128,
    deliverySla: '2h',
    deliveryHours: 2,
    sellerId: 'seller_carrefour',
    type: SellerType.enseigne,
    enseigneCategoryId: 'grocery',
    addressLine: 'Kaloum, av. de la République',
    trustBadges: ['Enseigne partenaire'],
    deliverableZoneIds: ['zone_1'],
  ),
  MockShop(
    id: 'brand_tech',
    name: 'Tech Guinée',
    logoUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1550009158-9ebf69173e03?w=800&h=400&fit=crop',
    description: 'Électroménager et high-tech',
    rating: 4.6,
    reviewCount: 31,
    deliverySla: '4h',
    deliveryHours: 4,
    sellerId: 'seller_tech',
    type: SellerType.enseigne,
    enseigneCategoryId: 'appliances',
    addressLine: 'Dixinn, près du rond-point',
    trustBadges: ['Enseigne partenaire'],
    deliverableZoneIds: ['zone_1', 'zone_2'],
  ),
  MockShop(
    id: 'brand_imperial',
    name: 'Impérial Store',
    logoUrl:
        'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1513506003901-1e6a229e2d15?w=800&h=400&fit=crop',
    description: 'Luminaires, déco et maison',
    rating: 4.2,
    reviewCount: 89,
    deliverySla: '24h',
    deliveryHours: 24,
    sellerId: 'seller_imperial',
    type: SellerType.enseigne,
    enseigneCategoryId: 'lighting',
    addressLine: 'Lambanyi, centre commercial',
    trustBadges: ['Enseigne partenaire'],
    deliverableZoneIds: ['zone_1', 'zone_2'],
  ),
  MockShop(
    id: 'brand_maison_plus',
    name: 'Maison Plus',
    logoUrl:
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=800&h=400&fit=crop',
    description: 'Décoration et équipement maison',
    rating: 4.5,
    reviewCount: 56,
    deliverySla: '4h',
    deliveryHours: 4,
    sellerId: 'seller_maison_plus',
    type: SellerType.enseigne,
    enseigneCategoryId: 'home',
    addressLine: 'Matoto, marché',
    trustBadges: ['Enseigne partenaire'],
    deliverableZoneIds: ['zone_2'],
  ),
  MockShop(
    id: 'brand_mode_express',
    name: 'Mode Express GN',
    logoUrl:
        'https://images.unsplash.com/photo-1441986300917-64676bd600d8?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1441986300917-64676bd600d8?w=800&h=400&fit=crop',
    description: 'Mode et accessoires — livraison express',
    rating: 4.3,
    reviewCount: 74,
    deliverySla: '2h',
    deliveryHours: 2,
    sellerId: 'seller_mode_express',
    type: SellerType.enseigne,
    enseigneCategoryId: 'mode',
    addressLine: 'Ratoma, centre-ville',
    trustBadges: ['Enseigne partenaire'],
    deliverableZoneIds: ['zone_1', 'zone_2'],
  ),
  MockShop(
    id: 'brand_epicerie_express',
    name: 'Épicerie Express',
    logoUrl:
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=200&h=200&fit=crop',
    coverImageUrl:
        'https://images.unsplash.com/photo-1556742049-0cfed4f6a45d?w=800&h=400&fit=crop',
    description: 'Courses et petit-déjeuner',
    rating: 4.7,
    reviewCount: 203,
    deliverySla: '2h',
    deliveryHours: 2,
    sellerId: 'seller_epicerie_express',
    type: SellerType.enseigne,
    enseigneCategoryId: 'grocery',
    addressLine: 'Kipé, près du marché',
    trustBadges: ['Enseigne partenaire'],
    deliverableZoneIds: ['zone_1'],
  ),
];

/// Partner stores that deliver to [zoneId], optionally filtered by category.
List<MockShop> enseignesForZone(
  String zoneId, {
  String categoryId = 'all',
}) {
  final verification = SellerVerificationService.instance;
  var list = mockPartnerBrands
      .where(
        (s) => s.deliversToZone(zoneId) && verification.isDirectoryVisible(s.sellerId),
      )
      .toList();
  if (categoryId != 'all') {
    list = list
        .where((s) => s.enseigneCategoryId == categoryId)
        .toList(growable: false);
  }
  list.sort((a, b) => a.deliveryHours.compareTo(b.deliveryHours));
  return list;
}

MockShop? shopBySellerId(String sellerId) {
  for (final shop in [
    ...mockPopularShops,
    ...mockPartnerBrands,
    ...mockQuartierShops,
  ]) {
    if (shop.sellerId == sellerId) return shop;
  }
  return null;
}