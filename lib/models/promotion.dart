/// Nest public featured promotion (`GET /promotions`, locale-collapsed).
class FeaturedPromotion {
  const FeaturedPromotion({
    required this.id,
    required this.kind,
    required this.title,
    required this.imageUrl,
    this.subtitle,
    this.description,
    this.badge,
    this.ctaLabel,
    this.listingId,
    this.sellerProfileId,
    this.promoPriceGnf,
    this.compareAtPriceGnf,
    this.discountPercent,
    this.startsAt,
    this.endsAt,
    this.surface,
    this.sortOrder = 0,
    this.deepLinkType,
    this.deepLinkId,
  });

  final String id;
  final FeaturedPromotionKind kind;
  final String title;
  final String? subtitle;
  final String? description;
  final String? badge;
  final String? ctaLabel;
  final String imageUrl;
  final String? listingId;
  final String? sellerProfileId;
  final int? promoPriceGnf;
  final int? compareAtPriceGnf;
  final int? discountPercent;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final String? surface;
  final int sortOrder;
  final FeaturedDeepLinkType? deepLinkType;
  final String? deepLinkId;

  bool get isProduct => kind == FeaturedPromotionKind.product;
  bool get isShop => kind == FeaturedPromotionKind.shop;

  bool get hasDiscount =>
      compareAtPriceGnf != null &&
      promoPriceGnf != null &&
      compareAtPriceGnf! > promoPriceGnf!;

  int? get effectiveDiscountPercent {
    if (discountPercent != null) return discountPercent;
    if (!hasDiscount) return null;
    return (((compareAtPriceGnf! - promoPriceGnf!) / compareAtPriceGnf!) * 100)
        .round();
  }

  /// Target id for navigation (deepLink preferred).
  String? get navigationId {
    if (deepLinkId != null && deepLinkId!.isNotEmpty) return deepLinkId;
    return switch (kind) {
      FeaturedPromotionKind.product => listingId,
      FeaturedPromotionKind.shop => sellerProfileId,
    };
  }

  factory FeaturedPromotion.fromJson(Map<String, dynamic> json) {
    final deep = json['deepLink'];
    Map<String, dynamic>? deepMap;
    if (deep is Map) deepMap = Map<String, dynamic>.from(deep);

    final kindRaw = (json['kind'] ?? '').toString().toUpperCase();
    final kind = kindRaw == 'SHOP'
        ? FeaturedPromotionKind.shop
        : FeaturedPromotionKind.product;

    FeaturedDeepLinkType? deepType;
    final deepTypeRaw =
        (deepMap?['type'] ?? '').toString().toUpperCase();
    if (deepTypeRaw == 'SHOP') {
      deepType = FeaturedDeepLinkType.shop;
    } else if (deepTypeRaw == 'LISTING' || kind == FeaturedPromotionKind.product) {
      deepType = FeaturedDeepLinkType.listing;
    } else if (kind == FeaturedPromotionKind.shop) {
      deepType = FeaturedDeepLinkType.shop;
    }

    return FeaturedPromotion(
      id: (json['id'] ?? '').toString(),
      kind: kind,
      title: (json['title'] ?? '').toString(),
      subtitle: json['subtitle']?.toString(),
      description: json['description']?.toString(),
      badge: json['badge']?.toString(),
      ctaLabel: json['ctaLabel']?.toString(),
      imageUrl: (json['imageUrl'] ?? '').toString(),
      listingId: json['listingId']?.toString(),
      sellerProfileId: json['sellerProfileId']?.toString(),
      promoPriceGnf: _asInt(json['promoPriceGnf']),
      compareAtPriceGnf: _asInt(json['compareAtPriceGnf']),
      discountPercent: _asInt(json['discountPercent']),
      startsAt: _asDate(json['startsAt']),
      endsAt: _asDate(json['endsAt']),
      surface: json['surface']?.toString(),
      sortOrder: _asInt(json['sortOrder']) ?? 0,
      deepLinkType: deepType,
      deepLinkId: deepMap?['id']?.toString(),
    );
  }
}

enum FeaturedPromotionKind { product, shop }

enum FeaturedDeepLinkType { listing, shop }

class PromotionsFeed {
  const PromotionsFeed({
    required this.items,
    required this.serverNow,
    required this.fetchedAt,
  });

  final List<FeaturedPromotion> items;
  final DateTime serverNow;
  final DateTime fetchedAt;

  /// Approximate server clock for countdowns.
  DateTime get estimatedServerNow {
    final skew = DateTime.now().toUtc().difference(fetchedAt.toUtc());
    return serverNow.toUtc().add(skew);
  }

  Duration remainingUntil(DateTime endsAt) {
    final left = endsAt.toUtc().difference(estimatedServerNow);
    return left.isNegative ? Duration.zero : left;
  }
}

int? _asInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.round();
  return int.tryParse(v.toString());
}

DateTime? _asDate(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString())?.toUtc();
}
