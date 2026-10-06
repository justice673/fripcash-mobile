import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/catalog_gender.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_icons.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:material_symbols_icons/symbols.dart';

class CatalogSearchBar extends StatelessWidget {
  const CatalogSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    this.onFilterTap,
    this.hasActiveFilters = false,
  });

  final TextEditingController controller;
  final String hint;
  final VoidCallback? onFilterTap;
  final bool hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: hint,
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppColors.primary, width: 1.4),
              ),
            ),
          ),
        ),
        if (onFilterTap != null) ...[
          const SizedBox(width: 10),
          Material(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(14),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: hasActiveFilters
                        ? AppColors.primary
                        : AppColors.border,
                    width: hasActiveFilters ? 1.5 : 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    AppIcon(
                      AppIcons.filter,
                      size: 22,
                      color: hasActiveFilters
                          ? AppColors.primary
                          : AppColors.textPrimary,
                    ),
                    if (hasActiveFilters)
                      Positioned(
                        top: 10,
                        right: 10,
                        child: Container(
                          width: 7,
                          height: 7,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class CatalogGenderFilterRow extends StatelessWidget {
  const CatalogGenderFilterRow({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final CatalogGender selected;
  final ValueChanged<CatalogGender> onSelected;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = [
      (CatalogGender.femme, t.catalogGenderFemme, Symbols.woman_rounded),
      (CatalogGender.homme, t.catalogGenderHomme, Symbols.man_rounded),
      (CatalogGender.enfant, t.catalogGenderEnfant, Symbols.child_care_rounded),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(right: 16),
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (gender, label, icon) = items[index];
          final isSelected = gender == selected;
          final fg = isSelected ? Colors.white : AppColors.textPrimary;
          return Material(
            color: isSelected ? AppColors.primary : AppColors.surface,
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: () => onSelected(gender),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 16, color: fg),
                    const SizedBox(width: 6),
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
        },
      ),
    );
  }
}

/// Full-width shop card hero — 16:9 reads better than a fixed 120px strip.
const double kShopStorefrontHeroAspectRatio = 16 / 9;

/// Server/load failure for catalog & directory screens.
class CatalogLoadError extends StatelessWidget {
  const CatalogLoadError({
    super.key,
    required this.onRetry,
    this.message,
  });

  final VoidCallback onRetry;
  final String? message;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.cloud_off_rounded,
              size: 40,
              color: AppColors.textSecondary.withValues(alpha: 0.7),
            ),
            const SizedBox(height: 14),
            Text(
              message ?? t.catalogLoadError,
              textAlign: TextAlign.center,
              style: AppTypography.style(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: onRetry,
              child: Text(t.retryAction),
            ),
          ],
        ),
      ),
    );
  }
}

ButtonStyle catalogViewShopButtonStyle() {
  return OutlinedButton.styleFrom(
    foregroundColor: AppColors.primary,
    side: const BorderSide(color: AppColors.primary),
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    minimumSize: const Size(0, 44),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
