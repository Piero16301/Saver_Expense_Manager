import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppVariables {
  static const String appName = 'Saver';

  static const String defaultBaseColor = 'INDIGO';
  static const String defaultFontFamily = 'Nunito_regular';

  static final minDate = DateTime(2020);
  static const deafultMonthsTrend = 10;
  static const deafultMonthsResume = 4;
  static const maxDaysWarning = 7;

  static const MaterialAccentColor incomeColor = Colors.blueAccent;
  static const MaterialColor balanceColor = Colors.teal;
  static const MaterialAccentColor expenseColor = Colors.orangeAccent;

  static const MaterialColor growthColor = Colors.green;
  static const MaterialAccentColor decreaseColor = Colors.redAccent;

  static Map<String, String> availableFonts = {
    'Merriweather': GoogleFonts.merriweather().fontFamily ?? '',
    'Montserrat': GoogleFonts.montserrat().fontFamily ?? '',
    'Nunito': GoogleFonts.nunito().fontFamily ?? '',
    'Open Sans': GoogleFonts.openSans().fontFamily ?? '',
    'Orbitron': GoogleFonts.orbitron().fontFamily ?? '',
    'Pacifico': GoogleFonts.pacifico().fontFamily ?? '',
    'Playfair Display': GoogleFonts.playfairDisplay().fontFamily ?? '',
    'Poppins': GoogleFonts.poppins().fontFamily ?? '',
    'Roboto': GoogleFonts.roboto().fontFamily ?? '',
    'Source Code Pro': GoogleFonts.sourceCodePro().fontFamily ?? '',
  };

  static String getFontFamily(String savedFontId) {
    if (availableFonts.values.contains(savedFontId)) {
      return savedFontId;
    }

    final cleanedName = savedFontId
        .replaceAll('_regular', '')
        .replaceAll('_bold', '')
        .replaceAll('_italic', '');

    final fontFamily = availableFonts[cleanedName];
    if (fontFamily != null && fontFamily.isNotEmpty) {
      return fontFamily;
    }

    return availableFonts['Nunito'] ?? 'Nunito';
  }

  static const categoriesCollection = 'categories';
  static const movementsCollection = 'movements';
  static const usersCollection = 'users';
}

enum MovementScreenType { add, edit }

enum ImageResolutionType { low, medium, high }

enum MovementsShowType {
  list,
  chart;

  bool get isList => this == MovementsShowType.list;
  bool get isChart => this == MovementsShowType.chart;

  static MovementsShowType fromString(String value) {
    return MovementsShowType.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MovementsShowType.list,
    );
  }
}

enum ResumeItemType {
  income,
  expense,
  balance,
}
