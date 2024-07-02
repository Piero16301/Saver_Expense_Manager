import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const backgroundLightColor = Color.fromRGBO(255, 251, 255, 1);
const primaryLightColor = Color.fromRGBO(234, 226, 205, 1);
const secondaryLightColor = Color.fromRGBO(247, 243, 242, 1);
const terciaryLightColor = Color.fromRGBO(122, 86, 73, 1);

const backgroundDarkColor = Color.fromRGBO(30, 27, 26, 1);
const primaryDarkColor = Color.fromRGBO(75, 71, 55, 1);
const secondaryDarkColor = Color.fromRGBO(43, 34, 32, 1);
const terciaryDarkColor = Color.fromRGBO(235, 188, 172, 1);

final appLightTheme = ThemeData.from(
  colorScheme: const ColorScheme.light(),
  textTheme: GoogleFonts.firaSansTextTheme(),
  useMaterial3: true,
).copyWith(
  primaryColor: primaryLightColor,
  textTheme: GoogleFonts.firaSansTextTheme().copyWith(
    bodyMedium: GoogleFonts.firaSans(
      fontWeight: FontWeight.w500,
      color: terciaryLightColor,
    ),
  ),
  scaffoldBackgroundColor: backgroundLightColor,
  inputDecorationTheme: const InputDecorationTheme(
    floatingLabelStyle: TextStyle(
      color: terciaryLightColor,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primaryLightColor),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: terciaryLightColor),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(terciaryLightColor),
      overlayColor: WidgetStateProperty.all(
        terciaryLightColor.withOpacity(0.1),
      ),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.firaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(terciaryLightColor),
      backgroundColor: WidgetStateProperty.all(primaryLightColor),
      overlayColor: WidgetStateProperty.all(
        primaryLightColor.withOpacity(0.1),
      ),
      side: WidgetStateProperty.all(const BorderSide(color: primaryLightColor)),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.firaSans(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(terciaryLightColor),
      overlayColor: WidgetStateProperty.all(
        terciaryLightColor.withOpacity(0.1),
      ),
    ),
  ),
);

final appDarkTheme = ThemeData.from(
  colorScheme: const ColorScheme.dark(),
  textTheme: GoogleFonts.firaSansTextTheme(),
  useMaterial3: true,
).copyWith(
  primaryColor: primaryDarkColor,
  textTheme: TextTheme(
    bodyMedium: GoogleFonts.firaSans(
      fontWeight: FontWeight.w500,
      color: terciaryDarkColor,
    ),
  ),
  scaffoldBackgroundColor: backgroundDarkColor,
  inputDecorationTheme: const InputDecorationTheme(
    floatingLabelStyle: TextStyle(
      color: terciaryDarkColor,
    ),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: primaryDarkColor),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: terciaryDarkColor),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(terciaryDarkColor),
      overlayColor: WidgetStateProperty.all(
        terciaryDarkColor.withOpacity(0.1),
      ),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.firaSans(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(terciaryDarkColor),
      backgroundColor: WidgetStateProperty.all(primaryDarkColor),
      overlayColor: WidgetStateProperty.all(
        primaryDarkColor.withOpacity(0.1),
      ),
      side: WidgetStateProperty.all(const BorderSide(color: primaryDarkColor)),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.firaSans(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
  iconButtonTheme: IconButtonThemeData(
    style: ButtonStyle(
      foregroundColor: WidgetStateProperty.all(terciaryDarkColor),
      overlayColor: WidgetStateProperty.all(
        terciaryDarkColor.withOpacity(0.1),
      ),
    ),
  ),
);
