class CatalogCategory {
  const CatalogCategory({
    required this.id,
    required this.slug,
    required this.nameFr,
    required this.nameEn,
    required this.sortOrder,
    required this.isActive,
    this.parentId,
    this.destination,
    this.imageUrl,
    this.imagePublicId,
  });

  final String id;
  final String? parentId;
  final String slug;
  final String nameFr;
  final String nameEn;
  final String? destination;
  final int sortOrder;
  final bool isActive;
  final String? imageUrl;
  final String? imagePublicId;

  bool get isRoot => parentId == null || parentId!.isEmpty;

  factory CatalogCategory.fromJson(Map<String, dynamic> json) {
    return CatalogCategory(
      id: (json['id'] ?? '').toString(),
      parentId: json['parentId']?.toString(),
      slug: (json['slug'] ?? '').toString(),
      nameFr: (json['nameFr'] ?? json['name'] ?? '').toString(),
      nameEn: (json['nameEn'] ?? json['nameFr'] ?? json['name'] ?? '')
          .toString(),
      destination: json['destination']?.toString(),
      sortOrder: json['sortOrder'] is int
          ? json['sortOrder'] as int
          : int.tryParse('${json['sortOrder'] ?? 0}') ?? 0,
      isActive: json['isActive'] != false,
      imageUrl: json['imageUrl']?.toString(),
      imagePublicId: json['imagePublicId']?.toString(),
    );
  }

  String labelForLocale(String languageCode) =>
      languageCode.toLowerCase().startsWith('en') ? nameEn : nameFr;
}
