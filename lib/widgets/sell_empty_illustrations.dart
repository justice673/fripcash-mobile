import 'package:flutter/material.dart';

/// Empty-state art for sell drafts / copy flows.
/// Same sticker cutouts as Browse category cards (`Image.asset` PNGs).
abstract final class SellEmptyIllustrations {
  static const drafts = SellEmptyIllustration(
    asset: 'assets/images/empty/empty_drafts.png',
  );
  static const copy = SellEmptyIllustration(
    asset: 'assets/images/empty/empty_copy.png',
  );
}

class SellEmptyIllustration extends StatelessWidget {
  const SellEmptyIllustration({
    super.key,
    required this.asset,
    this.size = 180,
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
      ),
    );
  }
}
