import 'package:google_fonts/google_fonts.dart';

class AppVariables {
  static const String appName = 'Saver';

  static const String defaultBaseColor = 'INDIGO';
  static const String defaultFontFamily = 'Nunito_regular';

  static final minDate = DateTime(2020);
  static const deafultMonthsTrend = 5;
  static const maxDaysWarning = 7;

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

  static const categoriesCollection = 'categories';
  static const movementsCollection = 'movements';
  static const usersCollection = 'users';
}

enum MovementScreenType { add, edit }
