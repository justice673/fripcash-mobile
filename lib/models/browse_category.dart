import 'package:flutter/material.dart';
import 'package:frip_cash/models/catalog_category.dart';

/// Browse grid card model — always built from Nest catalog categories.
class BrowseCategory {
  const BrowseCategory({
    required this.id,
    required this.accentColor,
    required this.icon,
    required this.nameFr,
    required this.nameEn,
    this.filterCategoryId,
    this.imageUrl,
    this.slug,
    this.childFilterIds = const [],
  });

  final String id;
  final Color accentColor;
  final IconData icon;
  final String nameFr;
  final String nameEn;

  /// Nest category id used for listing filters.
  final String? filterCategoryId;
  final String? imageUrl;
  final String? slug;

  /// Extra Nest category ids to include (children of a parent).
  final List<String> childFilterIds;

  String labelForLocale(String languageCode) =>
      languageCode.toLowerCase().startsWith('en')
          ? (nameEn.isNotEmpty ? nameEn : nameFr)
          : (nameFr.isNotEmpty ? nameFr : nameEn);

  Set<String> get matchingCategoryIds {
    final ids = <String>{};
    final primary = filterCategoryId ?? id;
    if (primary.isNotEmpty) ids.add(primary);
    ids.addAll(childFilterIds);
    return ids;
  }

  static BrowseCategory fromCatalog(
    CatalogCategory category, {
    List<String> childIds = const [],
  }) {
    final style = _styleForSlug(category.slug);
    return BrowseCategory(
      id: category.id,
      slug: category.slug,
      nameFr: category.nameFr,
      nameEn: category.nameEn,
      imageUrl: category.imageUrl,
      accentColor: style.accent,
      icon: style.icon,
      filterCategoryId: category.id,
      childFilterIds: childIds,
    );
  }
}

class _CatStyle {
  const _CatStyle({required this.accent, required this.icon});
  final Color accent;
  final IconData icon;
}

_CatStyle _styleForSlug(String slug) {
  final s = slug.toLowerCase();
  if (s.contains('fashion') || s.contains('mode') || s.contains('women')) {
    return const _CatStyle(
      accent: Color(0xFFB794F6),
      icon: Icons.checkroom_outlined,
    );
  }
  if (s.contains('men') && !s.contains('women')) {
    return const _CatStyle(
      accent: Color(0xFF8FAF9B),
      icon: Icons.man_outlined,
    );
  }
  if (s.contains('kid') || s.contains('baby') || s.contains('enfant')) {
    return const _CatStyle(
      accent: Color(0xFFFF8A5B),
      icon: Icons.child_care_outlined,
    );
  }
  if (s.contains('home') || s.contains('maison') || s.contains('decor')) {
    return const _CatStyle(
      accent: Color(0xFFFF7A45),
      icon: Icons.chair_outlined,
    );
  }
  if (s.contains('electron') ||
      s.contains('phone') ||
      s.contains('tech') ||
      s.contains('accessoir')) {
    return const _CatStyle(
      accent: Color(0xFF2BB7C5),
      icon: Icons.devices_outlined,
    );
  }
  if (s.contains('sport') || s.contains('leisure') || s.contains('shoe')) {
    return const _CatStyle(
      accent: Color(0xFF6E8A72),
      icon: Icons.sports_tennis_outlined,
    );
  }
  return const _CatStyle(
    accent: Color(0xFFC4A484),
    icon: Icons.category_outlined,
  );
}
