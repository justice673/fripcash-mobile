import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_colors.dart';

/// Courier hero art — same premium delivery illustration as onboarding.
class CourierBikeIllustration extends StatelessWidget {
  const CourierBikeIllustration({
    super.key,
    this.size = 220,
    this.showBackdrop = true,
  });

  final double size;
  final bool showBackdrop;

  static const asset = 'assets/images/onboarding/delivery.png';

  @override
  Widget build(BuildContext context) {
    final side = size;
    return SizedBox(
      width: side,
      height: side,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          if (showBackdrop) ...[
            DecoratedBox(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.22),
                    AppColors.primary.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.5, 1.0],
                ),
              ),
              child: SizedBox(width: side, height: side),
            ),
            Positioned(
              bottom: side * 0.08,
              child: Container(
                width: side * 0.55,
                height: side * 0.06,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 28,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
            ),
          ],
          Padding(
            padding: EdgeInsets.all(side * (showBackdrop ? 0.04 : 0.0)),
            child: Image.asset(
              asset,
              width: side * (showBackdrop ? 0.92 : 1),
              height: side * (showBackdrop ? 0.92 : 1),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              gaplessPlayback: true,
            ),
          ),
        ],
      ),
    );
  }
}
