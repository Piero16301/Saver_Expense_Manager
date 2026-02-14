import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppVariables {
  static const String appName = 'Saver';

  static const String defaultBaseColor = 'INDIGO';
  static const String defaultFontFamily = 'Nunito_regular';
  static const List<String> allowedExtensions = ['pdf', 'png', 'jpg', 'jpeg'];

  static final minDate = DateTime(2020);
  static const deafultMonthsTrend = 10;
  static const deafultMonthsResume = 4;
  static const maxDaysWarning = 7;

  static const String expensesTab = 'gastos';
  static const String movementsTab = 'movimientos';
  static const String summaryTab = 'resumen';
  static const String incomesTab = 'ingresos';

  static const String lightTheme = 'LIGHT';
  static const String darkTheme = 'DARK';

  static const String googleProvider = 'google.com';
  static const String emailProvider = 'password';

  static const String emailRegExp =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
  static const String passwordRegExp = r'^(?=.*[a-z])(?=.*[A-Z]).{6,}$';

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

enum SnackBarType {
  success,
  error,
  warning,
  info;

  bool get isSuccess => this == SnackBarType.success;
  bool get isError => this == SnackBarType.error;
  bool get isWarning => this == SnackBarType.warning;
  bool get isInfo => this == SnackBarType.info;
}

enum MovementScreenType { add, edit }

enum ImageResolutionType { low, medium, high }

enum ResumeItemType {
  income,
  expense,
  balance,
}
