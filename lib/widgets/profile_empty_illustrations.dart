import 'package:flutter/material.dart';

/// Empty-state art for profile hub (Shop / Sold / Purchased / Likes / Balance).
/// Same sticker cutouts as Browse category cards (`Image.asset` PNGs).
abstract final class ProfileEmptyIllustrations {
  static const shop = ProfileEmptyIllustration(
    asset: 'assets/images/empty/empty_shop.png',
  );
  static const toShip = ProfileEmptyIllustration(
    asset: 'assets/images/empty/empty_toship.png',
  );
  static const purchased = ProfileEmptyIllustration(
    asset: 'assets/images/empty/empty_purchased.png',
  );
  static const likes = ProfileEmptyIllustration(
    asset: 'assets/images/empty/empty_likes.png',
  );
  static const balance = ProfileEmptyIllustration(
    asset: 'assets/images/empty/empty_balance.png',
  );
  static const offers = ProfileEmptyIllustration(
    asset: 'assets/images/empty/empty_offers.png',
  );
}

class ProfileEmptyIllustration extends StatelessWidget {
  const ProfileEmptyIllustration({
    super.key,
    required this.asset,
    this.size = 168,
  });

  final String asset;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        asset,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (context, error, stackTrace) {
          return Icon(
            Icons.local_offer_outlined,
            size: size * 0.45,
            color: const Color(0xFFC45C26).withValues(alpha: 0.35),
          );
        },
      ),
    );
  }
}
