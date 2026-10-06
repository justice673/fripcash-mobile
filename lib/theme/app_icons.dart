import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Material Symbols (rounded) with [Icons] fallback where needed.
abstract final class AppIcons {
  // Navigation
  static final home = Symbols.home_rounded;
  static final browse = Symbols.grid_view_rounded;
  static final add = Symbols.add_rounded;
  static final inbox = Symbols.chat_bubble_rounded;
  static final profile = Symbols.person_rounded;

  // Home header / search
  static final notifications = Symbols.notifications_rounded;
  static final favorite = Symbols.favorite_rounded;
  static final cart = Symbols.shopping_bag_rounded;
  static final search = Symbols.search_rounded;
  static final close = Symbols.close_rounded;
  static final camera = Symbols.photo_camera_rounded;
  static final filter = Symbols.tune_rounded;

  // Common actions — Material Symbols
  static final chevronLeft = Symbols.chevron_left_rounded;
  static final chevronRight = Symbols.chevron_right_rounded;
  static final share = Symbols.share_rounded;
  static final more = Symbols.more_horiz_rounded;
  static final edit = Symbols.edit_rounded;
  static final delete = Symbols.delete_rounded;
  static final check = Symbols.check_rounded;
  static final schedule = Symbols.schedule_rounded;
  static final warning = Symbols.warning_rounded;
  static final shield = Symbols.shield_rounded;
  static final category = Symbols.category_rounded;

  // Fallbacks — Flutter built-in Material Icons
  static const materialAdd = Icons.add_rounded;
  static const materialSearch = Icons.search_rounded;
  static const materialHome = Icons.home_rounded;
}

/// Renders a Material Symbol with optional fill/weight, or a plain Material Icon.
class AppIcon extends StatelessWidget {
  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
    this.filled = false,
    this.weight = 500,
    this.opticalSize,
    this.semanticLabel,
    this.useMaterialIcons = false,
  });

  final IconData icon;
  final double? size;
  final Color? color;
  final bool filled;
  final double weight;
  final double? opticalSize;
  final String? semanticLabel;
  final bool useMaterialIcons;

  @override
  Widget build(BuildContext context) {
    final resolvedSize = size ?? IconTheme.of(context).size ?? 24;

    if (useMaterialIcons) {
      return Icon(
        icon,
        size: resolvedSize,
        color: color,
        semanticLabel: semanticLabel,
      );
    }

    return VariedIcon.varied(
      icon,
      size: resolvedSize,
      color: color,
      fill: filled ? 1 : 0,
      weight: weight,
      opticalSize: opticalSize ?? resolvedSize,
      semanticLabel: semanticLabel,
    );
  }
}
