import 'package:frip_cash/models/seller.dart';
import 'package:frip_cash/models/seller_type.dart';

const defaultSeller = SellerInfo(
  id: 'seller_default',
  username: 'fripcash_user',
  avatarUrl:
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
  rating: 4.8,
  reviewCount: 24,
  phone: '+224 620 00 00 00',
);

const sellersById = <String, SellerInfo>{
  'seller_aminata': SellerInfo(
    id: 'seller_aminata',
    username: 'aminata_v',
    avatarUrl:
        'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=100&h=100&fit=crop',
    type: SellerType.particulier,
    zone: 'Zone 1',
    deliverySla: '24h',
    rating: 4.9,
    reviewCount: 42,
    badge: 'Publications fréquentes',
    phone: '+224 621 11 22 33',
  ),
  'seller_ibrahim': SellerInfo(
    id: 'seller_ibrahim',
    username: 'ibrahim_shop',
    avatarUrl:
        'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=100&h=100&fit=crop',
    type: SellerType.boutique,
    zone: 'Zone 2',
    deliverySla: '48h',
    rating: 4.7,
    reviewCount: 18,
    phone: '+224 622 22 33 44',
  ),
  'seller_mariam': SellerInfo(
    id: 'seller_mariam',
    username: 'mariam_mode',
    avatarUrl:
        'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop',
    type: SellerType.boutique,
    zone: 'Zone 1',
    deliverySla: '72h',
    rating: 5,
    reviewCount: 107,
    badge: 'Publications fréquentes',
    phone: '+224 623 33 44 55',
  ),
  'seller_camilla': SellerInfo(
    id: 'seller_camilla',
    username: 'camillacamillacam',
    avatarUrl:
        'https://images.unsplash.com/photo-1534528741775-53994a69daeb?w=100&h=100&fit=crop',
    type: SellerType.particulier,
    zone: 'Zone 2',
    deliverySla: '48h',
    rating: 4.8,
    reviewCount: 63,
    badge: 'Vendeur vérifié',
    phone: '+224 624 44 55 66',
  ),
  'seller_tech': SellerInfo(
    id: 'seller_tech',
    username: 'tech_guinee',
    avatarUrl:
        'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=100&h=100&fit=crop',
    type: SellerType.enseigne,
    zone: 'Zone 1',
    deliverySla: '4h',
    rating: 4.6,
    reviewCount: 31,
    phone: '+224 625 55 66 77',
  ),
  'seller_carrefour': SellerInfo(
    id: 'seller_carrefour',
    username: 'carrefour_kaloum',
    avatarUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=100&h=100&fit=crop',
    type: SellerType.enseigne,
    zone: 'Zone 1',
    deliverySla: '2h',
    rating: 4.4,
    reviewCount: 128,
    phone: '+224 628 11 22 33',
  ),
  'seller_imperial': SellerInfo(
    id: 'seller_imperial',
    username: 'imperial_store',
    avatarUrl:
        'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?w=100&h=100&fit=crop',
    type: SellerType.enseigne,
    zone: 'Zone 1',
    deliverySla: '24h',
    rating: 4.2,
    reviewCount: 89,
    phone: '+224 628 22 33 44',
  ),
  'seller_maison_plus': SellerInfo(
    id: 'seller_maison_plus',
    username: 'maison_plus',
    avatarUrl:
        'https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=100&h=100&fit=crop',
    type: SellerType.enseigne,
    zone: 'Zone 2',
    deliverySla: '4h',
    rating: 4.5,
    reviewCount: 56,
    phone: '+224 628 33 44 55',
  ),
  'seller_mode_express': SellerInfo(
    id: 'seller_mode_express',
    username: 'mode_express_gn',
    avatarUrl:
        'https://images.unsplash.com/photo-1441986300917-64676bd600d8?w=100&h=100&fit=crop',
    type: SellerType.enseigne,
    zone: 'Zone 2',
    deliverySla: '2h',
    rating: 4.3,
    reviewCount: 74,
    phone: '+224 628 44 55 66',
  ),
  'seller_epicerie_express': SellerInfo(
    id: 'seller_epicerie_express',
    username: 'epicerie_express',
    avatarUrl:
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=100&h=100&fit=crop',
    type: SellerType.enseigne,
    zone: 'Zone 1',
    deliverySla: '2h',
    rating: 4.7,
    reviewCount: 203,
    phone: '+224 628 55 66 77',
  ),
  'seller_fatou': SellerInfo(
    id: 'seller_fatou',
    username: 'fatou_styles',
    avatarUrl:
        'https://images.unsplash.com/photo-1494790108377-be9c29b29330?w=100&h=100&fit=crop',
    type: SellerType.particulier,
    zone: 'Zone 1',
    deliverySla: '24h',
    rating: 4.5,
    reviewCount: 12,
    phone: '+224 626 66 77 88',
  ),
  'seller_mode_plus': SellerInfo(
    id: 'seller_mode_plus',
    username: 'mode_plus_gn',
    avatarUrl:
        'https://images.unsplash.com/photo-1500648767791-00dcc994a43e?w=100&h=100&fit=crop',
    type: SellerType.boutique,
    zone: 'Zone 2',
    deliverySla: '48h',
    rating: 4.4,
    reviewCount: 55,
    phone: '+224 627 77 88 99',
  ),
  'seller_quartier': SellerInfo(
    id: 'seller_quartier',
    username: 'epicerie_kipe',
    avatarUrl:
        'https://images.unsplash.com/photo-1556740738-b6a63e27c4df?w=100&h=100&fit=crop',
    type: SellerType.boutique,
    zone: 'Zone 1',
    deliverySla: 'Retrait / proximité',
    rating: 4.9,
    reviewCount: 28,
    badge: 'Boutique de proximité',
    phone: '+224 623 00 11 22',
  ),
  'seller_madina_epicerie': SellerInfo(
    id: 'seller_madina_epicerie',
    username: 'epicerie_madina',
    avatarUrl:
        'https://images.unsplash.com/photo-1604719312566-8912e9227c6a?w=100&h=100&fit=crop',
    type: SellerType.boutique,
    zone: 'Zone 2',
    deliverySla: 'Retrait / proximité',
    rating: 4.6,
    reviewCount: 14,
    badge: 'Boutique de proximité',
    phone: '+224 624 55 66 77',
  ),
};

const _productSellerIds = <String, String>{
  '1': 'seller_aminata',
  '2': 'seller_ibrahim',
  '3': 'seller_mariam',
  '4': 'seller_camilla',
  '5': 'seller_tech',
  '6': 'seller_fatou',
  '7': 'seller_mode_plus',
  '8': 'seller_aminata',
  '9': 'seller_camilla',
  '10': 'seller_fatou',
  '11': 'seller_mariam',
  '12': 'seller_mariam',
  '13': 'seller_mariam',
  '14': 'seller_ibrahim',
  '15': 'seller_ibrahim',
  '16': 'seller_ibrahim',
  '17': 'seller_mode_plus',
  '18': 'seller_mode_plus',
  '19': 'seller_mode_plus',
  '20': 'seller_camilla',
  '21': 'seller_camilla',
};

SellerInfo sellerForProduct(String productId) {
  final sellerId = _productSellerIds[productId];
  if (sellerId == null) return defaultSeller;
  return sellerById(sellerId) ?? defaultSeller;
}

/// Runtime sellers created by register / provision (simulates DB writes).
final Map<String, SellerInfo> _dynamicSellers = {};

SellerInfo? sellerById(String sellerId) =>
    _dynamicSellers[sellerId] ?? sellersById[sellerId];

void registerSellerProfile(SellerInfo seller) {
  _dynamicSellers[seller.id] = seller;
}

List<String> get showcaseSellerIds => const [
      'seller_mariam',
      'seller_ibrahim',
      'seller_mode_plus',
      'seller_camilla',
    ];
