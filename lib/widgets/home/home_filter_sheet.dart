import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/home_filters.dart';
import 'package:frip_cash/models/seller_type.dart';
import 'package:frip_cash/services/listings_repository.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/utils/price_formatter.dart';
import 'package:frip_cash/utils/product_lookup.dart';

Future<HomeFilters?> showHomeFilterSheet(
  BuildContext context, {
  required HomeFilters initial,
}) {
  return showModalBottomSheet<HomeFilters>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.background,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => _HomeFilterSheet(initial: initial),
  );
}

class _HomeFilterSheet extends StatefulWidget {
  const _HomeFilterSheet({required this.initial});

  final HomeFilters initial;

  @override
  State<_HomeFilterSheet> createState() => _HomeFilterSheetState();
}

class _HomeFilterSheetState extends State<_HomeFilterSheet> {
  late HomeSortOption _sort;
  SellerType? _sellerType;
  String? _condition;
  late bool _inStockOnly;
  late double _minPrice;
  late double _maxPrice;

  @override
  void initState() {
    super.initState();
    _sort = widget.initial.sort;
    _sellerType = widget.initial.sellerType;
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

  Iterable<String> get _conditions =>
      ListingsRepository.instance.allCached
          .map((p) => p.condition)
          .toSet()
          .toList()
        ..sort();

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
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
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
                selected: _sort == HomeSortOption.recommended,
                onTap: () => setState(() => _sort = HomeSortOption.recommended),
              ),
              _ChoiceChip(
                label: t.sortPriceLow,
                selected: _sort == HomeSortOption.priceLow,
                onTap: () => setState(() => _sort = HomeSortOption.priceLow),
              ),
              _ChoiceChip(
                label: t.sortPriceHigh,
                selected: _sort == HomeSortOption.priceHigh,
                onTap: () => setState(() => _sort = HomeSortOption.priceHigh),
              ),
              _ChoiceChip(
                label: t.sortNewest,
                selected: _sort == HomeSortOption.newest,
                onTap: () => setState(() => _sort = HomeSortOption.newest),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SectionLabel(t.filterSellerType),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ChoiceChip(
                label: t.all,
                selected: _sellerType == null,
                onTap: () => setState(() => _sellerType = null),
              ),
              _ChoiceChip(
                label: t.individualSellerRole,
                selected: _sellerType == SellerType.particulier,
                onTap: () =>
                    setState(() => _sellerType = SellerType.particulier),
              ),
              _ChoiceChip(
                label: t.shopRole,
                selected: _sellerType == SellerType.boutique,
                onTap: () => setState(() => _sellerType = SellerType.boutique),
              ),
              _ChoiceChip(
                label: t.partnerBrandLabel,
                selected: _sellerType == SellerType.enseigne,
                onTap: () => setState(() => _sellerType = SellerType.enseigne),
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
              for (final condition in _conditions)
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
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(HomeFilters.none),
                  child: Text(t.filterReset),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton(
                  onPressed: () {
                    Navigator.of(context).pop(
                      HomeFilters(
                        sort: _sort,
                        sellerType: _sellerType,
                        sellerPill: switch (_sellerType) {
                          null => HomeSellerPill.all,
                          SellerType.particulier =>
                            HomeSellerPill.particuliers,
                          SellerType.boutique => HomeSellerPill.boutiques,
                          SellerType.enseigne => HomeSellerPill.enseignes,
                        },
                        condition: _condition,
                        inStockOnly: _inStockOnly,
                        minPrice: _minPrice.round(),
                        maxPrice: _maxPrice.round(),
                      ),
                    );
                  },
                  child: Text(t.filterApply),
                ),
              ),
            ],
          ),
          ],
        ),
      ),
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
