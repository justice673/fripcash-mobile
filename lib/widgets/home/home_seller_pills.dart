import 'package:flutter/material.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/models/home_filters.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Pill filters under the home search bar: Tout / Particuliers / Boutiques / Quartier.
class HomeSellerPills extends StatelessWidget {
  const HomeSellerPills({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  final HomeSellerPill selected;
  final ValueChanged<HomeSellerPill> onChanged;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final items = <(HomeSellerPill, String, IconData?)>[
      (HomeSellerPill.all, t.all, null),
      (
        HomeSellerPill.particuliers,
        t.homeSellerPillIndividuals,
        Symbols.checkroom_rounded,
      ),
      (
        HomeSellerPill.boutiques,
        t.homeSellerPillShops,
        Symbols.storefront_rounded,
      ),
      (
        HomeSellerPill.quartier,
        t.neighborhood,
        Symbols.home_work_rounded,
      ),
      (
        HomeSellerPill.enseignes,
        t.homeSellerPillEnseignes,
        Symbols.storefront_rounded,
      ),
    ];

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final (pill, label, icon) = items[index];
          final isSelected = selected == pill;
          return _SellerPill(
            label: label,
            icon: icon,
            selected: isSelected,
            onTap: () => onChanged(pill),
          );
        },
      ),
    );
  }
}

class _SellerPill extends StatelessWidget {
  const _SellerPill({
    required this.label,
    required this.selected,
    required this.onTap,
    this.icon,
  });

  final String label;
  final IconData? icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Colors.white : AppColors.textPrimary;
    return Material(
      color: selected ? AppColors.primary : Colors.white,
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
              color: selected ? AppColors.primary : const Color(0xFFE0E0E0),
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
