/// Gender tabs on Articles neufs / Seconde main catalog screens.
enum CatalogGender { femme, homme, enfant }

extension CatalogGenderX on CatalogGender {
  bool matchesCategory(String categoryId) {
    return switch (this) {
      CatalogGender.femme =>
        categoryId == 'mode' ||
            categoryId == 'shoes' ||
            categoryId == 'beauty',
      CatalogGender.homme =>
        categoryId == 'secondhand' || categoryId == 'shoes',
      CatalogGender.enfant => categoryId == 'baby',
    };
  }
}
