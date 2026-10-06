import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frip_cash/l10n/app_localizations.dart';
import 'package:frip_cash/screens/splash_screen.dart';
import 'package:frip_cash/services/app_locale_service.dart';
import 'package:frip_cash/theme/app_typography.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

void main() {
  MaterialSymbolsBase.forceCompileTimeTreeShaking();
  MaterialSymbolsBase.setRoundedVariationDefaults(
    weight: 500,
    opticalSize: 24,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    AppLocaleService.instance.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    AppLocaleService.instance.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      debugShowCheckedModeBanner: false,
      locale: AppLocaleService.instance.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('fr'),
      ],
      theme: AppTheme.light(),
      builder: (context, child) {
        return DefaultTextStyle(
          style: AppTypography.style(),
          child: child ?? const SizedBox.shrink(),
        );
      },
      home: const SplashScreen(),
    );
  }
}
