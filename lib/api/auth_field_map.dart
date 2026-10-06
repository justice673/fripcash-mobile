import 'package:frip_cash/models/shop_kind.dart';

/// Maps UI labels / SLA display strings to API values.
abstract final class AuthFieldMap {
  /// Prefer catalog CUID from [CatalogApi.fetchShopCategories].
  /// Legacy FR labels still resolve to slug for one release.
  static const proximityCategorySlugs = <String, String>{
    'Épicerie sèche': 'epicerie_seche',
    'Boutique de proximité': 'boutique_de_proximite',
    'Boissons & snacks': 'boissons_snacks',
    'Produits du quotidien': 'produits_du_quotidien',
  };

  /// Value for `shopCategoryId`: pass CUID/slug through; map old FR labels → slug.
  static String? shopCategoryId(String? value) {
    if (value == null || value.isEmpty) return null;
    return proximityCategorySlugs[value] ?? value;
  }

  @Deprecated('Use shopCategoryId')
  static String? shopCategorySlug(String? uiLabel) => shopCategoryId(uiLabel);

  static String? deliverySlaApi(String? ui) {
    if (ui == null) return null;
    if (ui == '1 semaine') return '1_semaine';
    return ui;
  }

  /// Nest `ShopKind` enum on `POST /me/seller/shop`.
  static String shopKindApi(ShopKind kind) => switch (kind) {
        ShopKind.standard => 'STANDARD',
        ShopKind.proximite => 'PROXIMITE',
        ShopKind.enseigne => 'ENSEIGNE',
      };

  static String signupPath(String roleName) => roleName;
}
