import 'package:frip_cash/l10n/app_localizations.dart';

String enseigneCategoryLabel(String id, AppLocalizations t) {
  return switch (id) {
    'grocery' => t.enseigneCategoryGrocery,
    'appliances' => t.enseigneCategoryAppliances,
    'lighting' => t.enseigneCategoryLighting,
    'home' => t.enseigneCategoryHome,
    'mode' => t.enseigneCategoryMode,
    _ => id,
  };
}
