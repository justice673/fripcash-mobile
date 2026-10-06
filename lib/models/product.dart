import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/utils/commission_calculator.dart';
import 'package:frip_cash/utils/product_lookup.dart'
    show catalogMaxPrice, catalogMinPrice, productById, productsForSeller;

export 'package:frip_cash/utils/product_lookup.dart'
    show catalogMaxPrice, catalogMinPrice, productById, productsForSeller;

enum ListingStatus { active, soldOut }

ListingStatus listingStatusFromStock(int stock) =>
    stock <= 0 ? ListingStatus.soldOut : ListingStatus.active;

class Product {
  const Product({
    required this.id,
    required this.title,
    required this.price,
    required this.image,
    required this.size,
    required this.categoryId,
    required this.sellerId,
    this.sellerType = SellerType.particulier,
    this.stock = 1,
    this.netPrice,
    this.likes = 0,
    this.brand,
    this.shippingCost = 0,
    this.condition = 'Très bon état',
    this.description,
    this.images,
    this.colors,
    this.badge,
    this.compareAtPrice,
    this.negotiable = false,
    this.destination,
    this.sellerName,
    this.sellerAvatarUrl,
    this.sellerRating,
    this.sellerReviewCount,
  });

  final String id;
  final String title;
  /// Buyer-facing price (commission included).
  final int price;
  /// Local asset path (`assets/...`) or remote image URL (`https://...`).
  final String image;
  final String size;
  final String categoryId;
  final String sellerId;
  final SellerType sellerType;
  final int stock;
  final int? netPrice;
  final int likes;
  final String? brand;
  final int shippingCost;
  final String condition;
  final String? description;
  final List<String>? images;
  /// Display names aligned with [images] when colour variants exist.
  final List<String>? colors;
  final String? badge;

  /// Previous buyer-facing price when a discount is shown.
  final int? compareAtPrice;
  final bool negotiable;

  /// Set when the product comes from the live listings API.
  final ListingDestination? destination;

  /// From public listing DTO `seller.name` / `sellerProfile.displayName`.
  final String? sellerName;
  final String? sellerAvatarUrl;
  final double? sellerRating;
  final int? sellerReviewCount;

  bool get isNetworkImage => image.startsWith('http');

  ListingStatus get listingStatus => listingStatusFromStock(stock);

  bool get isSoldOut => listingStatus == ListingStatus.soldOut;

  int get sellerNetPrice => netPrice ?? netPriceFromDisplay(price);

  int get priceWithShipping => price + shippingCost;

  bool get inStock => stock > 0;

  bool get isLowStock => stock > 0 && stock <= 5;

  /// Neighborhood / proximité shop listings (pickup, 5% fee).
  bool get isNeighborhoodShop => badge == 'Proximité';

  bool get hasColorVariants =>
      colors != null &&
      colors!.isNotEmpty &&
      images != null &&
      images!.length >= colors!.length;

  List<String> get galleryImages {
    final extra = images;
    if (extra != null && extra.isNotEmpty) {
      final filtered = List<String>.from(extra.where((url) => url.isNotEmpty));
      if (filtered.isNotEmpty) return filtered;
    }
    if (image.isEmpty) return const <String>[];
    return <String>[image];
  }

  String get displayDescription =>
      description ?? 'Article en excellent état, soigneusement conservé.';

  Product copyWith({
    int? price,
    int? stock,
    int? compareAtPrice,
    bool? negotiable,
    String? image,
    List<String>? images,
    String? sellerName,
    String? sellerAvatarUrl,
    double? sellerRating,
    int? sellerReviewCount,
  }) {
    return Product(
      id: id,
      title: title,
      price: price ?? this.price,
      image: image ?? this.image,
      size: size,
      categoryId: categoryId,
      sellerId: sellerId,
      sellerType: sellerType,
      stock: stock ?? this.stock,
      netPrice: netPrice,
      likes: likes,
      brand: brand,
      shippingCost: shippingCost,
      condition: condition,
      description: description,
      images: images ?? this.images,
      colors: colors,
      badge: badge,
      compareAtPrice: compareAtPrice ?? this.compareAtPrice,
      negotiable: negotiable ?? this.negotiable,
      destination: destination,
      sellerName: sellerName ?? this.sellerName,
      sellerAvatarUrl: sellerAvatarUrl ?? this.sellerAvatarUrl,
      sellerRating: sellerRating ?? this.sellerRating,
      sellerReviewCount: sellerReviewCount ?? this.sellerReviewCount,
    );
  }
}
