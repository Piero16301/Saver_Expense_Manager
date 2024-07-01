import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

final appLightTheme = ThemeData.from(
  colorScheme: const ColorScheme.light(),
  textTheme: GoogleFonts.firaSansTextTheme(),
  useMaterial3: true,
).copyWith(
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.white,
    iconTheme: IconThemeData(color: Colors.black),
    actionsIconTheme: IconThemeData(color: Colors.black),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.blue),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      overlayColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.1)),
      side: WidgetStateProperty.all(const BorderSide(color: Colors.blue)),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.firaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
);

final appDarkTheme = ThemeData.from(
  colorScheme: const ColorScheme.dark(),
  textTheme: GoogleFonts.firaSansTextTheme(),
  useMaterial3: true,
).copyWith(
  primaryColor: Colors.blue,
  scaffoldBackgroundColor: Colors.black,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.black,
    iconTheme: IconThemeData(color: Colors.white),
    actionsIconTheme: IconThemeData(color: Colors.white),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    selectedItemColor: Colors.blue,
    unselectedItemColor: Colors.grey,
  ),
  inputDecorationTheme: const InputDecorationTheme(
    border: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.grey),
      borderRadius: BorderRadius.all(Radius.circular(10)),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: WidgetStateProperty.all(Colors.blue),
      foregroundColor: WidgetStateProperty.all(Colors.white),
      overlayColor: WidgetStateProperty.all(Colors.blue.withOpacity(0.1)),
      side: WidgetStateProperty.all(const BorderSide(color: Colors.blue)),
      shape: WidgetStateProperty.all(
        const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(10)),
        ),
      ),
      textStyle: WidgetStateProperty.all(
        GoogleFonts.firaSans(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
    ),
  ),
);
