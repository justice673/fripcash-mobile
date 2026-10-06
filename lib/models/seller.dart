import 'package:frip_cash/models/seller_type.dart';

class SellerInfo {
  const SellerInfo({
    required this.id,
    required this.username,
    required this.avatarUrl,
    this.type = SellerType.particulier,
    this.zone = 'Zone 1',
    this.deliverySla = '48h',
    this.rating = 5,
    this.reviewCount = 0,
    this.badge,
    this.phone,
  });

  final String id;
  final String username;
  final String avatarUrl;
  final SellerType type;
  final String zone;
  final String deliverySla;
  final double rating;
  final int reviewCount;
  final String? badge;
  /// Private — never shown on public product or shop cards.
  final String? phone;
}
