import 'package:flutter/material.dart';
import 'package:frip_cash/theme/app_colors.dart';
import 'package:frip_cash/theme/app_shapes.dart';

abstract final class AppTypography {
  /// Body / UI font — must match `family` in pubspec.yaml.
  static const fontFamily = 'PlusJakartaSans';

  /// Large / display font (upright Cormorant Garamond only).
  static const displayFontFamily = 'CormorantGaramond';

  /// Default UI text (Plus Jakarta Sans).
  static TextStyle style({
    double? fontSize,
    FontWeight? fontWeight,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      height: height,
      letterSpacing: letterSpacing,
      decoration: decoration,
    );
  }

  /// Large titles / hero headlines (Cormorant upright).
  static TextStyle display({
    double fontSize = 32,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
    double? height,
    double? letterSpacing,
    TextDecoration? decoration,
  }) {
    return TextStyle(
      fontFamily: displayFontFamily,
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color ?? AppColors.textPrimary,
      height: height ?? 1.15,
      letterSpacing: letterSpacing ?? -0.4,
      decoration: decoration,
      fontStyle: FontStyle.normal,
    );
  }
}

abstract final class AppTheme {
  static ThemeData light() {
    const body = AppTypography.fontFamily;
    const display = AppTypography.displayFontFamily;

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        primary: AppColors.primary,
        onPrimary: Colors.white,
        secondary: AppColors.sage,
        error: AppColors.error,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: body,
    );

    TextTheme withFamilies(TextTheme theme) {
      return theme
          .apply(
            fontFamily: body,
            bodyColor: AppColors.textPrimary,
            displayColor: AppColors.textPrimary,
          )
          .copyWith(
            displayLarge: theme.displayLarge?.copyWith(fontFamily: display),
            displayMedium: theme.displayMedium?.copyWith(fontFamily: display),
            displaySmall: theme.displaySmall?.copyWith(fontFamily: display),
            headlineLarge: theme.headlineLarge?.copyWith(fontFamily: display),
            headlineMedium: theme.headlineMedium?.copyWith(fontFamily: display),
            headlineSmall: theme.headlineSmall?.copyWith(fontFamily: display),
          );
    }

    final textTheme = withFamilies(base.textTheme);
    final primaryTextTheme = withFamilies(base.primaryTextTheme);

    const buttonTextStyle = TextStyle(
      fontFamily: body,
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );

    return base.copyWith(
      textTheme: textTheme,
      primaryTextTheme: primaryTextTheme,
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: AppColors.background,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontFamily: body,
          fontWeight: FontWeight.w700,
          color: AppColors.textPrimary,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 52),
          textStyle: buttonTextStyle,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          minimumSize: const Size(64, 52),
          shape: AppShapes.pillShape,
          textStyle: buttonTextStyle,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary, width: 1.5),
          minimumSize: const Size(64, 52),
          shape: AppShapes.pillShape,
          textStyle: buttonTextStyle,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.textPrimary,
          textStyle: AppTypography.style(
            fontSize: 15,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        hintStyle: AppTypography.style(
          fontSize: 16,
          color: AppColors.textPrimary,
        ),
        labelStyle: AppTypography.style(
          fontSize: 15,
          fontWeight: FontWeight.w600,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        side: const BorderSide(color: AppColors.textPrimary, width: 1.5),
        checkColor: WidgetStateProperty.all(Colors.white),
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return AppColors.primary;
          }
          return Colors.white;
        }),
      ),
      bottomNavigationBarTheme: base.bottomNavigationBarTheme.copyWith(
        selectedLabelStyle: const TextStyle(fontFamily: body),
        unselectedLabelStyle: const TextStyle(
          fontFamily: body,
          color: AppColors.textPrimary,
        ),
      ),
      navigationBarTheme: base.navigationBarTheme.copyWith(
        labelTextStyle: WidgetStatePropertyAll(
          AppTypography.style(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ),
      tabBarTheme: base.tabBarTheme.copyWith(
        labelStyle: const TextStyle(fontFamily: body),
        unselectedLabelStyle: const TextStyle(
          fontFamily: body,
          color: AppColors.textPrimary,
        ),
      ),
      iconTheme: const IconThemeData(
        size: 24,
        color: AppColors.textPrimary,
      ),
    );
  }
}
