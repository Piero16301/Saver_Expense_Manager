// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const _seedColor = Colors.greenAccent;
  static ThemeData _lightBase() {
    return ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: _seedColor));
  }

  static ThemeData _darkBase() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: _seedColor,
        brightness: Brightness.dark,
      ),
    );
  }

  static final appLightTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.light,
    ),
    snackBarTheme: SnackBarThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      contentTextStyle: GoogleFonts.nunito().copyWith(
        color: _lightBase().colorScheme.onSurface,
      ),
      backgroundColor: _lightBase().colorScheme.surfaceContainer,
      closeIconColor: _lightBase().colorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: _seedColor.withValues(alpha: 0.3),
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.nunito().fontFamily,
  );

  static final appDarkTheme = ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: _seedColor,
      brightness: Brightness.dark,
    ),
    snackBarTheme: SnackBarThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      behavior: SnackBarBehavior.floating,
      showCloseIcon: true,
      contentTextStyle: GoogleFonts.nunito().copyWith(
        color: _darkBase().colorScheme.onSurface,
      ),
      backgroundColor: _darkBase().colorScheme.surfaceContainer,
      closeIconColor: _darkBase().colorScheme.onSurface,
    ),
    cardTheme: CardThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: _seedColor.withValues(alpha: 0.3),
      elevation: 0,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    useMaterial3: true,
    fontFamily: GoogleFonts.nunito().fontFamily,
  );
}
