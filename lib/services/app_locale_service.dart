import 'package:flutter/material.dart';

class AppLocaleService extends ChangeNotifier {
  AppLocaleService._();

  static final AppLocaleService instance = AppLocaleService._();

  Locale? _locale;

  Locale? get locale => _locale;

  void setLocale(Locale locale) {
    if (_locale == locale) return;
    _locale = locale;
    notifyListeners();
  }
}
