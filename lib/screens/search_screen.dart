import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/home_filters.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/navigation/product_navigation.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/home_universe_counts.dart';
import 'package:frip_cash/widgets/home/home_feed_grid.dart';
import 'package:frip_cash/widgets/home/home_filter_sheet.dart';

/// Dedicated marketplace search (mock catalog).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key, this.initialQuery = ''});

  final String initialQuery;

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  late final TextEditingController _controller;
  HomeFilters _filters = HomeFilters.none;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  List<Product> get _results {
    final query = _controller.text.trim();
    var list = List<Product>.of(ListingsRepository.instance.allCached);
    if (query.isNotEmpty) {
      list = list.where((p) => productMatchesHomeSearch(p, query)).toList();
    }
    return _filters.applyFilters(list);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final results = _results;
    final query = _controller.text.trim();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        title: Text(
          t.searchScreenTitle,
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 17),
        ),
        actions: [
          IconButton(
            tooltip: t.listingFilterTitle,
            onPressed: () async {
              final next = await showHomeFilterSheet(
                context,
                initial: _filters,
              );
              if (next == null || !mounted) return;
              setState(() => _filters = next);
            },
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: t.searchScreenHint,
                prefixIcon: Icon(
                  AppIcons.search,
                  color: AppColors.textPrimary.withValues(alpha: 0.45),
                ),
                suffixIcon: query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => _controller.clear(),
                      ),
                filled: true,
                fillColor: const Color(0xFFF5F5F5),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
              style: AppTypography.style(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          if (query.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  t.searchResultsCount(results.length),
                  style: AppTypography.style(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary.withValues(alpha: 0.65),
                  ),
                ),
              ),
            ),
          Expanded(
            child: query.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        t.searchScreenHint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.textPrimary.withValues(alpha: 0.55),
                        ),
                      ),
                    ),
                  )
                : results.isEmpty
                    ? Center(child: Text(t.searchNoResults))
                    : CustomScrollView(
                        slivers: [
                          ...HomeFeedGrid.buildSlivers(
                            context: context,
                            products: results,
                            visibleCount: results.length,
                            isLoadingMore: false,
                            topPadding: 8,
                            onProductTap: (product) =>
                                openProductDetail(context, product),
                          ),
                          const SliverToBoxAdapter(child: SizedBox(height: 24)),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}
