import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/mock/mock_products.dart';
import 'package:frip_cash/models/catalog_list_filters.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/models/product.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/price_formatter.dart';

Future<CatalogListFilters?> showCatalogProductFilterSheet(
  BuildContext context, {
  required CatalogListFilters initial,
  required List<String> conditions,
}) {
  return showModalBottomSheet<CatalogListFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CatalogProductFilterSheet(
      initial: initial,
      conditions: conditions,
    ),
  );
}

Future<CatalogShopFilters?> showCatalogShopFilterSheet(
  BuildContext context, {
  required CatalogShopFilters initial,
}) {
  return showModalBottomSheet<CatalogShopFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _CatalogShopFilterSheet(initial: initial),
  );
}

class _CatalogProductFilterSheet extends StatefulWidget {
  const _CatalogProductFilterSheet({
    required this.initial,
    required this.conditions,
  });

  final CatalogListFilters initial;
  final List<String> conditions;

  @override
  State<_CatalogProductFilterSheet> createState() =>
      _CatalogProductFilterSheetState();
}

class _CatalogProductFilterSheetState extends State<_CatalogProductFilterSheet> {
  late CatalogSortOption _sort;
  String? _condition;
  late bool _inStockOnly;
  late double _minPrice;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    _sort = widget.initial.sort;
    _condition = widget.initial.condition;
    _inStockOnly = widget.initial.inStockOnly;
    _minPrice = widget.initial.minPrice.toDouble();
    _maxPrice = widget.initial.maxPrice.toDouble();
  }

  int get _priceDivisions {
    final span = catalogMaxPrice - catalogMinPrice;
    if (span <= 0) return 1;
    return (span / 5000).round().clamp(10, 40);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHandle(),
            const SizedBox(height: 16),
            Text(
              t.filterTitle,
              textAlign: TextAlign.center,
              style: AppTypography.style(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(t.filterSort),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: t.sortRecommended,
                  selected: _sort == CatalogSortOption.recommended,
                  onTap: () =>
                      setState(() => _sort = CatalogSortOption.recommended),
                ),
                _ChoiceChip(
                  label: t.sortPriceLow,
                  selected: _sort == CatalogSortOption.priceLow,
                  onTap: () =>
                      setState(() => _sort = CatalogSortOption.priceLow),
                ),
                _ChoiceChip(
                  label: t.sortPriceHigh,
                  selected: _sort == CatalogSortOption.priceHigh,
                  onTap: () =>
                      setState(() => _sort = CatalogSortOption.priceHigh),
                ),
                _ChoiceChip(
                  label: t.sortNewest,
                  selected: _sort == CatalogSortOption.newest,
                  onTap: () => setState(() => _sort = CatalogSortOption.newest),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel(t.filterCondition),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: t.all,
                  selected: _condition == null,
                  onTap: () => setState(() => _condition = null),
                ),
                for (final condition in widget.conditions)
                  _ChoiceChip(
                    label: condition,
                    selected: _condition == condition,
                    onTap: () => setState(() => _condition = condition),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _SectionLabel(t.filterPriceRange),
            const SizedBox(height: 4),
            Text(
              t.filterPriceRangeValue(
                formatPrice(_minPrice.round()),
                formatPrice(_maxPrice.round()),
              ),
              style: AppTypography.style(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
            RangeSlider(
              values: RangeValues(_minPrice, _maxPrice),
              min: catalogMinPrice.toDouble(),
              max: catalogMaxPrice.toDouble(),
              divisions: _priceDivisions,
              activeColor: AppColors.primary,
              labels: RangeLabels(
                formatPrice(_minPrice.round()),
                formatPrice(_maxPrice.round()),
              ),
              onChanged: (values) {
                setState(() {
                  _minPrice = values.start;
                  _maxPrice = values.end;
                });
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${formatPrice(catalogMinPrice)} GNF',
                  style: AppTypography.style(fontSize: 12),
                ),
                Text(
                  '${formatPrice(catalogMaxPrice)} GNF',
                  style: AppTypography.style(fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 18),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                t.filterInStockOnly,
                style: AppTypography.style(fontWeight: FontWeight.w500),
              ),
              value: _inStockOnly,
              activeThumbColor: Colors.white,
              activeTrackColor: AppColors.primary,
              onChanged: (value) => setState(() => _inStockOnly = value),
            ),
            const SizedBox(height: 20),
            _SheetActions(
              onReset: () =>
                  Navigator.of(context).pop(CatalogListFilters.none),
              onApply: () => Navigator.of(context).pop(
                CatalogListFilters(
                  sort: _sort,
                  condition: _condition,
                  inStockOnly: _inStockOnly,
                  minPrice: _minPrice.round(),
                  maxPrice: _maxPrice.round(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CatalogShopFilterSheet extends StatefulWidget {
  const _CatalogShopFilterSheet({required this.initial});

  final CatalogShopFilters initial;

  @override
  State<_CatalogShopFilterSheet> createState() =>
      _CatalogShopFilterSheetState();
}

class _CatalogShopFilterSheetState extends State<_CatalogShopFilterSheet> {
  late CatalogShopSort _sort;

  @override
  void initState() {
    super.initState();
    _sort = widget.initial.sort;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(20, 12, 20, bottom + 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SheetHandle(),
            const SizedBox(height: 16),
            Text(
              t.filterTitle,
              textAlign: TextAlign.center,
              style: AppTypography.style(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            _SectionLabel(t.filterSort),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _ChoiceChip(
                  label: t.articlesNeufsSortBestRated,
                  selected: _sort == CatalogShopSort.bestRated,
                  onTap: () =>
                      setState(() => _sort = CatalogShopSort.bestRated),
                ),
                _ChoiceChip(
                  label: t.catalogShopSortMostProducts,
                  selected: _sort == CatalogShopSort.mostProducts,
                  onTap: () =>
                      setState(() => _sort = CatalogShopSort.mostProducts),
                ),
                _ChoiceChip(
                  label: t.catalogShopSortNameAz,
                  selected: _sort == CatalogShopSort.nameAz,
                  onTap: () => setState(() => _sort = CatalogShopSort.nameAz),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _SheetActions(
              onReset: () =>
                  Navigator.of(context).pop(CatalogShopFilters.none),
              onApply: () => Navigator.of(context).pop(
                CatalogShopFilters(sort: _sort),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.grey.shade300,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({required this.onReset, required this.onApply});

  final VoidCallback onReset;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: onReset,
            child: Text(t.filterReset),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: onApply,
            child: Text(t.filterApply),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTypography.style(
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? AppColors.primary : Colors.grey.shade300,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.style(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.primary : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

String catalogProductSortLabel(AppLocalizations t, CatalogSortOption sort) {
  return switch (sort) {
    CatalogSortOption.recommended => t.secondeMainSortRecent,
    CatalogSortOption.priceLow => t.sortPriceLow,
    CatalogSortOption.priceHigh => t.sortPriceHigh,
    CatalogSortOption.newest => t.sortNewest,
  };
}

String catalogShopSortLabel(AppLocalizations t, CatalogShopSort sort) {
  return switch (sort) {
    CatalogShopSort.bestRated => t.articlesNeufsSortBestRated,
    CatalogShopSort.mostProducts => t.catalogShopSortMostProducts,
    CatalogShopSort.nameAz => t.catalogShopSortNameAz,
  };
}

/// Collect unique conditions from a product list for the filter sheet.
List<String> catalogConditionsFrom(List<Product> products) {
  return products.map((p) => p.condition).toSet().toList()..sort();
}
