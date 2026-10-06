import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_shops.dart';
import 'package:frip_cash/mock/mock_zones.dart';
import 'package:frip_cash/models/enseigne_category.dart';
import 'package:frip_cash/screens/seller_profile_screen.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/services/mock_session.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/enseigne_category_localization.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/widgets/catalog/catalog_screen_widgets.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Partner-store directory — opened from home (Enseignes pill or partner carousel).
class EnseignesScreen extends StatefulWidget {
  const EnseignesScreen({super.key});

  @override
  State<EnseignesScreen> createState() => _EnseignesScreenState();
}

class _EnseignesScreenState extends State<EnseignesScreen> {
  late String _zoneId;
  late String _quartier;
  String _categoryId = 'all';

  @override
  void initState() {
    super.initState();
    final user = MockSession.instance.user;
    _zoneId = user.zoneId ?? '';
    _quartier = _defaultQuartier(_zoneId, user.address);
    runAfterFrame(_loadListings);
  }

  Future<void> _loadListings() {
    return ListingsRepository.instance.fetch(
      destination: ListingDestination.enseignes,
    );
  }

  static String _defaultQuartier(String zoneId, String? address) {
    if (address != null) {
      final first = address.split(',').first.trim();
      if (first.isNotEmpty) return first;
    }
    final zone = zoneById(zoneId);
    return zone?.quartiers.first ?? '';
  }

  String get _communeLabel {
    final zone = zoneById(_zoneId);
    return zone?.name ?? 'Zone 1';
  }

  List<MockShop> get _shops =>
      enseignesForZone(_zoneId, categoryId: _categoryId);

  Future<void> _pickDeliveryLocation() async {
    final t = AppLocalizations.of(context)!;
    final picked = await showModalBottomSheet<({String zoneId, String quartier})>(
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
                  t.enseignesChangeLocation,
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
                      for (final zone in mockZones)
                        for (final quartier in zone.quartiers)
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text('$quartier, ${zone.name}'),
                            trailing: _zoneId == zone.id && _quartier == quartier
                                ? const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.primary,
                                  )
                                : null,
                            onTap: () => Navigator.of(context).pop(
                              (zoneId: zone.id, quartier: quartier),
                            ),
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
    setState(() {
      _zoneId = picked.zoneId;
      _quartier = picked.quartier;
    });
  }

  void _openShop(MockShop shop) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SellerProfileScreen(sellerId: shop.sellerId),
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
          t.enseignesTitle,
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
          final repo = ListingsRepository.instance;
          final showServerError =
              repo.error != null && !repo.isLoading && shops.isEmpty;

          return Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(sidePad, 4, sidePad, 0),
                      child: _DeliveryLocationCard(
                        label: t.enseignesDeliveryTo,
                        location: '$_quartier, $_communeLabel',
                        subtitle: showServerError
                            ? t.catalogLoadError
                            : t.enseignesDeliverHereCount(shops.length),
                        changeLabel: t.enseignesChangeLocation,
                        onChange: _pickDeliveryLocation,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(top: 16, left: sidePad),
                      child: _CategoryFilterRow(
                        selected: _categoryId,
                        onSelected: (id) => setState(() => _categoryId = id),
                      ),
                    ),
                  ),
                  if (repo.isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: LinearProgressIndicator(minHeight: 2),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(sidePad, 18, sidePad, 10),
                      child: Row(
                        children: [
                          Text(
                            t.enseignesCount(shops.length),
                            style: AppTypography.style(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            t.enseignesSortDeliveryAsc,
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
                  if (showServerError)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: CatalogLoadError(onRetry: _loadListings),
                    )
                  else if (shops.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: sidePad),
                          child: Text(
                            t.enseignesEmptyForZone,
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
                      padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 32),
                      sliver: SliverList.separated(
                        itemCount: shops.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 14),
                        itemBuilder: (context, index) {
                          return _EnseigneStoreCard(
                            shop: shops[index],
                            onViewShop: () => _openShop(shops[index]),
                          );
                        },
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

class _DeliveryLocationCard extends StatelessWidget {
  const _DeliveryLocationCard({
    required this.label,
    required this.location,
    required this.subtitle,
    required this.changeLabel,
    required this.onChange,
  });

  final String label;
  final String location;
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
            color: AppColors.gold,
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
                border: Border.all(color: AppColors.gold.withValues(alpha: 0.45)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.rosePoudre,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Symbols.local_shipping_rounded,
                      size: 22,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location,
                          style: AppTypography.style(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
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

class _CategoryFilterRow extends StatelessWidget {
  const _CategoryFilterRow({
    required this.selected,
    required this.onSelected,
  });

  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 16),
        itemCount: enseigneCategoryIds.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final id = enseigneCategoryIds[index];
          final isSelected = id == selected;
          final category = enseigneCategoryById(id);
          final label =
              id == 'all' ? t.all : enseigneCategoryLabel(id, t);

          return _FilterChip(
            label: label,
            icon: category?.icon,
            selected: isSelected,
            onTap: () => onSelected(id),
          );
        },
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(999),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: icon == null ? 16 : 12,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: 1.2,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: fg),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: AppTypography.style(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EnseigneStoreCard extends StatelessWidget {
  const _EnseigneStoreCard({
    required this.shop,
    required this.onViewShop,
  });

  final MockShop shop;
  final VoidCallback onViewShop;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final rating = shop.rating.toStringAsFixed(1).replaceAll('.', ',');

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
                    Text(
                      '$rating (${shop.reviewCount})',
                      style: AppTypography.style(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                if (shop.addressLine != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 16,
                        color: AppColors.error.withValues(alpha: 0.85),
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          shop.addressLine!,
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
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Symbols.bolt_rounded,
                            size: 14,
                            color: AppColors.gold.withValues(alpha: 0.95),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            t.enseignesDeliveredIn(shop.deliveryHours),
                            style: AppTypography.style(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    OutlinedButton(
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
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
