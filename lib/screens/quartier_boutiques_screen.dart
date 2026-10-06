import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_shops.dart';
import 'package:frip_cash/mock/mock_zones.dart';
import 'package:frip_cash/screens/seller_profile_screen.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/widgets/catalog/catalog_screen_widgets.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/seller_rating_text.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Neighborhood-shop directory — opened from home (Quartier pill).
class QuartierBoutiquesScreen extends StatefulWidget {
  const QuartierBoutiquesScreen({super.key});

  @override
  State<QuartierBoutiquesScreen> createState() =>
      _QuartierBoutiquesScreenState();
}

class _QuartierBoutiquesScreenState extends State<QuartierBoutiquesScreen> {
  late String _quartier;

  @override
  void initState() {
    super.initState();
    final user = MockSession.instance.user;
    _quartier = _defaultQuartier(user.address);
    runAfterFrame(_loadListings);
  }

  Future<void> _loadListings() {
    return ListingsRepository.instance.fetch(
      destination: ListingDestination.quartierBoutiques,
    );
  }

  static String _defaultQuartier(String? address) {
    if (address != null) {
      final first = address.split(',').first.trim();
      if (first.isNotEmpty) return first;
    }
    return '';
  }

  List<MockShop> get _shops => quartierShopsForNeighborhood(_quartier);

  String get _communeLabel {
    final sample = _shops.isNotEmpty ? _shops.first : null;
    return communeLabelForQuartier(_quartier, sample);
  }

  Future<void> _pickQuartier() async {
    final t = AppLocalizations.of(context)!;
    final quartiers = <String>{
      for (final zone in mockZones) ...zone.quartiers,
    }.toList()
      ..sort();

    final picked = await showModalBottomSheet<String>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  t.quartierBoutiquesChangeNeighborhood,
                  style: AppTypography.style(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Flexible(
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      for (final quartier in quartiers)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(quartier),
                          trailing: _quartier == quartier
                              ? const Icon(
                                  Icons.check_rounded,
                                  color: AppColors.primary,
                                )
                              : null,
                          onTap: () => Navigator.of(context).pop(quartier),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (picked == null || !mounted) return;
    setState(() => _quartier = picked);
  }

  void _openShop(MockShop shop) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProfileScreen(sellerId: shop.sellerId),
      ),
    );
  }

  void _reportMissingShop() {
    final t = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(t.quartierBoutiquesReportAck),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final maxWidth = AppBreakpoints.homeMaxWidth(context);
    final sidePad = AppBreakpoints.isTablet(context) ? 24.0 : 16.0;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: true,
        title: Text(
          t.quartierBoutiquesTitle,
          style: AppTypography.display(
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: ListenableBuilder(
        listenable: ListingsRepository.instance,
        builder: (context, _) {
          final shops = _shops;
          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(sidePad, 4, sidePad, 0),
                      child: _NeighborhoodLocationCard(
                        label: t.quartierBoutiquesYourNeighborhood,
                        quartier: _quartier,
                        subtitle: '$_communeLabel · Conakry',
                        changeLabel: t.quartierBoutiquesChangeNeighborhood,
                        onChange: _pickQuartier,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(sidePad, 18, sidePad, 10),
                      child: Row(
                        children: [
                          Text(
                            t.quartierBoutiquesCount(shops.length, _quartier),
                            style: AppTypography.style(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            t.quartierBoutiquesSortNearest,
                            style: AppTypography.style(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (shops.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: ListingsRepository.instance.error != null &&
                              !ListingsRepository.instance.isLoading
                          ? CatalogLoadError(onRetry: _loadListings)
                          : Center(
                              child: Padding(
                                padding:
                                    EdgeInsets.symmetric(horizontal: sidePad),
                                child: Text(
                                  t.quartierBoutiquesEmpty,
                                  textAlign: TextAlign.center,
                                  style: AppTypography.style(
                                    fontSize: 15,
                                    color: AppColors.textSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 16),
                      sliver: SliverList.separated(
                        itemCount: shops.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _QuartierShopCard(
                            shop: shops[index],
                            onViewShop: () => _openShop(shops[index]),
                          );
                        },
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(sidePad, 8, sidePad, 32),
                      child: _ReportShopCard(
                        title: t.quartierBoutiquesReportTitle,
                        body: t.quartierBoutiquesReportBody,
                        onTap: _reportMissingShop,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _NeighborhoodLocationCard extends StatelessWidget {
  const _NeighborhoodLocationCard({
    required this.label,
    required this.quartier,
    required this.subtitle,
    required this.changeLabel,
    required this.onChange,
  });

  final String label;
  final String quartier;
  final String subtitle;
  final String changeLabel;
  final VoidCallback onChange;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTypography.style(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.sage,
          ),
        ),
        const SizedBox(height: 8),
        Material(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          child: InkWell(
            onTap: onChange,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.45),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on_rounded,
                    size: 28,
                    color: AppColors.error.withValues(alpha: 0.85),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quartier,
                          style: AppTypography.style(
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: AppTypography.style(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  TextButton(
                    onPressed: onChange,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    child: Text(
                      changeLabel,
                      style: AppTypography.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuartierShopCard extends StatelessWidget {
  const _QuartierShopCard({
    required this.shop,
    required this.onViewShop,
  });

  final MockShop shop;
  final VoidCallback onViewShop;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AspectRatio(
            aspectRatio: kShopStorefrontHeroAspectRatio,
            child: Stack(
              fit: StackFit.expand,
              children: [
                SafeNetworkImage(
                  url: shop.heroImageUrl,
                  fit: BoxFit.cover,
                  iconSize: 32,
                ),
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.05),
                        Colors.black.withValues(alpha: 0.55),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 14,
                  right: 14,
                  bottom: 12,
                  child: Text(
                    shop.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.style(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        shop.description,
                        style: AppTypography.style(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        SellerRatingText(
                          rating: shop.rating,
                          reviewCount: shop.reviewCount,
                        ),
                        if (shop.productCount != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            t.quartierBoutiquesProductCount(shop.productCount!),
                            style: AppTypography.style(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                if (shop.addressLine != null && shop.walkMinutes != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: AppColors.error.withValues(alpha: 0.75),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          t.quartierBoutiquesWalkTime(
                            shop.addressLine!,
                            shop.walkMinutes!,
                          ),
                          style: AppTypography.style(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (shop.pickupByCode)
                      _StatusBadge(
                        label: t.quartierBoutiquesPickupByCode,
                        icon: Symbols.key_rounded,
                        background: AppColors.sage.withValues(alpha: 0.16),
                        foreground: AppColors.sage,
                      ),
                    if (shop.opensAtHour != null)
                      _StatusBadge(
                        label: t.quartierBoutiquesOpensAt(shop.opensAtHour!),
                        icon: Symbols.schedule_rounded,
                        background: const Color(0xFFE8EEF5),
                        foreground: const Color(0xFF5B7A9A),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton(
                    onPressed: onViewShop,
                    style: catalogViewShopButtonStyle(),
                    child: Text(
                      t.viewShop,
                      style: AppTypography.style(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.label,
    required this.icon,
    required this.background,
    required this.foreground,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: foreground),
          const SizedBox(width: 4),
          Text(
            label,
            style: AppTypography.style(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _ReportShopCard extends StatelessWidget {
  const _ReportShopCard({
    required this.title,
    required this.body,
    required this.onTap,
  });

  final String title;
  final String body;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.rosePoudre.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: AppColors.primary, width: 3),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Symbols.add_circle_rounded,
                size: 22,
                color: AppColors.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.style(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      body,
                      style: AppTypography.style(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
