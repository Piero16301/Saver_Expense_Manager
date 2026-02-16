import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';

class AppThemes {
  static ThemeData lightTheme({
    required String baseColor,
    required String fontFamily,
  }) {
    final color = ColorHelper.getColorByName(baseColor);
    final colorScheme = ColorScheme.fromSeed(seedColor: color);
    final realFontFamily = AppVariables.getFontFamily(fontFamily);

    return ThemeData(
      textTheme: ThemeData.light().textTheme.apply(
            fontFamily: realFontFamily,
          ),
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: colorScheme.onSurface,
        ),
        backgroundColor: colorScheme.surfaceContainer,
        closeIconColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }

  static ThemeData darkTheme({
    required String baseColor,
    required String fontFamily,
  }) {
    final color = ColorHelper.getColorByName(baseColor);
    final colorScheme = ColorScheme.fromSeed(
      seedColor: color,
      brightness: Brightness.dark,
    );
    final realFontFamily = AppVariables.getFontFamily(fontFamily);

    return ThemeData(
      textTheme: ThemeData.dark().textTheme.apply(
            fontFamily: realFontFamily,
          ),
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: color,
        brightness: Brightness.dark,
      ),
      snackBarTheme: SnackBarThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
        showCloseIcon: true,
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          color: colorScheme.onSurface,
        ),
        backgroundColor: colorScheme.surfaceContainer,
        closeIconColor: colorScheme.onSurface,
      ),
      cardTheme: CardThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
      ),
    );
  }
}
