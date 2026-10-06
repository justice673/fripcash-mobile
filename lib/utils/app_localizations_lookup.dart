import 'dart:ui';

import 'package:frip_cash/l10n/app_localizations.dart';

AppLocalizations currentAppLocalizations() {
  final locale = PlatformDispatcher.instance.locale;
  final code = locale.languageCode;
  final supported = AppLocalizations.supportedLocales
      .any((supportedLocale) => supportedLocale.languageCode == code);
  return lookupAppLocalizations(supported ? Locale(code) : const Locale('en'));
}
