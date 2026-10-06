import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/browse_category.dart';
import 'package:frip_cash/models/catalog_category.dart';
import 'package:frip_cash/screens/browse_category_screen.dart';
import 'package:frip_cash/services/catalog_repository.dart';
import 'package:frip_cash/theme/app_breakpoints.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';

/// Home category pills from `GET /catalog/categories` — no section header.
class HomeCategoriesGrid extends StatefulWidget {
  const HomeCategoriesGrid({super.key});

  @override
  State<HomeCategoriesGrid> createState() => _HomeCategoriesGridState();
}

class _HomeCategoriesGridState extends State<HomeCategoriesGrid> {
  /// `all` or a Nest category id.
  String _selectedId = 'all';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      CatalogRepository.instance.refreshCategories(force: true);
    });
  }

  void _onSelect(BuildContext context, String id, CatalogCategory? category) {
    setState(() => _selectedId = id);
    if (id == 'all' || category == null) return;
    final repo = CatalogRepository.instance;
    final browse = BrowseCategory.fromCatalog(
      category,
      childIds: repo.childrenOf(category.id).map((e) => e.id).toList(),
    );
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BrowseCategoryScreen(category: browse),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;
    final isTablet = AppBreakpoints.isTablet(context);
    final sidePad = isTablet ? 24.0 : 16.0;

    return ListenableBuilder(
      listenable: CatalogRepository.instance,
      builder: (context, _) {
        final roots = CatalogRepository.instance.rootCategories;
        final loading = CatalogRepository.instance.isCategoriesLoading;
        final error = CatalogRepository.instance.error;

        if (loading && roots.isEmpty) {
          return const SizedBox(
            height: 48,
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }

        if (roots.isEmpty) {
          return Padding(
            padding: EdgeInsets.fromLTRB(sidePad, 12, sidePad, 4),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    error ?? t.catalogLoadError,
                    style: AppTypography.style(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () => CatalogRepository.instance
                      .refreshCategories(force: true),
                  child: Text(t.retryAction),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.only(top: 12, bottom: 4),
          child: SizedBox(
            height: isTablet ? 44 : 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: sidePad),
              itemCount: roots.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _CategoryPill(
                    label: t.all,
                    selected: _selectedId == 'all',
                    onTap: () => _onSelect(context, 'all', null),
                  );
                }
                final category = roots[index - 1];
                return _CategoryPill(
                  label: category.labelForLocale(locale),
                  selected: _selectedId == category.id,
                  onTap: () => _onSelect(context, category.id, category),
                );
              },
            ),
          ),
        );
      },
    );
  }
}

class _CategoryPill extends StatelessWidget {
  const _CategoryPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final isTablet = AppBreakpoints.isTablet(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(
            horizontal: isTablet ? 18 : 16,
            vertical: isTablet ? 10 : 9,
          ),
          decoration: BoxDecoration(
            color: selected ? AppColors.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.28),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Text(
            label,
            style: AppTypography.style(
              fontSize: isTablet ? 15 : 14,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              color: selected
                  ? Colors.white
                  : AppColors.textPrimary.withValues(alpha: 0.55),
            ),
          ),
        ),
      ),
    );
  }
}
