import 'package:flutter/material.dart';
import 'package:material_symbols_icons/symbols.dart';

/// Sub-categories for partner stores (enseignes) — what they sell.
class EnseigneCategory {
  const EnseigneCategory({
    required this.id,
    required this.icon,
  });

  final String id;
  final IconData icon;
}

/// First entry in filter chips is always `all` (handled in UI).
const enseigneCategoryIds = <String>[
  'all',
  'grocery',
  'appliances',
  'lighting',
  'home',
  'mode',
];

const enseigneCategories = <EnseigneCategory>[
  EnseigneCategory(id: 'grocery', icon: Symbols.ramen_dining_rounded),
  EnseigneCategory(id: 'appliances', icon: Symbols.electrical_services_rounded),
  EnseigneCategory(id: 'lighting', icon: Symbols.lightbulb_rounded),
  EnseigneCategory(id: 'home', icon: Symbols.nest_wifi_router_rounded),
  EnseigneCategory(id: 'mode', icon: Symbols.apparel_rounded),
];

EnseigneCategory? enseigneCategoryById(String id) {
  for (final category in enseigneCategories) {
    if (category.id == id) return category;
  }
  return null;
}
