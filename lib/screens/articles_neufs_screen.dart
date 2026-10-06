import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_shops.dart';
import 'package:frip_cash/models/catalog_gender.dart';
import 'package:frip_cash/models/catalog_list_filters.dart';
import 'package:frip_cash/models/listing_destination.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/screens/seller_profile_screen.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/catalog_filters.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/widgets/catalog/catalog_filter_sheet.dart';
import 'package:frip_cash/widgets/catalog/catalog_screen_widgets.dart';
import 'package:frip_cash/widgets/product_card.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';
import 'package:frip_cash/widgets/seller_rating_text.dart';
import 'package:material_symbols_icons/symbols.dart';

/// New-in-stock boutique directory — opened from home (Boutiques pill).
class ArticlesNeufsScreen extends StatefulWidget {
  const ArticlesNeufsScreen({super.key});

  @override
  State<ArticlesNeufsScreen> createState() => _ArticlesNeufsScreenState();
}

class _ArticlesNeufsScreenState extends State<ArticlesNeufsScreen> {
  CatalogGender _gender = CatalogGender.femme;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  CatalogShopFilters _filters = CatalogShopFilters.none;

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
        destination: ListingDestination.articlesNeufs,
      );
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<MockShop> get _baseShops => articlesNeufsShops(_gender);

  List<MockShop> get _shops {
    var list = _baseShops;
    final query = _searchQuery.toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where(
            (s) =>
                s.name.toLowerCase().contains(query) ||
                s.description.toLowerCase().contains(query),
          )
          .toList();
    }
    return _filters.applyFilters(
      list,
      productCount: (id) => articlesNeufsCountForShop(id, _gender),
    );
  }

  Future<void> _openFilters() async {
    final result = await showCatalogShopFilterSheet(
      context,
      initial: _filters,
    );
    if (result == null || !mounted) return;
    setState(() => _filters = result);
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
    final sidePad = AppBreakpoints.isTablet(context) ? 24.0 : 16.0;
    final maxWidth = AppBreakpoints.homeMaxWidth(context);
    final totalArticles = totalArticlesNeufsCount(_gender);
    final totalShops = articlesNeufsShops(_gender).length;

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
              t.articlesNeufsTitle,
              style: AppTypography.display(
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              t.articlesNeufsSubtitle(totalShops, totalArticles),
              style: AppTypography.style(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
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
                  padding: EdgeInsets.fromLTRB(sidePad, 8, sidePad, 0),
                  child: CatalogSearchBar(
                    controller: _searchController,
                    hint: t.articlesNeufsSearchHint,
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
                        t.articlesNeufsShopCount(shops.length, _genderLabel(t)),
                        style: AppTypography.style(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        catalogShopSortLabel(t, _filters.sort),
                        style: AppTypography.style(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (shops.isEmpty &&
                  productsForDestination(ListingDestination.articlesNeufs)
                      .isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: ListingsRepository.instance.error != null &&
                          !ListingsRepository.instance.isLoading
                      ? CatalogLoadError(
                          onRetry: () {
                            ListingsRepository.instance.fetch(
                              destination: ListingDestination.articlesNeufs,
                            );
                          },
                        )
                      : Center(
                          child: Text(
                            t.articlesNeufsEmpty,
                            style: AppTypography.style(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                )
              else if (shops.isEmpty)
                SliverPadding(
                  padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 28),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          AppBreakpoints.productGridCrossAxisCount(context),
                      crossAxisSpacing: 12,
                      mainAxisSpacing:
                          AppBreakpoints.productGridMainAxisSpacing(context),
                      childAspectRatio:
                          AppBreakpoints.productGridChildAspectRatio(context),
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final apiProducts = productsForDestination(
                          ListingDestination.articlesNeufs,
                        );
                        final product = apiProducts[index];
                        return ProductCard(
                          product: product,
                          onTap: () => openProductDetail(context, product),
                        );
                      },
                      childCount: productsForDestination(
                        ListingDestination.articlesNeufs,
                      ).length,
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
                      final shop = shops[index];
                      final articleCount =
                          articlesNeufsCountForShop(shop.sellerId, _gender);
                      return _ArticlesNeufsShopCard(
                        shop: shop,
                        articleCount: articleCount,
                        onViewShop: () => _openShop(shop),
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

  String _genderLabel(AppLocalizations t) {
    return switch (_gender) {
      CatalogGender.femme => t.catalogGenderFemme,
      CatalogGender.homme => t.catalogGenderHomme,
      CatalogGender.enfant => t.catalogGenderEnfant,
    };
  }
}

class _ArticlesNeufsShopCard extends StatelessWidget {
  const _ArticlesNeufsShopCard({
    required this.shop,
    required this.articleCount,
    required this.onViewShop,
  });

  final MockShop shop;
  final int articleCount;
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            shop.description,
                            style: AppTypography.style(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          if (shop.addressLine != null) ...[
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
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.sage.withValues(alpha: 0.16),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Symbols.local_shipping_rounded,
                                  size: 14,
                                  color: AppColors.sage,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  t.articlesNeufsDeliveredIn(shop.deliverySla),
                                  style: AppTypography.style(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.sage,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
                        const SizedBox(height: 4),
                        Text(
                          t.articlesNeufsArticleCount(articleCount),
                          style: AppTypography.style(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
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
