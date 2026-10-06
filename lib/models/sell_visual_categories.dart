import 'package:frip_cash/l10n/app_localizations.dart';

/// Top-level visual card on the sell “Catégorie” step (client mock).
class SellVisualCategory {
  const SellVisualCategory({
    required this.id,
    required this.imageAsset,
    required this.listingCategoryId,
    required this.subs,
  });

  final String id;
  final String imageAsset;
  final String listingCategoryId;
  final List<SellVisualSubcategory> subs;

  bool get needsSubcategory => subs.isNotEmpty;
}

class SellVisualSubcategory {
  const SellVisualSubcategory({
    required this.id,
    required this.listingCategoryId,
    this.listingSubcategoryId,
  });

  final String id;
  final String listingCategoryId;
  final String? listingSubcategoryId;
}

/// Six photo cards: Femmes, Hommes, Maison, High-tech, Épicerie, Premium.
const sellVisualCategories = <SellVisualCategory>[
  SellVisualCategory(
    id: 'femmes',
    imageAsset: 'assets/images/browse/browse_women.png',
    listingCategoryId: 'mode',
    subs: [
      SellVisualSubcategory(
        id: 'dresses',
        listingCategoryId: 'mode',
        listingSubcategoryId: 'women',
      ),
      SellVisualSubcategory(
        id: 'tops',
        listingCategoryId: 'mode',
        listingSubcategoryId: 'women',
      ),
      SellVisualSubcategory(
        id: 'bottoms',
        listingCategoryId: 'mode',
        listingSubcategoryId: 'women',
      ),
      SellVisualSubcategory(
        id: 'shoes_w',
        listingCategoryId: 'shoes',
        listingSubcategoryId: 'women',
      ),
      SellVisualSubcategory(
        id: 'accessories_w',
        listingCategoryId: 'mode',
        listingSubcategoryId: 'accessories',
      ),
    ],
  ),
  SellVisualCategory(
    id: 'hommes',
    imageAsset: 'assets/images/browse/browse_men.png',
    listingCategoryId: 'mode',
    subs: [
      SellVisualSubcategory(
        id: 'tops_m',
        listingCategoryId: 'mode',
        listingSubcategoryId: 'men',
      ),
      SellVisualSubcategory(
        id: 'bottoms_m',
        listingCategoryId: 'mode',
        listingSubcategoryId: 'men',
      ),
      SellVisualSubcategory(
        id: 'shoes_m',
        listingCategoryId: 'shoes',
        listingSubcategoryId: 'men',
      ),
      SellVisualSubcategory(
        id: 'accessories_m',
        listingCategoryId: 'mode',
        listingSubcategoryId: 'accessories',
      ),
    ],
  ),
  SellVisualCategory(
    id: 'maison',
    imageAsset: 'assets/images/browse/browse_home.png',
    listingCategoryId: 'home',
    subs: [
      SellVisualSubcategory(
        id: 'furniture',
        listingCategoryId: 'home',
        listingSubcategoryId: 'furniture',
      ),
      SellVisualSubcategory(
        id: 'decor',
        listingCategoryId: 'home',
        listingSubcategoryId: 'decor',
      ),
      SellVisualSubcategory(
        id: 'kitchen',
        listingCategoryId: 'home',
        listingSubcategoryId: 'kitchen',
      ),
    ],
  ),
  SellVisualCategory(
    id: 'hightech',
    imageAsset: 'assets/images/browse/browse_tech.png',
    listingCategoryId: 'electronics',
    subs: [
      SellVisualSubcategory(
        id: 'phones',
        listingCategoryId: 'electronics',
        listingSubcategoryId: 'phones',
      ),
      SellVisualSubcategory(
        id: 'computers',
        listingCategoryId: 'electronics',
        listingSubcategoryId: 'computers',
      ),
      SellVisualSubcategory(
        id: 'tvs',
        listingCategoryId: 'electronics',
        listingSubcategoryId: 'tvs',
      ),
      SellVisualSubcategory(
        id: 'accessories_e',
        listingCategoryId: 'electronics',
        listingSubcategoryId: 'accessories',
      ),
    ],
  ),
  SellVisualCategory(
    id: 'epicerie',
    imageAsset: 'assets/images/home/categories/grocery.jpg',
    listingCategoryId: 'grocery',
    subs: [],
  ),
  SellVisualCategory(
    id: 'premium',
    imageAsset: 'assets/images/browse/browse_premium.png',
    listingCategoryId: 'secondhand',
    subs: [
      SellVisualSubcategory(
        id: 'premium_women',
        listingCategoryId: 'secondhand',
        listingSubcategoryId: 'women',
      ),
      SellVisualSubcategory(
        id: 'premium_men',
        listingCategoryId: 'secondhand',
        listingSubcategoryId: 'men',
      ),
      SellVisualSubcategory(
        id: 'premium_other',
        listingCategoryId: 'secondhand',
        listingSubcategoryId: 'other',
      ),
    ],
  ),
];

SellVisualCategory? sellVisualById(String id) {
  for (final c in sellVisualCategories) {
    if (c.id == id) return c;
  }
  return null;
}

String sellVisualCategoryLabel(String id, AppLocalizations t) {
  return switch (id) {
    'femmes' => t.browseCategoryWomen,
    'hommes' => t.browseCategoryMen,
    'maison' => t.sellVisualHome,
    'hightech' => t.browseCategoryTech,
    'epicerie' => t.categoryGroceryShort,
    'premium' => t.sellVisualPremium,
    _ => id,
  };
}

String sellVisualSubLabel(String id, AppLocalizations t) {
  return switch (id) {
    'dresses' => t.sellSubDresses,
    'tops' || 'tops_m' => t.sellSubTops,
    'bottoms' || 'bottoms_m' => t.sellSubBottoms,
    'shoes_w' || 'shoes_m' => t.sellSubShoes,
    'accessories_w' || 'accessories_m' || 'accessories_e' => t.sellSubAccessories,
    'furniture' => t.sellSubFurniture,
    'decor' => t.sellSubDecor,
    'kitchen' => t.sellSubKitchen,
    'phones' => t.sellSubPhones,
    'computers' => t.sellSubComputers,
    'tvs' => t.sellSubTvs,
    'premium_women' => t.subcategoryWomen,
    'premium_men' => t.subcategoryMen,
    'premium_other' => t.sellSubOther,
    _ => id,
  };
}
