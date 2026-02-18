import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppVariables {
  static const String appName = 'Saver';

  @visibleForTesting
  static bool useTestFonts = false;

  static const Color defaultBaseColor = Colors.green;
  static const String defaultFontFamily = 'Poppins';
  static const List<String> allowedExtensions = ['pdf', 'png', 'jpg', 'jpeg'];

  static final minDate = DateTime(2020);
  static const deafultMonthsTrend = 10;
  static const deafultMonthsResume = 4;
  static const maxDaysWarning = 7;

  static const String expensesTab = 'gastos';
  static const String movementsTab = 'movimientos';
  static const String summaryTab = 'resumen';
  static const String incomesTab = 'ingresos';

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

  static Map<String, String> availableFonts = getAvailableFonts();

  @visibleForTesting
  static Map<String, String> getAvailableFonts() {
    if (useTestFonts) {
      return {
        'Nunito': 'Nunito',
        'Roboto': 'Roboto',
      };
    }
    return {
      'Merriweather': GoogleFonts.merriweather().fontFamily ?? 'Merriweather',
      'Montserrat': GoogleFonts.montserrat().fontFamily ?? 'Montserrat',
      'Nunito': GoogleFonts.nunito().fontFamily ?? 'Nunito',
      'Open Sans': GoogleFonts.openSans().fontFamily ?? 'Open Sans',
      'Orbitron': GoogleFonts.orbitron().fontFamily ?? 'Orbitron',
      'Pacifico': GoogleFonts.pacifico().fontFamily ?? 'Pacifico',
      'Playfair Display':
          GoogleFonts.playfairDisplay().fontFamily ?? 'Playfair Display',
      'Poppins': GoogleFonts.poppins().fontFamily ?? 'Poppins',
      'Roboto': GoogleFonts.roboto().fontFamily ?? 'Roboto',
      'Source Code Pro':
          GoogleFonts.sourceCodePro().fontFamily ?? 'Source Code Pro',
    };
  }

  static const categoriesCollection = 'categories';
  static const movementsCollection = 'movements';
  static const usersCollection = 'users';

  static const List<Locale> supportedLocales = [
    Locale('en', 'US'),
    Locale('es', 'ES'),
    Locale('it', 'IT'),
  ];
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

enum ModelType {
  cloud,
  local;

  bool get isCloud => this == ModelType.cloud;
  bool get isLocal => this == ModelType.local;

  String get name {
    switch (this) {
      case ModelType.cloud:
        return 'CLOUD';
      case ModelType.local:
        return 'LOCAL';
    }
  }

  static ModelType fromName(String name) {
    switch (name) {
      case 'CLOUD':
        return ModelType.cloud;
      case 'LOCAL':
        return ModelType.local;
      default:
        return ModelType.cloud;
    }
  }
}
