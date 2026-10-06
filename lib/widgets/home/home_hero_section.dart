import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

class HomeHeroSection extends StatefulWidget {
  const HomeHeroSection({super.key, this.userName});

  final String? userName;

  @override
  State<HomeHeroSection> createState() => _HomeHeroSectionState();
}

class _HomeHeroSectionState extends State<HomeHeroSection> {
  PageController? _pageController;
  double _viewportFraction = 1.0;
  int _page = 0;
  Timer? _autoPlay;

  /// Platform editorial slides — trimmed RGBA cutouts (no photo background).
  static const _slides = <_HeroSlide>[
    _HeroSlide(
      // Deep cocoa — clean contrast with terracotta bag cutout (was loud gold).
      background: Color(0xFF4A2F28),
      accent: Color(0xFFE9C3B4),
      imageAsset: 'assets/images/home/banners/cutout_bags.png',
    ),
    _HeroSlide(
      background: Color(0xFFC0603C),
      accent: Color(0xFFE9C3B4),
      imageAsset: 'assets/images/home/banners/cutout_girl.png',
    ),
    _HeroSlide(
      background: Color(0xFF1A8FE3),
      accent: Color(0xFF64B5F6),
      imageAsset: 'assets/images/home/banners/cutout_model.png',
    ),
    _HeroSlide(
      background: Color(0xFFE85D04),
      accent: Color(0xFFFF9E6D),
      imageAsset: 'assets/images/home/banners/cutout_shoes.png',
    ),
    _HeroSlide(
      background: Color(0xFF7B2CBF),
      accent: Color(0xFFB388FF),
      imageAsset: 'assets/images/home/banners/cutout_headphones.png',
    ),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Portrait tablet: slight peek. Landscape: full-bleed in the wide column
    // so the hero doesn't read as a floating phone card.
    final isTablet = AppBreakpoints.isTablet(context);
    final fraction = !isTablet
        ? 1.0
        : (AppBreakpoints.isLandscape(context) ? 1.0 : 0.92);
    if (_pageController == null || _viewportFraction != fraction) {
      final oldPage = _pageController?.hasClients == true
          ? (_pageController!.page?.round() ?? _page)
          : _page;
      _pageController?.dispose();
      _viewportFraction = fraction;
      _pageController = PageController(
        initialPage: oldPage,
        viewportFraction: fraction,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _autoPlay = Timer.periodic(const Duration(seconds: 4), (_) {
      final controller = _pageController;
      if (!mounted || controller == null || !controller.hasClients) return;
      final next = (_page + 1) % _slides.length;
      controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
      );
    });
  }

  @override
  void dispose() {
    _autoPlay?.cancel();
    _pageController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isTablet = AppBreakpoints.isTablet(context);
    final isLandscape = AppBreakpoints.isLandscape(context);
    final bannerHeight = !isTablet
        ? 168.0
        : (isLandscape ? 268.0 : 232.0);
    final controller = _pageController;
    if (controller == null) return const SizedBox.shrink();
    final showPeek = isTablet && !isLandscape;

    return Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: AppBreakpoints.homeMaxWidth(context),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            isTablet ? 24 : 16,
            12,
            isTablet ? 24 : 16,
            4,
          ),
          child: Column(
            children: [
              SizedBox(
                height: bannerHeight,
                child: PageView.builder(
                  controller: controller,
                  itemCount: _slides.length,
                  onPageChanged: (i) => setState(() => _page = i),
                  itemBuilder: (context, index) {
                    final slide = _slides[index];
                    return Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: showPeek ? 6 : 0,
                      ),
                      child: _HeroBannerCard(
                        slide: slide,
                        title: t.homeBigSaleTitle,
                        offer: t.homeBigSaleOffer,
                        subtitle: t.homeBigSaleNow,
                        bannerHeight: bannerHeight,
                        isTablet: isTablet,
                        isLandscape: isLandscape,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(_slides.length, (i) {
                  final active = i == _page;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 22 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.primary
                          : AppColors.primary.withValues(alpha: 0.28),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSlide {
  const _HeroSlide({
    required this.background,
    required this.accent,
    required this.imageAsset,
  });

  final Color background;
  final Color accent;
  final String imageAsset;
}

class _HeroBannerCard extends StatelessWidget {
  const _HeroBannerCard({
    required this.slide,
    required this.title,
    required this.offer,
    required this.subtitle,
    required this.bannerHeight,
    required this.isTablet,
    required this.isLandscape,
  });

  final _HeroSlide slide;
  final String title;
  final String offer;
  final String subtitle;
  final double bannerHeight;
  final bool isTablet;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    final titleSize = !isTablet ? 28.0 : (isLandscape ? 40.0 : 34.0);
    final offerSize = !isTablet ? 16.0 : (isLandscape ? 20.0 : 18.0);
    final textMaxWidth = !isTablet ? 168.0 : (isLandscape ? 360.0 : 280.0);

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: slide.background,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned(
              top: -36,
              left: -28,
              child: _WaveBlob(
                color: slide.accent.withValues(alpha: 0.45),
                size: 110,
              ),
            ),
            Positioned(
              bottom: -40,
              left: 40,
              child: _WaveBlob(
                color: slide.accent.withValues(alpha: 0.28),
                size: 120,
              ),
            ),
            Positioned(
              top: -20,
              right: 40,
              child: _WaveBlob(
                color: Colors.white.withValues(alpha: 0.12),
                size: 90,
              ),
            ),
            // Cutout subject — floats on the color, bottom-right.
            Positioned(
              right: isTablet ? 8 : 4,
              bottom: 0,
              top: isTablet ? 8 : 4,
              width: isTablet ? bannerHeight * 1.35 : bannerHeight * 1.1,
              child: Image.asset(
                slide.imageAsset,
                fit: BoxFit.contain,
                alignment: Alignment.bottomCenter,
                filterQuality: FilterQuality.medium,
                errorBuilder: (context, error, stackTrace) {
                  debugPrint('Hero cutout failed: ${slide.imageAsset} $error');
                  return const SizedBox.shrink();
                },
              ),
            ),
            // Copy stays on the left over the solid color.
            Positioned(
              left: isTablet ? 28 : 20,
              top: isTablet ? 26 : 22,
              bottom: isTablet ? 26 : 22,
              width: textMaxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.display(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.05,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    offer,
                    style: AppTypography.style(
                      fontSize: offerSize,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.95),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    subtitle,
                    style: AppTypography.style(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveBlob extends StatelessWidget {
  const _WaveBlob({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(size * 0.45),
      ),
    );
  }
}
