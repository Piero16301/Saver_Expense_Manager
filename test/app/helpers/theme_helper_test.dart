import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/helpers/theme_helper.dart';

void main() {
  group('ThemeHelper', () {
    test('getThemeName returns correct string for ThemeMode', () {
      expect(ThemeHelper.getThemeName(ThemeMode.light), equals('LIGHT'));
      expect(ThemeHelper.getThemeName(ThemeMode.dark), equals('DARK'));
      expect(ThemeHelper.getThemeName(ThemeMode.system), equals('SYSTEM'));
    });

    test('getThemeByName returns correct ThemeMode for valid string', () {
      expect(ThemeHelper.getThemeByName('LIGHT'), equals(ThemeMode.light));
      expect(ThemeHelper.getThemeByName('light'), equals(ThemeMode.light));
      expect(ThemeHelper.getThemeByName('DARK'), equals(ThemeMode.dark));
      expect(ThemeHelper.getThemeByName('SYSTEM'), equals(ThemeMode.system));
    });

    test('getThemeByName returns ThemeMode.light for invalid string', () {
      expect(ThemeHelper.getThemeByName('INVALID'), equals(ThemeMode.light));
    });
  });
}
