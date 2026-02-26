import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppVariables.useTestFonts = true;

  group('AppState', () {
    test('supports value equality', () {
      expect(const AppState(), equals(const AppState()));
    });

    test('copyWith returns correct instance', () {
      const state = AppState();
      const language = Locale('es', 'ES');
      const theme = ThemeMode.dark;
      const baseColor = Colors.red;
      const fontFamily = 'Roboto';

      expect(
        state.copyWith(
          language: language,
          theme: theme,
          baseColor: baseColor,
          fontFamily: fontFamily,
        ),
        equals(
          const AppState(
            language: language,
            theme: theme,
            baseColor: baseColor,
            fontFamily: fontFamily,
          ),
        ),
      );
    });

    test('copyWith uses original values if none provided', () {
      const state = AppState();
      expect(state.copyWith(), equals(state));
    });
  });

  group('AppCubit', () {
    late MockLocalStorageService localStorage;

    setUp(() {
      localStorage = MockLocalStorageService();
      TestWidgetsFlutterBinding.ensureInitialized();
      getIt.registerSingleton<LocalStorageService>(localStorage);
    });

    tearDown(getIt.reset);

    test('initial state is correct', () {
      expect(AppCubit().state, equals(const AppState()));
    });

    group('initialLoad', () {
      blocTest<AppCubit, AppState>(
        'emits correct state and saves defaults when local storage is empty',
        build: () {
          when(() => localStorage.getLanguage()).thenReturn(null);
          when(() => localStorage.getTheme()).thenReturn(null);
          when(() => localStorage.getBaseColor()).thenReturn(null);
          when(() => localStorage.getFontFamily()).thenReturn(null);

          when(
            () => localStorage.saveLanguage(
              language: AppVariables.supportedLocales.first,
            ),
          ).thenAnswer((_) async {});
          when(() => localStorage.saveTheme(theme: ThemeMode.system))
              .thenAnswer((_) async {});
          when(
            () => localStorage.saveBaseColor(
              baseColor: AppVariables.defaultBaseColor,
            ),
          ).thenAnswer((_) async {});
          when(
            () => localStorage.saveFontFamily(
              fontFamily: AppVariables.defaultFontFamily,
            ),
          ).thenAnswer((_) async {});

          return AppCubit();
        },
        act: (cubit) => cubit.initialLoad(),
        expect: () => [const AppState()],
        verify: (_) {
          verify(
            () => localStorage.saveLanguage(
              language: AppVariables.supportedLocales.first,
            ),
          ).called(1);
          verify(() => localStorage.saveTheme(theme: ThemeMode.system))
              .called(1);
          verify(
            () => localStorage.saveBaseColor(
              baseColor: AppVariables.defaultBaseColor,
            ),
          ).called(1);
          verify(
            () => localStorage.saveFontFamily(
              fontFamily: AppVariables.defaultFontFamily,
            ),
          ).called(1);
        },
      );

      blocTest<AppCubit, AppState>(
        'emits correct state using stored values',
        build: () {
          const language = Locale('es', 'ES');
          const theme = ThemeMode.dark;
          const baseColor = Colors.red;
          const fontFamily = 'Open Sans';

          when(() => localStorage.getLanguage()).thenReturn(language);
          when(() => localStorage.getTheme()).thenReturn(theme);
          when(() => localStorage.getBaseColor()).thenReturn(baseColor);
          when(() => localStorage.getFontFamily()).thenReturn(fontFamily);

          return AppCubit();
        },
        act: (cubit) => cubit.initialLoad(),
        expect: () => [
          const AppState(
            language: Locale('es', 'ES'),
            theme: ThemeMode.dark,
            baseColor: Colors.red,
            fontFamily: 'Open Sans',
          ),
        ],
      );
    });

    group('changeLanguage', () {
      blocTest<AppCubit, AppState>(
        'emits correct state and calls localStorage',
        build: () {
          when(
            () => localStorage.saveLanguage(language: const Locale('es', 'ES')),
          ).thenAnswer((_) async {});
          return AppCubit();
        },
        act: (cubit) =>
            cubit.changeLanguage(language: const Locale('es', 'ES')),
        expect: () => [
          const AppState(language: Locale('es', 'ES')),
        ],
        verify: (_) {
          verify(
            () => localStorage.saveLanguage(language: const Locale('es', 'ES')),
          ).called(1);
        },
      );
    });

    group('changeTheme', () {
      blocTest<AppCubit, AppState>(
        'emits correct state and calls localStorage',
        build: () {
          when(() => localStorage.saveTheme(theme: ThemeMode.dark))
              .thenAnswer((_) async {});
          return AppCubit();
        },
        act: (cubit) => cubit.changeTheme(theme: ThemeMode.dark),
        expect: () => [
          const AppState(theme: ThemeMode.dark),
        ],
        verify: (_) {
          verify(() => localStorage.saveTheme(theme: ThemeMode.dark)).called(1);
        },
      );
    });

    group('changeBaseColor', () {
      blocTest<AppCubit, AppState>(
        'emits correct state and calls localStorage',
        build: () {
          when(() => localStorage.saveBaseColor(baseColor: Colors.red))
              .thenAnswer((_) async {});
          return AppCubit();
        },
        act: (cubit) => cubit.changeBaseColor(baseColor: Colors.red),
        expect: () => [
          const AppState(baseColor: Colors.red),
        ],
        verify: (_) {
          verify(() => localStorage.saveBaseColor(baseColor: Colors.red))
              .called(1);
        },
      );
    });

    group('changeFontFamily', () {
      blocTest<AppCubit, AppState>(
        'emits correct state and calls localStorage',
        build: () {
          when(() => localStorage.saveFontFamily(fontFamily: 'Merriweather'))
              .thenAnswer((_) async {});
          return AppCubit();
        },
        act: (cubit) => cubit.changeFontFamily(fontFamily: 'Merriweather'),
        expect: () => [
          const AppState(fontFamily: 'Merriweather'),
        ],
        verify: (_) {
          verify(() => localStorage.saveFontFamily(fontFamily: 'Merriweather'))
              .called(1);
        },
      );
    });
  });
}
