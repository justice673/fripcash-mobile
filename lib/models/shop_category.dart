/// Proximity shop type from `GET /catalog/shop-categories` (not listing taxonomy).
class ShopCategory {
  const ShopCategory({
    required this.id,
    required this.slug,
    required this.nameFr,
    required this.nameEn,
    required this.sortOrder,
    required this.isActive,
    this.kind = 'PROXIMITE',
    this.descriptionFr,
    this.descriptionEn,
    this.iconKey,
  });

  final String id;
  final String kind;
  final String slug;
  final String nameFr;
  final String nameEn;
  final String? descriptionFr;
  final String? descriptionEn;
  final String? iconKey;
  final int sortOrder;
  final bool isActive;

  factory ShopCategory.fromJson(Map<String, dynamic> json) {
    return ShopCategory(
      id: (json['id'] ?? '').toString(),
      kind: (json['kind'] ?? 'PROXIMITE').toString(),
      slug: (json['slug'] ?? '').toString(),
      nameFr: (json['nameFr'] ?? json['name'] ?? '').toString(),
      nameEn: (json['nameEn'] ?? json['nameFr'] ?? json['name'] ?? '')
          .toString(),
      descriptionFr: json['descriptionFr']?.toString(),
      descriptionEn: json['descriptionEn']?.toString(),
      iconKey: json['iconKey']?.toString(),
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder'] as int
          : int.tryParse('${json['sortOrder'] ?? 0}') ?? 0,
      isActive: json['isActive'] != false,
    );
  }

  String labelForLocale(String languageCode) =>
      languageCode.toLowerCase().startsWith('en') ? nameEn : nameFr;
}
