enum ShopKind {
  /// Neighborhood / local grocery-style shop — 5% commission, pickup codes.
  proximite,

  /// Classic boutique — 8% commission, FripCash courier, articles neufs.
  standard,

  /// Partner enseigne — whole-city catalog, manual validation.
  enseigne,
}

extension ShopKindX on ShopKind {
  bool get isProximite => this == ShopKind.proximite;

  bool get isPartnerEnseigne => this == ShopKind.enseigne;
}
