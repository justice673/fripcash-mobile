class MarketplaceCategory {
  const MarketplaceCategory({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;
}

const marketplaceCategories = <MarketplaceCategory>[
  MarketplaceCategory(id: 'mode', label: 'Mode & Accessoires'),
  MarketplaceCategory(id: 'shoes', label: 'Chaussures'),
  MarketplaceCategory(id: 'beauty', label: 'Beauté & Cosmétique'),
  MarketplaceCategory(id: 'baby', label: 'Bébé & Maternité'),
  MarketplaceCategory(id: 'grocery', label: 'Épicerie & Petit-déjeuner'),
  MarketplaceCategory(id: 'home', label: 'Maison & Décoration'),
  MarketplaceCategory(
    id: 'electronics',
    label: 'Électronique - Électroménager',
  ),
  MarketplaceCategory(id: 'secondhand', label: 'Seconde main'),
];

/// Category ids for home filter pills (first entry = all).
const categoryPillIds = <String>[
  'all',
  'mode',
  'shoes',
  'beauty',
  'baby',
  'grocery',
  'home',
  'electronics',
  'secondhand',
];

/// Legacy label list kept for backwards compatibility in mocks.
const categoryPills = <String>[
  'Voir tout',
  'Mode & Accessoires',
  'Chaussures',
  'Beauté & Cosmétique',
  'Bébé & Maternité',
  'Épicerie & Petit-déjeuner',
  'Maison & Décoration',
  'Électronique - Électroménager',
  'Seconde main',
];

MarketplaceCategory? categoryById(String id) {
  for (final category in marketplaceCategories) {
    if (category.id == id) return category;
  }
  return null;
}

MarketplaceCategory? categoryByLabel(String label) {
  for (final category in marketplaceCategories) {
    if (category.label == label) return category;
  }
  return null;
}
