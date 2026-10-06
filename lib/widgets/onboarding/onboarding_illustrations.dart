import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

enum OnboardingArtKind { sell, free, delivery, welcome }

/// Premium illustrated hero — all slides stay fixed in place.
class OnboardingHeroArt extends StatelessWidget {
  const OnboardingHeroArt({
    super.key,
    required this.kind,
    this.active = true,
  });

  final OnboardingArtKind kind;
  final bool active;

  String get asset => switch (kind) {
        OnboardingArtKind.sell => 'assets/images/onboarding/sell.png',
        OnboardingArtKind.free => 'assets/images/onboarding/free.png',
        OnboardingArtKind.delivery => 'assets/images/onboarding/delivery.png',
        OnboardingArtKind.welcome => 'assets/images/onboarding/welcome.png',
      };

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final side = math.min(constraints.maxWidth, constraints.maxHeight);
        return Center(
          child: SizedBox(
            width: side,
            height: side,
            child: Stack(
              alignment: Alignment.center,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(alpha: 0.16),
                        AppColors.primary.withValues(alpha: 0.05),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                  child: const SizedBox.expand(),
                ),
                Padding(
                  padding: EdgeInsets.all(side * 0.02),
                  child: Image.asset(
                    asset,
                    width: side * 0.92,
                    height: side * 0.92,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    gaplessPlayback: true,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Soft entrance when a slide becomes visible.
class OnboardingSlideReveal extends StatelessWidget {
  const OnboardingSlideReveal({
    super.key,
    required this.child,
    required this.visible,
  });

  final Widget child;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      opacity: visible ? 1 : 0.35,
      child: AnimatedScale(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeOutCubic,
        scale: visible ? 1 : 0.96,
        child: child,
      ),
    );
  }
}

/// Frosted skip control — quiet, premium.
class OnboardingSkipChip extends StatelessWidget {
  const OnboardingSkipChip({
    super.key,
    required this.label,
    required this.onPressed,
  });

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.55),
          child: InkWell(
            onTap: onPressed,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppTypography.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary.withValues(alpha: 0.55),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
