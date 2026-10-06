import 'package:frip_cash/l10n/app_localizations.dart';

/// Localized labels for marketplace/home category ids.
String marketplaceCategoryLabel(String id, AppLocalizations t) => switch (id) {
      'mode' => t.categoryMode,
      'shoes' => t.categoryShoes,
      'beauty' => t.categoryBeauty,
      'baby' => t.categoryBaby,
      'grocery' => t.categoryGrocery,
      'home' => t.categoryHome,
      'electronics' => t.categoryElectronics,
      'secondhand' => t.categorySecondhand,
      _ => id,
    };

/// Home grid uses shorter labels for some categories.
String homeCategoryLabel(String id, AppLocalizations t) => switch (id) {
      'electronics' => t.categoryElectronicsShort,
      'beauty' => t.categoryBeautyShort,
      'grocery' => t.categoryGroceryShort,
      _ => marketplaceCategoryLabel(id, t),
    };
