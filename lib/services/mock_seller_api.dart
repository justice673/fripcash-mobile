import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/mock/mock_users.dart';
import 'package:frip_cash/mock/mock_zones.dart';
import 'package:frip_cash/models/seller.dart';
import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/services/mock_wallet_service.dart';

/// Post-auth bootstrap — wallet sync only. No seeded demo listings.
abstract final class MockSellerApi {
  static void provisionAccount(MockUser user) {
    if (!user.role.isSeller) {
      MockWalletService.instance.syncForUser(user);
      return;
    }

    final type = user.sellerType ?? SellerType.particulier;
    final zoneName = zoneById(user.zoneId ?? '')?.name ?? user.zoneId ?? '';

    registerSellerProfile(
      SellerInfo(
        id: user.sellerId,
        username: _usernameFrom(user),
        avatarUrl: '',
        type: type,
        zone: zoneName,
        deliverySla: user.isProximityShop
            ? 'Retrait / proximité'
            : (user.deliverySla ?? '48h'),
        rating: 0,
        reviewCount: 0,
        badge: user.isProximityShop
            ? 'Boutique de proximité'
            : user.isPartnerEnseigne
                ? 'Enseigne partenaire'
                : (type == SellerType.particulier ? 'Nouveau vendeur' : null),
        phone: user.phone,
      ),
    );

    MockWalletService.instance.syncForUser(user);
  }

  static String _usernameFrom(MockUser user) {
    final shop = user.shopName?.trim();
    if (shop != null && shop.isNotEmpty) {
      return shop.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
    }
    final name = user.name.trim();
    if (name.isEmpty) return user.sellerId;
    return name.toLowerCase().replaceAll(RegExp(r'\s+'), '_');
  }
}
