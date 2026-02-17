import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  group('ThemeHelper', () {
    test('getThemeByName returns correct ThemeMode for valid names', () {
      expect(
        ThemeHelper.getThemeByName(AppVariables.lightTheme),
        ThemeMode.light,
      );
      expect(
        ThemeHelper.getThemeByName(AppVariables.darkTheme),
        ThemeMode.dark,
      );
    });

    test('getThemeByName returns default ThemeMode (light) for invalid names',
        () {
      expect(ThemeHelper.getThemeByName('UNKNOWN_THEME'), ThemeMode.light);
      expect(ThemeHelper.getThemeByName(''), ThemeMode.light);
      expect(ThemeHelper.getThemeByName('123'), ThemeMode.light);
    });

    test('getThemeByName is case-sensitive and returns default for lowercase',
        () {
      expect(ThemeHelper.getThemeByName('light'), ThemeMode.light);
      expect(ThemeHelper.getThemeByName('dark'), ThemeMode.light);
    });
  });
}
