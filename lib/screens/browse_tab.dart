import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/browse_category.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/screens/browse_category_screen.dart';
import 'package:frip_cash/services/catalog_repository.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/safe_notify.dart';
import 'package:frip_cash/widgets/product_card.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

/// Browse surface aligned with the terracotta / cream charte.
abstract final class _BrowsePalette {
  static const background = AppColors.background;
  static const hint = AppColors.textSecondary;
}

class BrowseTab extends StatefulWidget {
  const BrowseTab({super.key});

  @override
  State<BrowseTab> createState() => _BrowseTabState();
}

class _BrowseTabState extends State<BrowseTab> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() {
      final next = _searchController.text.trim();
      if (next == _searchQuery) return;
      setState(() => _searchQuery = next);
    });
    runAfterFrame(() {
      CatalogRepository.instance.refreshCategories();
      ListingsRepository.instance.prefetchDiscovery();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<BrowseCategory> get _liveCategories {
    final repo = CatalogRepository.instance;
    return repo.rootCategories
        .map(
          (c) => BrowseCategory.fromCatalog(
            c,
            childIds: repo.childrenOf(c.id).map((e) => e.id).toList(),
          ),
        )
        .toList();
  }

  List<BrowseCategory> _matchingCategories() {
    final query = _searchQuery.toLowerCase();
    final all = _liveCategories;
    if (query.isEmpty) return all;
    final locale = Localizations.localeOf(context).languageCode;
    return all.where((c) {
      return c.labelForLocale(locale).toLowerCase().contains(query);
    }).toList();
  }

  String _labelFor(BrowseCategory category) {
    return category.labelForLocale(
      Localizations.localeOf(context).languageCode,
    );
  }

  List<Product> get _matchingProducts {
    final query = _searchQuery.toLowerCase();
    if (query.isEmpty) return const [];
    return ListingsRepository.instance.allCached.where((p) {
      final haystack = [
        p.title,
        p.brand ?? '',
        p.description ?? '',
        p.categoryId,
      ].join(' ').toLowerCase();
      return haystack.contains(query);
    }).toList();
  }

  SliverGridDelegateWithFixedCrossAxisCount _categoryGridDelegate(
    int cols,
    bool isTablet,
  ) {
    return SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: cols,
      mainAxisSpacing: isTablet ? 14 : 12,
      crossAxisSpacing: isTablet ? 14 : 12,
      childAspectRatio: isTablet ? 1.12 : 1.05,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final topInset = MediaQuery.paddingOf(context).top;
    final searching = _searchQuery.isNotEmpty;
    final categories = _matchingCategories();
    final products = _matchingProducts;
    final isTablet = AppBreakpoints.isTablet(context);
    final contentWidth = AppBreakpoints.homeMaxWidth(context);
    final sidePad = isTablet ? 24.0 : 16.0;
    final categoryCols =
        AppBreakpoints.browseCategoryCrossAxisCount(context);

    return ListenableBuilder(
      listenable: Listenable.merge([
        ListingsRepository.instance,
        CatalogRepository.instance,
      ]),
      builder: (context, _) {
        final liveCategories = searching ? categories : _liveCategories;
        final liveProducts = searching ? _matchingProducts : products;
        final loadingCats = CatalogRepository.instance.isCategoriesLoading &&
            CatalogRepository.instance.rootCategories.isEmpty;

        return ColoredBox(
          color: _BrowsePalette.background,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: contentWidth),
              child: CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.fromLTRB(
                        sidePad,
                        topInset + (isTablet ? 14 : 10),
                        sidePad,
                        isTablet ? 20 : 16,
                      ),
                      child: _BrowseSearchBar(controller: _searchController),
                    ),
                  ),
                  if (loadingCats)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 48),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (!searching && liveCategories.isEmpty)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(sidePad, 32, sidePad, 28),
                        child: Column(
                          children: [
                            Text(
                              CatalogRepository.instance.error ??
                                  t.catalogLoadError,
                              textAlign: TextAlign.center,
                              style: AppTypography.style(
                                fontSize: 15,
                                color: _BrowsePalette.hint,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextButton(
                              onPressed: () => CatalogRepository.instance
                                  .refreshCategories(force: true),
                              child: Text(t.retryAction),
                            ),
                          ],
                        ),
                      ),
                    )
                  else if (!searching)
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(sidePad, 0, sidePad, 28),
                      sliver: SliverGrid(
                        gridDelegate:
                            _categoryGridDelegate(categoryCols, isTablet),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final category = liveCategories[index];
                            return _IllustratedCategoryCard(
                              category: category,
                              label: _labelFor(category),
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => BrowseCategoryScreen(
                                      category: category,
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                          childCount: liveCategories.length,
                        ),
                      ),
                    )
                  else ...[
                    if (categories.isNotEmpty)
                      SliverPadding(
                        padding:
                            EdgeInsets.fromLTRB(sidePad, 0, sidePad, 12),
                        sliver: SliverGrid(
                          gridDelegate:
                              _categoryGridDelegate(categoryCols, isTablet),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final category = categories[index];
                              return _IllustratedCategoryCard(
                                category: category,
                                label: _labelFor(category),
                                onTap: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => BrowseCategoryScreen(
                                        category: category,
                                      ),
                                    ),
                                  );
                                },
                              );
                            },
                            childCount: categories.length,
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          sidePad + 4,
                          8,
                          sidePad + 4,
                          12,
                        ),
                        child: Text(
                          liveProducts.isEmpty
                              ? t.searchNoResults
                              : t.searchResultsCount(liveProducts.length),
                          style: AppTypography.style(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: _BrowsePalette.hint,
                          ),
                        ),
                      ),
                    ),
                    if (liveProducts.isNotEmpty)
                      SliverPadding(
                        padding:
                            EdgeInsets.fromLTRB(sidePad, 0, sidePad, 28),
                        sliver: SliverGrid(
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount:
                                AppBreakpoints.productGridCrossAxisCount(
                              context,
                            ),
                            crossAxisSpacing: 12,
                            mainAxisSpacing:
                                AppBreakpoints.productGridMainAxisSpacing(
                              context,
                            ),
                            childAspectRatio:
                                AppBreakpoints.productGridChildAspectRatio(
                              context,
                            ),
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (context, index) {
                              final product = liveProducts[index];
                              return ProductCard(
                                product: product,
                                onTap: () =>
                                    openProductDetail(context, product),
                              );
                            },
                            childCount: liveProducts.length,
                          ),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _BrowseSearchBar extends StatefulWidget {
  const _BrowseSearchBar({required this.controller});

  final TextEditingController controller;

  @override
  State<_BrowseSearchBar> createState() => _BrowseSearchBarState();
}

class _BrowseSearchBarState extends State<_BrowseSearchBar> {
  final _focusNode = FocusNode();
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      final next = _focusNode.hasFocus;
      if (next == _focused) return;
      setState(() => _focused = next);
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final isTablet = AppBreakpoints.isTablet(context);

    return ListenableBuilder(
      listenable: widget.controller,
      builder: (context, _) {
        final hasText = widget.controller.text.isNotEmpty;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          height: isTablet ? 52 : 48,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(
              color: _focused
                  ? AppColors.primary.withValues(alpha: 0.55)
                  : const Color(0xFFD8DCE3),
              width: _focused ? 1.5 : 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: _focused ? 0.10 : 0.06),
                blurRadius: _focused ? 14 : 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.only(left: 16, right: 6),
          child: Row(
            children: [
              AppIcon(
                AppIcons.search,
                size: 22,
                color: AppColors.textPrimary.withValues(alpha: 0.45),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: _focusNode,
                  textInputAction: TextInputAction.search,
                  style: AppTypography.style(
                    fontSize: isTablet ? 16 : 15,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                  cursorColor: AppColors.primary,
                  decoration: InputDecoration(
                    isDense: true,
                    hintText: t.browseSearchHint,
                    hintStyle: AppTypography.style(
                      fontSize: isTablet ? 16 : 15,
                      fontWeight: FontWeight.w400,
                      color: AppColors.textPrimary.withValues(alpha: 0.42),
                    ),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),
              if (hasText)
                IconButton(
                  onPressed: widget.controller.clear,
                  icon: AppIcon(
                    AppIcons.close,
                    size: 18,
                    color: AppColors.textPrimary.withValues(alpha: 0.5),
                  ),
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints:
                      const BoxConstraints(minWidth: 36, minHeight: 36),
                ),
            ],
          ),
        );
      },
    );
  }
}

class _IllustratedCategoryCard extends StatefulWidget {
  const _IllustratedCategoryCard({
    required this.category,
    required this.label,
    required this.onTap,
  });

  final BrowseCategory category;
  final String label;
  final VoidCallback onTap;

  @override
  State<_IllustratedCategoryCard> createState() =>
      _IllustratedCategoryCardState();
}

class _IllustratedCategoryCardState extends State<_IllustratedCategoryCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppBreakpoints.isTablet(context);
    final titleSize = isTablet ? 16.0 : 15.0;
    final titleInset = isTablet ? 14.0 : 12.0;
    final imageUrl = widget.category.imageUrl;

    return AnimatedScale(
      scale: _pressed ? 0.975 : 1,
      duration: const Duration(milliseconds: 120),
      curve: Curves.easeOut,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: widget.onTap,
          onHighlightChanged: (v) => setState(() => _pressed = v),
          borderRadius: BorderRadius.circular(16),
          splashColor: Colors.white.withValues(alpha: 0.12),
          highlightColor: Colors.white.withValues(alpha: 0.06),
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null && imageUrl.isNotEmpty)
                SafeNetworkImage(
                  url: imageUrl,
                  fit: BoxFit.cover,
                )
              else
                ColoredBox(color: widget.category.accentColor),
              // Dark overlay so white title stays readable.
              const ColoredBox(color: Color(0x66000000)),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.15),
                      Colors.black.withValues(alpha: 0.55),
                    ],
                  ),
                ),
              ),
              Positioned(
                left: titleInset,
                right: titleInset,
                bottom: titleInset,
                child: Text(
                  widget.label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.style(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

