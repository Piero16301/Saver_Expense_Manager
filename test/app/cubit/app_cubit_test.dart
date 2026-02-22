import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLocalStorageService mockLocalStorageService;

  setUpAll(() {
    registerFallbackValue(const Locale('en', 'US'));
    registerFallbackValue(Colors.red);
    registerFallbackValue(ThemeMode.light);
    registerFallbackValue(ModelType.cloud);
  });

  setUp(() {
    mockLocalStorageService = MockLocalStorageService();
    GetIt.I.registerSingleton<LocalStorageService>(mockLocalStorageService);
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('AppCubit', () {
    test('initial state is AppState()', () {
      expect(AppCubit().state, const AppState());
    });

    group('initialLoad', () {
      blocTest<AppCubit, AppState>(
        'emits state with values from LocalStorage when they exist',
        setUp: () {
          when(() => mockLocalStorageService.getLanguage()).thenReturn(
            const Locale('es', 'ES'),
          );
          when(() => mockLocalStorageService.getTheme()).thenReturn(
            ThemeMode.dark,
          );
          when(() => mockLocalStorageService.getBaseColor()).thenReturn(
            Colors.red,
          );
          when(() => mockLocalStorageService.getFontFamily())
              .thenReturn('Poppins');
        },
        build: AppCubit.new,
        act: (cubit) => cubit.initialLoad(),
        expect: () => [
          const AppState(
            language: Locale('es', 'ES'),
            theme: ThemeMode.dark,
            baseColor: Colors.red,
          ),
        ],
      );

      blocTest<AppCubit, AppState>(
        'saves and emits default values when LocalStorage is empty',
        setUp: () {
          when(() => mockLocalStorageService.getLanguage()).thenReturn(null);
          when(
            () => mockLocalStorageService.saveLanguage(
              language: any(named: 'language'),
            ),
          ).thenReturn(null);

          when(() => mockLocalStorageService.getTheme()).thenReturn(null);
          when(
            () => mockLocalStorageService.saveTheme(theme: any(named: 'theme')),
          ).thenReturn(null);

          when(() => mockLocalStorageService.getBaseColor()).thenReturn(null);
          when(
            () => mockLocalStorageService.saveBaseColor(
              baseColor: any(named: 'baseColor'),
            ),
          ).thenReturn(null);

          when(() => mockLocalStorageService.getFontFamily()).thenReturn(null);
          when(
            () => mockLocalStorageService.saveFontFamily(
              fontFamily: any(named: 'fontFamily'),
            ),
          ).thenReturn(null);
        },
        build: AppCubit.new,
        act: (cubit) => cubit.initialLoad(),
        verify: (_) {
          verify(
            () => mockLocalStorageService.saveLanguage(
              language: any(named: 'language'),
            ),
          ).called(1);
          verify(
            () => mockLocalStorageService.saveTheme(theme: any(named: 'theme')),
          ).called(1);
          verify(
            () => mockLocalStorageService.saveBaseColor(
              baseColor: any(named: 'baseColor'),
            ),
          ).called(1);
          verify(
            () => mockLocalStorageService.saveFontFamily(
              fontFamily: any(named: 'fontFamily'),
            ),
          ).called(1);
        },
      );
    });

    group('changeLanguage', () {
      blocTest<AppCubit, AppState>(
        'calls saveLanguage and emits new state',
        setUp: () {
          when(
            () => mockLocalStorageService.saveLanguage(
              language: const Locale('fr', 'FR'),
            ),
          ).thenReturn(null);
        },
        build: AppCubit.new,
        act: (cubit) =>
            cubit.changeLanguage(language: const Locale('fr', 'FR')),
        expect: () => [const AppState(language: Locale('fr', 'FR'))],
        verify: (_) {
          verify(
            () => mockLocalStorageService.saveLanguage(
              language: const Locale('fr', 'FR'),
            ),
          ).called(1);
        },
      );
    });

    group('changeTheme', () {
      blocTest<AppCubit, AppState>(
        'calls saveTheme and emits new state',
        setUp: () {
          when(() => mockLocalStorageService.saveTheme(theme: ThemeMode.dark))
              .thenReturn(null);
        },
        build: AppCubit.new,
        act: (cubit) => cubit.changeTheme(theme: ThemeMode.dark),
        expect: () => [const AppState(theme: ThemeMode.dark)],
        verify: (_) {
          verify(() => mockLocalStorageService.saveTheme(theme: ThemeMode.dark))
              .called(1);
        },
      );
    });

    group('changeBaseColor', () {
      blocTest<AppCubit, AppState>(
        'calls saveBaseColor and emits new state',
        setUp: () {
          when(
            () => mockLocalStorageService.saveBaseColor(
              baseColor: Colors.green,
            ),
          ).thenReturn(null);
        },
        build: AppCubit.new,
        act: (cubit) => cubit.changeBaseColor(baseColor: Colors.green),
        expect: () => [const AppState()],
        verify: (_) {
          verify(
            () =>
                mockLocalStorageService.saveBaseColor(baseColor: Colors.green),
          ).called(1);
        },
      );
    });

    group('changeFontFamily', () {
      blocTest<AppCubit, AppState>(
        'calls saveFontFamily and emits new state',
        setUp: () {
          when(
            () => mockLocalStorageService.saveFontFamily(
              fontFamily: 'Open Sans',
            ),
          ).thenReturn(null);
        },
        build: AppCubit.new,
        act: (cubit) => cubit.changeFontFamily(fontFamily: 'Open Sans'),
        expect: () => [const AppState(fontFamily: 'Open Sans')],
        verify: (_) {
          verify(
            () => mockLocalStorageService.saveFontFamily(
              fontFamily: 'Open Sans',
            ),
          ).called(1);
        },
      );
    });
  });
}
