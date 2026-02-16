import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/cubit/app_cubit.dart';

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
          'en_US',
          'LIGHT',
          'INDIGO',
          'Nunito_regular',
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
          language: 'es_ES',
          theme: 'DARK',
          baseColor: 'RED',
          fontFamily: 'Roboto',
        );

        expect(
          result,
          equals(
            const AppState(
              language: 'es_ES',
              theme: 'DARK',
              baseColor: 'RED',
              fontFamily: 'Roboto',
            ),
          ),
        );
      });

      test('applies updates individually correctly', () {
        const state = AppState();

        expect(
          state.copyWith(language: 'es_ES'),
          equals(const AppState(language: 'es_ES')),
        );
        expect(
          state.copyWith(theme: 'DARK'),
          equals(const AppState(theme: 'DARK')),
        );
        expect(
          state.copyWith(baseColor: 'BLUE'),
          equals(const AppState(baseColor: 'BLUE')),
        );
        expect(
          state.copyWith(fontFamily: 'Roboto'),
          equals(const AppState(fontFamily: 'Roboto')),
        );
      });
    });
  });
}
