import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/catalog_category.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:frip_cash/widgets/safe_network_image.dart';

/// Step 1 UI: callout + Nest catalog category grid + subcategory dropdown.
class SellCategoryStep extends StatelessWidget {
  const SellCategoryStep({
    super.key,
    required this.roots,
    required this.subcategories,
    required this.selectedRootId,
    required this.selectedSubId,
    required this.loading,
    this.error,
    required this.onRetry,
    required this.onRootSelected,
    required this.onSubSelected,
  });

  final List<CatalogCategory> roots;
  final List<CatalogCategory> subcategories;
  final String? selectedRootId;
  final String? selectedSubId;
  final bool loading;
  final String? error;
  final VoidCallback onRetry;
  final ValueChanged<CatalogCategory> onRootSelected;
  final ValueChanged<CatalogCategory> onSubSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final locale = Localizations.localeOf(context).languageCode;

    return ListView(
      key: const PageStorageKey<String>('sell-category-step'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        _StepCallout(
          title: t.sellStep1CalloutTitle,
          body: t.sellStep1CalloutBody,
        ),
        const SizedBox(height: 22),
        Text(
          t.chooseACategory,
          style: AppTypography.display(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
        ),
        const SizedBox(height: 14),
        if (loading && roots.isEmpty)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 48),
            child: Center(child: CircularProgressIndicator()),
          )
        else if (roots.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Column(
              children: [
                Text(
                  error ?? t.catalogLoadError,
                  style: AppTypography.style(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                TextButton(onPressed: onRetry, child: Text(t.retryAction)),
              ],
            ),
          )
        else
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: roots.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              // Landscape tiles (~1.65:1), similar to podcast category cards.
              childAspectRatio: 1.65,
            ),
            itemBuilder: (context, index) {
              final cat = roots[index];
              final isSelected = cat.id == selectedRootId;
              return _CategoryCard(
                label: cat.labelForLocale(locale),
                imageUrl: cat.imageUrl,
                selected: isSelected,
                onTap: () => onRootSelected(cat),
              );
            },
          ),
        if (subcategories.isNotEmpty) ...[
          const SizedBox(height: 22),
          Text(
            t.subcategoryLabel,
            style: AppTypography.style(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _SubcategoryField(
            value: selectedSubId,
            options: subcategories,
            locale: locale,
            onChanged: onSubSelected,
          ),
        ],
      ],
    );
  }
}

class _StepCallout extends StatelessWidget {
  const _StepCallout({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: AppColors.rosePoudre.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.explore_outlined,
            color: AppColors.primary,
            size: 22,
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
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: AppTypography.style(
                    fontSize: 13,
                    height: 1.35,
                    color: AppColors.primary.withValues(alpha: 0.85),
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

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    required this.label,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String? imageUrl;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected ? AppColors.primary : Colors.transparent,
              width: 2.2,
            ),
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (imageUrl != null && imageUrl!.isNotEmpty)
                SafeNetworkImage(url: imageUrl!, fit: BoxFit.cover)
              else
                ColoredBox(
                  color: AppColors.rosePoudre,
                  child: Icon(
                    Icons.category_outlined,
                    color: AppColors.primary,
                    size: 40,
                  ),
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
                left: 8,
                right: 8,
                bottom: 8,
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.style(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    height: 1.15,
                  ),
                ),
              ),
              if (selected)
                Positioned(
                  top: 6,
                  right: 6,
                  child: Container(
                    width: 22,
                    height: 22,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      size: 14,
                      color: Colors.white,
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

class _SubcategoryField extends StatelessWidget {
  const _SubcategoryField({
    required this.value,
    required this.options,
    required this.locale,
    required this.onChanged,
  });

  final String? value;
  final List<CatalogCategory> options;
  final String locale;
  final ValueChanged<CatalogCategory> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF7EDE7),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          key: ValueKey<String>('sell-sub-${options.map((e) => e.id).join('-')}'),
          isExpanded: true,
          value: value,
          hint: Text(
            t.chooseShopCategory,
            style: AppTypography.style(
              fontSize: 15,
              color: AppColors.textSecondary,
            ),
          ),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color: AppColors.textPrimary,
          ),
          items: [
            for (final sub in options)
              DropdownMenuItem(
                value: sub.id,
                child: Text(
                  sub.labelForLocale(locale),
                  style: AppTypography.style(fontSize: 15),
                ),
              ),
          ],
          onChanged: (id) {
            if (id == null) return;
            final match = options.where((s) => s.id == id);
            if (match.isEmpty) return;
            onChanged(match.first);
          },
        ),
      ),
    );
  }
}
