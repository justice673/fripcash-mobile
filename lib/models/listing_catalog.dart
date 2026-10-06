import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';

/// How size/spec options are chosen for a listing.
///
/// Like Vinted: the **platform** defines this catalog (admins / product team).
/// Sellers only pick from it — they don't create categories.
enum ListingSizeSchema {
  clothing,
  shoeEu,
  babyAge,
  oneSize,
  tvInches,
  phoneStorage,
  none,
}

class ListingSubcategory {
  const ListingSubcategory({
    required this.id,
    required this.sizeSchema,
  });

  final String id;
  final ListingSizeSchema sizeSchema;
}

class ListingCategoryNode {
  const ListingCategoryNode({
    required this.id,
    this.subcategories = const [],
    this.defaultSizeSchema = ListingSizeSchema.none,
  });

  final String id;
  final List<ListingSubcategory> subcategories;
  final ListingSizeSchema defaultSizeSchema;

  bool get hasSubcategories => subcategories.isNotEmpty;

  ListingSubcategory? subcategoryById(String id) {
    for (final sub in subcategories) {
      if (sub.id == id) return sub;
    }
    return null;
  }

  ListingSizeSchema sizeSchemaFor(String? subcategoryId) {
    if (subcategoryId != null) {
      final sub = subcategoryById(subcategoryId);
      if (sub != null) return sub.sizeSchema;
    }
    return defaultSizeSchema;
  }
}

/// Platform listing taxonomy used on the sell form.
const listingCatalog = <ListingCategoryNode>[
  ListingCategoryNode(
    id: 'mode',
    defaultSizeSchema: ListingSizeSchema.clothing,
    subcategories: [
      ListingSubcategory(id: 'women', sizeSchema: ListingSizeSchema.clothing),
      ListingSubcategory(id: 'men', sizeSchema: ListingSizeSchema.clothing),
      ListingSubcategory(id: 'kids', sizeSchema: ListingSizeSchema.clothing),
      ListingSubcategory(
        id: 'accessories',
        sizeSchema: ListingSizeSchema.oneSize,
      ),
    ],
  ),
  ListingCategoryNode(
    id: 'shoes',
    defaultSizeSchema: ListingSizeSchema.shoeEu,
    subcategories: [
      ListingSubcategory(id: 'women', sizeSchema: ListingSizeSchema.shoeEu),
      ListingSubcategory(id: 'men', sizeSchema: ListingSizeSchema.shoeEu),
      ListingSubcategory(id: 'kids', sizeSchema: ListingSizeSchema.shoeEu),
    ],
  ),
  ListingCategoryNode(
    id: 'electronics',
    defaultSizeSchema: ListingSizeSchema.none,
    subcategories: [
      ListingSubcategory(
        id: 'phones',
        sizeSchema: ListingSizeSchema.phoneStorage,
      ),
      ListingSubcategory(id: 'tvs', sizeSchema: ListingSizeSchema.tvInches),
      ListingSubcategory(
        id: 'computers',
        sizeSchema: ListingSizeSchema.phoneStorage,
      ),
      ListingSubcategory(
        id: 'appliances',
        sizeSchema: ListingSizeSchema.none,
      ),
      ListingSubcategory(
        id: 'accessories',
        sizeSchema: ListingSizeSchema.oneSize,
      ),
    ],
  ),
  ListingCategoryNode(
    id: 'beauty',
    defaultSizeSchema: ListingSizeSchema.oneSize,
  ),
  ListingCategoryNode(
    id: 'baby',
    defaultSizeSchema: ListingSizeSchema.babyAge,
    subcategories: [
      ListingSubcategory(id: 'baby_clothes', sizeSchema: ListingSizeSchema.babyAge),
      ListingSubcategory(
        id: 'maternity',
        sizeSchema: ListingSizeSchema.clothing,
      ),
      ListingSubcategory(
        id: 'baby_gear',
        sizeSchema: ListingSizeSchema.oneSize,
      ),
    ],
  ),
  ListingCategoryNode(
    id: 'grocery',
    defaultSizeSchema: ListingSizeSchema.none,
  ),
  ListingCategoryNode(
    id: 'home',
    defaultSizeSchema: ListingSizeSchema.oneSize,
    subcategories: [
      ListingSubcategory(
        id: 'furniture',
        sizeSchema: ListingSizeSchema.oneSize,
      ),
      ListingSubcategory(id: 'decor', sizeSchema: ListingSizeSchema.oneSize),
      ListingSubcategory(id: 'kitchen', sizeSchema: ListingSizeSchema.oneSize),
    ],
  ),
  ListingCategoryNode(
    id: 'secondhand',
    defaultSizeSchema: ListingSizeSchema.clothing,
    subcategories: [
      ListingSubcategory(id: 'women', sizeSchema: ListingSizeSchema.clothing),
      ListingSubcategory(id: 'men', sizeSchema: ListingSizeSchema.clothing),
      ListingSubcategory(id: 'kids', sizeSchema: ListingSizeSchema.clothing),
      ListingSubcategory(
        id: 'other',
        sizeSchema: ListingSizeSchema.oneSize,
      ),
    ],
  ),
];

ListingCategoryNode? listingCategoryById(String id) {
  for (final category in listingCatalog) {
    if (category.id == id) return category;
  }
  return null;
}

const clothingSizes = <String>[
  'One size',
  '3XS',
  'XXS',
  'XS',
  'S',
  'M',
  'L',
  'XL',
  'XXL',
  '3XL',
  '4XL',
  '5XL',
  '6XL',
  'Other',
];

const shoeEuSizes = <String>[
  '35',
  '36',
  '37',
  '38',
  '39',
  '40',
  '41',
  '42',
  '43',
  '44',
  '45',
  '46',
  '47',
];

const babyAgeSizes = <String>[
  '0-3 m',
  '3-6 m',
  '6-12 m',
  '12-18 m',
  '18-24 m',
  '2-3 y',
  '3-4 y',
  '4-5 y',
  '5-6 y',
];

const tvInchSizes = <String>[
  '24"',
  '32"',
  '40"',
  '43"',
  '50"',
  '55"',
  '65"',
  '75"',
];

const phoneStorageSizes = <String>[
  '32 GB',
  '64 GB',
  '128 GB',
  '256 GB',
  '512 GB',
  '1 TB',
];

List<String> sizeOptionsForSchema(ListingSizeSchema schema, AppLocalizations t) {
  return switch (schema) {
    ListingSizeSchema.clothing => clothingSizes,
    ListingSizeSchema.shoeEu => shoeEuSizes,
    ListingSizeSchema.babyAge => babyAgeSizes,
    ListingSizeSchema.oneSize => [t.oneSize],
    ListingSizeSchema.tvInches => tvInchSizes,
    ListingSizeSchema.phoneStorage => phoneStorageSizes,
    ListingSizeSchema.none => const [],
  };
}

String subcategoryLabel(String id, AppLocalizations t) => switch (id) {
      'women' => t.subcategoryWomen,
      'men' => t.subcategoryMen,
      'kids' => t.subcategoryKids,
      'accessories' => t.subcategoryAccessories,
      'phones' => t.subcategoryPhones,
      'tvs' => t.subcategoryTvs,
      'computers' => t.subcategoryComputers,
      'appliances' => t.subcategoryAppliances,
      'baby_clothes' => t.subcategoryBabyClothes,
      'maternity' => t.subcategoryMaternity,
      'baby_gear' => t.subcategoryBabyGear,
      'furniture' => t.subcategoryFurniture,
      'decor' => t.subcategoryDecor,
      'kitchen' => t.subcategoryKitchen,
      'other' => t.subcategoryOther,
      _ => id,
    };

String sizeFieldLabel(ListingSizeSchema schema, AppLocalizations t) =>
    switch (schema) {
      ListingSizeSchema.tvInches => t.sizeScreenInches,
      ListingSizeSchema.phoneStorage => t.sizeStorage,
      ListingSizeSchema.shoeEu => t.sizeShoeEu,
      ListingSizeSchema.babyAge => t.sizeAge,
      ListingSizeSchema.none => t.size,
      _ => t.size,
    };

IconData subcategoryIcon(String id) => switch (id) {
      'women' => Icons.woman_outlined,
      'men' => Icons.man_outlined,
      'kids' => Icons.child_care_outlined,
      'accessories' => Icons.watch_outlined,
      'phones' => Icons.smartphone_outlined,
      'tvs' => Icons.tv_outlined,
      'computers' => Icons.laptop_mac_outlined,
      'appliances' => Icons.kitchen_outlined,
      'baby_clothes' => Icons.checkroom_outlined,
      'maternity' => Icons.pregnant_woman_outlined,
      'baby_gear' => Icons.stroller_outlined,
      'furniture' => Icons.chair_outlined,
      'decor' => Icons.light_outlined,
      'kitchen' => Icons.restaurant_outlined,
      'other' => Icons.category_outlined,
      _ => Icons.grid_view_outlined,
    };
