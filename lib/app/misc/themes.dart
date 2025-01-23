// ignore_for_file: avoid_redundant_argument_values

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const seedColor = Colors.green;

final appLightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.light,
  ),
  snackBarTheme: SnackBarThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    behavior: SnackBarBehavior.floating,
    showCloseIcon: true,
    contentTextStyle: GoogleFonts.nunito(),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    color: seedColor.withValues(alpha: 0.3),
    elevation: 0,
  ),
  useMaterial3: true,
  fontFamily: GoogleFonts.nunito().fontFamily,
);

final appDarkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: seedColor,
    brightness: Brightness.dark,
  ),
  snackBarTheme: SnackBarThemeData(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
    behavior: SnackBarBehavior.floating,
    showCloseIcon: true,
    contentTextStyle: GoogleFonts.nunito(),
  ),
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
    ),
    color: seedColor.withValues(alpha: 0.3),
    elevation: 0,
  ),
  useMaterial3: true,
  fontFamily: GoogleFonts.nunito().fontFamily,
);
