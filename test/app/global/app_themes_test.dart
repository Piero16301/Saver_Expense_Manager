import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    AppVariables.useTestFonts = true;
  });

  group('AppThemes', () {
    group('lightTheme', () {
      test('returns a ThemeData with light brightness', () {
        final theme = AppThemes.lightTheme(
          baseColor: 'INDIGO',
          fontFamily: 'Nunito',
        );

        expect(theme.brightness, Brightness.light);
      });

      test('applies color scheme from base color', () {
        final themeRed = AppThemes.lightTheme(
          baseColor: 'RED',
          fontFamily: 'Nunito',
        );
        final themeIndigo = AppThemes.lightTheme(
          baseColor: 'INDIGO',
          fontFamily: 'Nunito',
        );

        expect(
          themeRed.colorScheme.primary,
          isNot(equals(themeIndigo.colorScheme.primary)),
        );
      });

      test('applies font family', () {
        final theme = AppThemes.lightTheme(
          baseColor: 'INDIGO',
          fontFamily: 'Nunito',
        );

        expect(theme.textTheme.bodyMedium?.fontFamily, isNotNull);
      });

      test('sets snackBarTheme correctly', () {
        final theme = AppThemes.lightTheme(
          baseColor: 'INDIGO',
          fontFamily: 'Nunito',
        );

        expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
        expect(theme.snackBarTheme.showCloseIcon, isTrue);
      });
    });

    group('darkTheme', () {
      test('returns a ThemeData with dark brightness', () {
        final theme = AppThemes.darkTheme(
          baseColor: 'INDIGO',
          fontFamily: 'Nunito',
        );

        expect(theme.brightness, Brightness.dark);
      });

      test('applies color scheme from base color', () {
        final themeRed = AppThemes.darkTheme(
          baseColor: 'RED',
          fontFamily: 'Nunito',
        );
        final themeIndigo = AppThemes.darkTheme(
          baseColor: 'INDIGO',
          fontFamily: 'Nunito',
        );

        expect(
          themeRed.colorScheme.primary,
          isNot(equals(themeIndigo.colorScheme.primary)),
        );
      });

      test('applies font family', () {
        final theme = AppThemes.darkTheme(
          baseColor: 'INDIGO',
          fontFamily: 'Roboto',
        );

        expect(theme.textTheme.bodyMedium?.fontFamily, isNotNull);
      });
    });
  });
}
