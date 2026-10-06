enum OfferStatus {
  pending,
  accepted,
  refused,
  cancelled,
  expired,
  consumed;

  static OfferStatus fromApi(String? raw) {
    switch ((raw ?? '').toUpperCase()) {
      case 'ACCEPTED':
        return OfferStatus.accepted;
      case 'REFUSED':
        return OfferStatus.refused;
      case 'CANCELLED':
      case 'CANCELED':
        return OfferStatus.cancelled;
      case 'EXPIRED':
        return OfferStatus.expired;
      case 'CONSUMED':
        return OfferStatus.consumed;
      default:
        return OfferStatus.pending;
    }
  }

  String get apiValue => switch (this) {
        OfferStatus.pending => 'PENDING',
        OfferStatus.accepted => 'ACCEPTED',
        OfferStatus.refused => 'REFUSED',
        OfferStatus.cancelled => 'CANCELLED',
        OfferStatus.expired => 'EXPIRED',
        OfferStatus.consumed => 'CONSUMED',
      };
}

class ProductOffer {
  const ProductOffer({
    required this.id,
    required this.productId,
    required this.productTitle,
    required this.productImage,
    required this.listedPrice,
    required this.offeredPrice,
    required this.sellerName,
    required this.sellerId,
    this.buyerName = 'Acheteur',
    this.status = OfferStatus.pending,
    this.createdAtLabel = '',
    this.checkoutToken,
    this.expiresAt,
    this.canAccept = false,
    this.canRefuse = false,
    this.canCancel = false,
  });

  final String id;
  final String productId;
  final String productTitle;
  final String productImage;
  final int listedPrice;
  final int offeredPrice;
  final String sellerName;
  final String sellerId;
  final String buyerName;
  final OfferStatus status;
  final String createdAtLabel;
  final String? checkoutToken;
  final String? expiresAt;
  final bool canAccept;
  final bool canRefuse;
  final bool canCancel;

  factory ProductOffer.fromJson(Map<String, dynamic> json) {
    int n(dynamic v) =>
        v is num ? v.toInt() : int.tryParse('$v') ?? 0;
    final listed = n(json['listedPriceGnf'] ?? json['listedPrice']);
    final offered = n(
      json['offeredPriceGnf'] ?? json['amountGnf'] ?? json['offeredPrice'],
    );
    final created = json['createdAt']?.toString();
    return ProductOffer(
      id: (json['id'] ?? '').toString(),
      productId: (json['listingId'] ?? json['productId'] ?? '').toString(),
      productTitle: (json['listingTitle'] ??
              json['productTitle'] ??
              (json['product'] is Map ? json['product']['title'] : null) ??
              '')
          .toString(),
      productImage: (json['listingImageUrl'] ??
              json['productImage'] ??
              (json['product'] is Map ? json['product']['imageUrl'] : null) ??
              '')
          .toString(),
      listedPrice: listed,
      offeredPrice: offered,
      sellerName: (json['sellerDisplayName'] ?? json['sellerName'] ?? '')
          .toString(),
      sellerId:
          (json['sellerProfileId'] ?? json['sellerId'] ?? '').toString(),
      buyerName:
          (json['buyerDisplayName'] ?? json['buyerName'] ?? 'Acheteur')
              .toString(),
      status: OfferStatus.fromApi(json['status']?.toString()),
      createdAtLabel: created ?? '',
      checkoutToken: json['checkoutToken']?.toString(),
      expiresAt: json['expiresAt']?.toString(),
      canAccept: json['canAccept'] == true,
      canRefuse: json['canRefuse'] == true,
      canCancel: json['canCancel'] == true,
    );
  }
}
