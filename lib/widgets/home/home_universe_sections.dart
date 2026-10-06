import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/articles_neufs_screen.dart';
import 'package:frip_cash/screens/enseignes_screen.dart';
import 'package:frip_cash/screens/quartier_boutiques_screen.dart';
import 'package:frip_cash/screens/seconde_main_screen.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/home_universe_counts.dart';

/// Mode + Courses entry points — four universes, two grouped sections.
class HomeUniverseSections extends StatelessWidget {
  const HomeUniverseSections({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = MockSession.instance.user;
    final zoneId = user.zoneId ?? 'zone_1';
    final quartier = homeQuartierFromAddress(user.address);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionHeader(
            title: t.homeModeSectionTitle,
            subtitle: t.homeModeSectionSubtitle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _UniverseCard(
                  title: t.listingDestinationSecondeMain,
                  subtitle: t.homeUniverseSecondeMainSubtitle,
                  countLabel: t.homeUniverseArticlesCount(totalSecondeMainCount()),
                  backgroundAsset: 'assets/images/home/categories/secondhand.jpg',
                  accent: const Color(0xFF8B4A32),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const SecondeMainScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UniverseCard(
                  title: t.listingDestinationArticlesNeufs,
                  subtitle: t.homeUniverseArticlesNeufsSubtitle,
                  countLabel:
                      t.homeUniverseArticlesCount(totalArticlesNeufsCountAll()),
                  backgroundAsset: 'assets/images/home/categories/mode.jpg',
                  accent: AppColors.primary,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ArticlesNeufsScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _SectionHeader(
            title: t.homeCoursesSectionTitle,
            subtitle: t.homeCoursesSectionSubtitle,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _UniverseCard(
                  title: t.listingDestinationQuartier,
                  subtitle: t.homeUniverseQuartierSubtitle,
                  countLabel: t.homeUniverseQuartierCount(
                    quartierShopCount(quartier),
                    quartier,
                  ),
                  backgroundAsset: 'assets/images/home/categories/grocery.jpg',
                  accent: const Color(0xFF3D6B52),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const QuartierBoutiquesScreen(),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _UniverseCard(
                  title: t.listingDestinationEnseignes,
                  subtitle: t.homeUniverseEnseignesSubtitle,
                  countLabel: t.homeUniverseEnseignesCount(
                    enseigneCountForZone(zoneId),
                  ),
                  backgroundAsset: 'assets/images/home/categories/home.jpg',
                  accent: const Color(0xFF4A7A62),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EnseignesScreen(),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// All four marketplace universes in a 2×2 grid — used on Home.
class FourUniversesGrid extends StatelessWidget {
  const FourUniversesGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final user = MockSession.instance.user;
    final zoneId = user.zoneId ?? 'zone_1';
    final quartier = homeQuartierFromAddress(user.address);

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _UniverseCard(
                title: t.listingDestinationSecondeMain,
                subtitle: t.homeUniverseSecondeMainSubtitle,
                countLabel:
                    t.homeUniverseArticlesCount(totalSecondeMainCount()),
                backgroundAsset: 'assets/images/home/categories/secondhand.jpg',
                accent: const Color(0xFF8B4A32),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const SecondeMainScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _UniverseCard(
                title: t.listingDestinationArticlesNeufs,
                subtitle: t.homeUniverseArticlesNeufsSubtitle,
                countLabel:
                    t.homeUniverseArticlesCount(totalArticlesNeufsCountAll()),
                backgroundAsset: 'assets/images/home/categories/mode.jpg',
                accent: AppColors.primary,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ArticlesNeufsScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _UniverseCard(
                title: t.listingDestinationQuartier,
                subtitle: t.homeUniverseQuartierSubtitle,
                countLabel: t.homeUniverseQuartierCount(
                  quartierShopCount(quartier),
                  quartier,
                ),
                backgroundAsset: 'assets/images/home/categories/grocery.jpg',
                accent: const Color(0xFF3D6B52),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const QuartierBoutiquesScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _UniverseCard(
                title: t.listingDestinationEnseignes,
                subtitle: t.homeUniverseEnseignesSubtitle,
                countLabel: t.homeUniverseEnseignesCount(
                  enseigneCountForZone(zoneId),
                ),
                backgroundAsset: 'assets/images/home/categories/home.jpg',
                accent: const Color(0xFF4A7A62),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EnseignesScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.style(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          subtitle,
          style: AppTypography.style(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary.withValues(alpha: 0.55),
          ),
        ),
      ],
    );
  }
}

class _UniverseCard extends StatelessWidget {
  const _UniverseCard({
    required this.title,
    required this.subtitle,
    required this.countLabel,
    required this.backgroundAsset,
    required this.accent,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final String countLabel;
  final String backgroundAsset;
  final Color accent;
  final VoidCallback onTap;

  static const _cardHeight = 172.0;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          height: _cardHeight,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: accent.withValues(alpha: 0.32),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  backgroundAsset,
                  fit: BoxFit.cover,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, _, _) => ColoredBox(color: accent),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        accent.withValues(alpha: 0.72),
                        accent.withValues(alpha: 0.38),
                        Colors.black.withValues(alpha: 0.62),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.08),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: -18,
                  left: -12,
                  child: _GlowOrb(
                    color: Colors.white.withValues(alpha: 0.14),
                    size: 64,
                  ),
                ),
                Positioned(
                  bottom: -22,
                  left: 28,
                  child: _GlowOrb(
                    color: accent.withValues(alpha: 0.35),
                    size: 72,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 12, 13),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.style(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.12,
                          letterSpacing: -0.2,
                        ).copyWith(
                          shadows: const [
                            Shadow(
                              color: Color(0x66000000),
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.style(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withValues(alpha: 0.9),
                          height: 1.25,
                        ),
                      ),
                      const Spacer(),
                      _CountPill(label: countLabel),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.28),
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.22),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            child: Text(
              label,
              style: AppTypography.style(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white.withValues(alpha: 0.96),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
      ),
    );
  }
}
