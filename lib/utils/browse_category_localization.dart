import 'package:frip_cash/l10n/app_localizations.dart';

String browseCategoryLabel(String id, AppLocalizations t) => switch (id) {
      'women' => t.browseCategoryWomen,
      'men' => t.browseCategoryMen,
      'premium' => t.browseCategoryPremium,
      'kids' => t.browseCategoryKids,
      'home' => t.browseCategoryHome,
      'tech' => t.browseCategoryTech,
      'books' => t.browseCategoryBooks,
      'hobbies' => t.browseCategoryHobbies,
      'sports' => t.browseCategorySports,
      _ => id,
    };
