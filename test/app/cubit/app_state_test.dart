import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  group('AppState', () {
    test('supports value equality', () {
      expect(
        const AppState(),
        equals(const AppState()),
      );
    });

    test('props are correct', () {
      expect(
        const AppState().props,
        equals([
          const Locale('en', 'US'),
          ThemeMode.system,
          Colors.green,
          'Poppins',
        ]),
      );
    });

    group('copyWith', () {
      test('returns the same object if no arguments are provided', () {
        expect(
          const AppState().copyWith(),
          equals(const AppState()),
        );
      });

      test('retains the old value for every parameter if null is provided', () {
        expect(
          const AppState().copyWith(),
          equals(const AppState()),
        );
      });

      test('replaces every non-null parameter', () {
        const state = AppState();
        final result = state.copyWith(
          language: const Locale('es', 'ES'),
          theme: ThemeMode.dark,
          baseColor: Colors.red,
          fontFamily: 'Poppins',
        );

        expect(
          result,
          equals(
            const AppState(
              language: Locale('es', 'ES'),
              theme: ThemeMode.dark,
              baseColor: Colors.red,
            ),
          ),
        );
      });

      test('applies updates individually correctly', () {
        const state = AppState();

        expect(
          state.copyWith(language: const Locale('es', 'ES')),
          equals(const AppState(language: Locale('es', 'ES'))),
        );
        expect(
          state.copyWith(theme: ThemeMode.dark),
          equals(const AppState(theme: ThemeMode.dark)),
        );
        expect(
          state.copyWith(baseColor: Colors.blue),
          equals(const AppState(baseColor: Colors.blue)),
        );
        expect(
          state.copyWith(fontFamily: 'Poppins'),
          equals(const AppState()),
        );
      });
    });
  });
}
