import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  group('AppState', () {
    test('supports value equality', () {
      expect(const AppState(), equals(const AppState()));
    });

    test('props are correct', () {
      expect(
        const AppState().props,
        equals(<Object?>[
          const Locale('en', 'US'),
          ThemeMode.system,
          Colors.green,
          'GoogleSansFlex',
        ]),
      );
    });

    test('copyWith returns object with updated properties', () {
      expect(
        const AppState().copyWith(
          language: const Locale('es', 'ES'),
          theme: ThemeMode.dark,
          baseColor: Colors.blue,
          fontFamily: 'Roboto',
        ),
        equals(
          const AppState(
            language: Locale('es', 'ES'),
            theme: ThemeMode.dark,
            baseColor: Colors.blue,
            fontFamily: 'Roboto',
          ),
        ),
      );
    });

    test('copyWith returns original object when properties are null', () {
      expect(const AppState().copyWith(), equals(const AppState()));
    });
  });
}
