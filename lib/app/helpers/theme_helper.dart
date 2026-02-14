import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';

class ThemeHelper {
  static const Map<String, ThemeMode> themeMap = <String, ThemeMode>{
    AppVariables.lightTheme: ThemeMode.light,
    AppVariables.darkTheme: ThemeMode.dark,
  };

  static ThemeMode getThemeByName(String themeName) {
    return themeMap[themeName] ?? ThemeMode.light;
  }
}
