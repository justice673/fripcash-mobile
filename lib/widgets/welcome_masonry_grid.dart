import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';

class _StackCard {
  const _StackCard({
    required this.asset,
    required this.alignment,
    required this.widthFactor,
    required this.heightFactor,
    required this.angle,
    required this.delay,
  });

  final String asset;
  final Alignment alignment;
  final double widthFactor;
  final double heightFactor;
  final double angle;
  final double delay;
}

/// Overlapping product cards inspired by modern welcome/onboarding layouts.
class WelcomeMasonryGrid extends StatefulWidget {
  const WelcomeMasonryGrid({super.key});

  @override
  State<WelcomeMasonryGrid> createState() => _WelcomeMasonryGridState();
}

class _WelcomeMasonryGridState extends State<WelcomeMasonryGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  /// Phone: original spread that reads well on a narrow stage.
  static const _phoneCards = <_StackCard>[
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_1.jpg',
      alignment: Alignment(0.05, -0.58),
      widthFactor: 0.36,
      heightFactor: 0.44,
      angle: -0.11,
      delay: 0.05,
    ),
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_2.jpg',
      alignment: Alignment(-0.72, 0.28),
      widthFactor: 0.34,
      heightFactor: 0.48,
      angle: 0.09,
      delay: 0.18,
    ),
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_3.jpg',
      alignment: Alignment(0.74, 0.04),
      widthFactor: 0.32,
      heightFactor: 0.46,
      angle: 0.14,
      delay: 0.28,
    ),
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_4.jpg',
      alignment: Alignment(0.1, 0.52),
      widthFactor: 0.3,
      heightFactor: 0.3,
      angle: -0.05,
      delay: 0.38,
    ),
  ];

  /// Portrait tablet: bigger cards with a little breathing room between them.
  static const _tabletPortraitCards = <_StackCard>[
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_1.jpg',
      alignment: Alignment(0.0, -0.48),
      widthFactor: 0.34,
      heightFactor: 0.52,
      angle: -0.11,
      delay: 0.05,
    ),
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_2.jpg',
      alignment: Alignment(-0.48, 0.26),
      widthFactor: 0.32,
      heightFactor: 0.56,
      angle: 0.09,
      delay: 0.18,
    ),
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_3.jpg',
      alignment: Alignment(0.50, 0.04),
      widthFactor: 0.30,
      heightFactor: 0.54,
      angle: 0.14,
      delay: 0.28,
    ),
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_4.jpg',
      alignment: Alignment(0.06, 0.52),
      widthFactor: 0.28,
      heightFactor: 0.40,
      angle: -0.05,
      delay: 0.38,
    ),
  ];

  /// Landscape tablet: compact cluster for a short, wide stage.
  static const _tabletLandscapeCards = <_StackCard>[
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_1.jpg',
      alignment: Alignment(-0.02, -0.55),
      widthFactor: 0.20,
      heightFactor: 0.70,
      angle: -0.10,
      delay: 0.05,
    ),
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_2.jpg',
      alignment: Alignment(-0.28, 0.18),
      widthFactor: 0.19,
      heightFactor: 0.76,
      angle: 0.08,
      delay: 0.18,
    ),
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_3.jpg',
      alignment: Alignment(0.28, -0.05),
      widthFactor: 0.18,
      heightFactor: 0.72,
      angle: 0.12,
      delay: 0.28,
    ),
    _StackCard(
      asset: 'assets/images/welcome/welcome_card_4.jpg',
      alignment: Alignment(0.04, 0.55),
      widthFactor: 0.16,
      heightFactor: 0.54,
      angle: -0.05,
      delay: 0.38,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  List<_StackCard> _cardsFor(BuildContext context) {
    if (!AppBreakpoints.isTablet(context)) return _phoneCards;
    if (AppBreakpoints.isLandscape(context)) return _tabletLandscapeCards;
    return _tabletPortraitCards;
  }

  ({double minW, double maxW, double minH, double maxH}) _clamps(
    BuildContext context,
  ) {
    if (!AppBreakpoints.isTablet(context)) {
      return (minW: 96, maxW: 168, minH: 118, maxH: 210);
    }
    if (AppBreakpoints.isLandscape(context)) {
      return (minW: 160, maxW: 260, minH: 180, maxH: 310);
    }
    return (minW: 200, maxW: 320, minH: 240, maxH: 390);
  }

  @override
  Widget build(BuildContext context) {
    final cards = _cardsFor(context);
    final clamps = _clamps(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final h = constraints.maxHeight;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (final card in cards)
              Align(
                alignment: card.alignment,
                child: _AnimatedProductCard(
                  animation: _entrance,
                  delay: card.delay,
                  angle: card.angle,
                  width: (w * card.widthFactor).clamp(clamps.minW, clamps.maxW),
                  height:
                      (h * card.heightFactor).clamp(clamps.minH, clamps.maxH),
                  asset: card.asset,
                ),
              ),
            // Faint fade into white at the bottom of the collage.
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              height: h * 0.28,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.white.withValues(alpha: 0),
                        Colors.white.withValues(alpha: 0.72),
                        Colors.white,
                      ],
                      stops: const [0.0, 0.55, 1.0],
                    ),
                  ),
                ),
              ),
            ),
            // Subtle spark accent.
            Positioned(
              left: w * 0.5 - 10,
              bottom: h * 0.12,
              child: FadeTransition(
                opacity: CurvedAnimation(
                  parent: _entrance,
                  curve: const Interval(0.55, 1, curve: Curves.easeOut),
                ),
                child: Icon(
                  Icons.auto_awesome,
                  size: 18,
                  color: AppColors.primary.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _AnimatedProductCard extends StatelessWidget {
  const _AnimatedProductCard({
    required this.animation,
    required this.delay,
    required this.angle,
    required this.width,
    required this.height,
    required this.asset,
  });

  final Animation<double> animation;
  final double delay;
  final double angle;
  final double width;
  final double height;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final t = Curves.easeOutCubic.transform(
          ((animation.value - delay) / (1 - delay)).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * 28),
            child: Transform.rotate(
              angle: angle * t,
              child: child,
            ),
          ),
        );
      },
      child: _ProductCard(
        width: width,
        height: height,
        asset: asset,
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  const _ProductCard({
    required this.width,
    required this.height,
    required this.asset,
  });

  final double width;
  final double height;
  final String asset;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return ColoredBox(
              color: Colors.grey.shade200,
              child: Icon(
                Icons.checkroom_outlined,
                color: AppColors.primary.withValues(alpha: 0.7),
                size: 36,
              ),
            );
          },
        ),
      ),
    );
  }
}
