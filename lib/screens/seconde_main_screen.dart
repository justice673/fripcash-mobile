import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_sellers.dart';
import 'package:frip_cash/models/catalog_gender.dart';
import 'package:frip_cash/models/catalog_list_filters.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/services/favorites_store.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/catalog_filters.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/widgets/catalog/catalog_filter_sheet.dart';
import 'package:frip_cash/widgets/catalog/catalog_screen_widgets.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/seller_rating_text.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Second-hand listings from individuals — opened from home (Particuliers pill).
class SecondeMainScreen extends StatefulWidget {
  const SecondeMainScreen({super.key});

  @override
  State<SecondeMainScreen> createState() => _SecondeMainScreenState();
}

class _SecondeMainScreenState extends State<SecondeMainScreen> {
  CatalogGender _gender = CatalogGender.femme;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  CatalogListFilters _filters = CatalogListFilters.none;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final next = _searchController.text.trim();
      if (next == _searchQuery) return;
      setState(() => _searchQuery = next);
    });
    runAfterFrame(() {
      ListingsRepository.instance.fetch(
        destination: ListingDestination.secondeMain,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Product> get _baseProducts => secondeMainProducts(_gender);

  List<Product> get _products {
    var list = _baseProducts;
    final query = _searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      list = list.where((p) {
        final haystack = [
          p.title,
          p.brand ?? '',
          p.size,
          p.condition,
        ].join(' ').toLowerCase();
        return haystack.contains(query);
      }).toList();
    }
    return _filters.applyFilters(list);
  }

  Future<void> _openFilters() async {
    final result = await showCatalogProductFilterSheet(
      context,
      initial: _filters,
      conditions: catalogConditionsFrom(_baseProducts),
    );
    if (result == null || !mounted) return;
    setState(() => _filters = result);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final sidePad = AppBreakpoints.isTablet(context) ? 24.0 : 16.0;
    final maxWidth = AppBreakpoints.homeMaxWidth(context);

    return ListenableBuilder(
      listenable: ListingsRepository.instance,
      builder: (context, _) {
        final products = _products;
        final totalCount = totalSecondeMainCount(_gender);

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
        title: Column(
          children: [
            Text(
              t.secondeMainTitle,
              style: AppTypography.display(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              t.secondeMainSubtitle(totalCount),
              style: AppTypography.style(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(sidePad, 8, sidePad, 0),
                  child: CatalogSearchBar(
                    controller: _searchController,
                    hint: t.secondeMainSearchHint,
                    hasActiveFilters: _filters.hasActiveFilters,
                    onFilterTap: _openFilters,
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.only(top: 12, left: sidePad),
                  child: CatalogGenderFilterRow(
                    selected: _gender,
                    onSelected: (g) => setState(() => _gender = g),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(sidePad, 14, sidePad, 10),
                  child: Row(
                    children: [
                      Text(
                        t.secondeMainCount(products.length, _genderLabel(t)),
                        style: AppTypography.style(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        catalogProductSortLabel(t, _filters.sort),
                        style: AppTypography.style(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 32),
                sliver: products.isEmpty
                    ? SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 32),
                          child: ListingsRepository.instance.error != null &&
                                  !ListingsRepository.instance.isLoading
                              ? CatalogLoadError(
                                  onRetry: () {
                                    ListingsRepository.instance.fetch(
                                      destination:
                                          ListingDestination.secondeMain,
                                    );
                                  },
                                )
                              : Center(
                                  child: Text(
                                    t.secondeMainEmpty,
                                    style: AppTypography.style(
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ),
                        ),
                      )
                    : SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount:
                              AppBreakpoints.productGridCrossAxisCount(context),
                          crossAxisSpacing: 12,
                          mainAxisSpacing:
                              AppBreakpoints.productGridMainAxisSpacing(context),
                          childAspectRatio: 0.58,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            return _SecondeMainProductCard(
                              product: products[index],
                              onTap: () => openProductDetail(
                                context,
                                products[index],
                              ),
                            );
                          },
                          childCount: products.length,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
      },
    );
  }

  String _genderLabel(AppLocalizations t) {
    return switch (_gender) {
      CatalogGender.femme => t.catalogGenderFemme,
      CatalogGender.homme => t.catalogGenderHomme,
      CatalogGender.enfant => t.catalogGenderEnfant,
    };
  }
}

class _SecondeMainProductCard extends StatelessWidget {
  const _SecondeMainProductCard({
    required this.product,
    required this.onTap,
  });

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final seller = sellerById(product.sellerId);
    final conditionShort = _shortCondition(product.condition);

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: SafeNetworkImage(
                    url: product.image,
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    iconSize: 28,
                  ),
                ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.92),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Symbols.checkroom_rounded,
                          size: 14,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          t.secondeMainIndividualBadge,
                          style: AppTypography.style(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: ListenableBuilder(
                    listenable: FavoritesStore.instance,
                    builder: (context, _) {
                      final liked =
                          FavoritesStore.instance.isFavorite(product.id);
                      return GestureDetector(
                        onTap: () =>
                            FavoritesStore.instance.toggle(product.id),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.92),
                            shape: BoxShape.circle,
                          ),
                          child: AppIcon(
                            AppIcons.favorite,
                            size: 18,
                            filled: liked,
                            color: liked
                                ? Colors.redAccent
                                : AppColors.textPrimary,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${formatPrice(product.price)} GNF',
            style: AppTypography.style(
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            product.brand != null
                ? '${product.brand} · ${product.title}'
                : product.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.style(fontSize: 13),
          ),
          Text(
            '${product.size} · $conditionShort',
            style: AppTypography.style(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
          if (seller != null) ...[
            const SizedBox(height: 4),
            SellerRatingText(
              rating: seller.rating,
              reviewCount: seller.reviewCount,
              fontSize: 12,
            ),
          ],
        ],
      ),
    );
  }

  static String _shortCondition(String condition) {
    final lower = condition.toLowerCase();
    if (lower.contains('très bon')) return 'TBE';
    if (lower.contains('bon')) return 'Bon état';
    if (lower.contains('neuf')) return 'Neuf';
    return condition;
  }
}
