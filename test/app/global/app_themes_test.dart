import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/global/app_themes.dart';

void main() {
  group('AppThemes', () {
    test('lightTheme returns correct ThemeData', () {
      final theme = AppThemes.lightTheme(
        baseColor: Colors.blue,
        fontFamily: 'Roboto',
      );

      expect(theme.brightness, equals(Brightness.light));
      expect(
        theme.colorScheme.primary.toARGB32(),
        equals(ColorScheme.fromSeed(seedColor: Colors.blue).primary.toARGB32()),
      );
      expect(theme.textTheme.bodyMedium?.fontFamily, equals('Roboto'));
    });

    test('darkTheme returns correct ThemeData', () {
      final theme = AppThemes.darkTheme(
        baseColor: Colors.red,
        fontFamily: 'Open Sans',
      );

      expect(theme.brightness, equals(Brightness.dark));
      expect(
        theme.colorScheme.primary.toARGB32(),
        equals(
          ColorScheme.fromSeed(
            seedColor: Colors.red,
            brightness: Brightness.dark,
          ).primary.toARGB32(),
        ),
      );
      expect(theme.textTheme.bodyMedium?.fontFamily, equals('Open Sans'));
    });
  });
}
