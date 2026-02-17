import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/cubit/app_cubit.dart';
import 'package:saver_expense_manager/app/services/local_storage_service.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late MockLocalStorageService mockLocalStorageService;

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
          when(() => mockLocalStorageService.getLanguage()).thenReturn('es_ES');
          when(() => mockLocalStorageService.getTheme()).thenReturn('DARK');
          when(() => mockLocalStorageService.getBaseColor()).thenReturn('RED');
          when(() => mockLocalStorageService.getFontFamily())
              .thenReturn('Roboto');
        },
        build: AppCubit.new,
        act: (cubit) => cubit.initialLoad(),
        expect: () => [
          const AppState(
            language: 'es_ES',
            theme: 'DARK',
            baseColor: 'RED',
            fontFamily: 'Roboto',
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
          when(() => mockLocalStorageService.saveLanguage(language: 'fr_FR'))
              .thenReturn(null);
        },
        build: AppCubit.new,
        act: (cubit) => cubit.changeLanguage(language: 'fr_FR'),
        expect: () => [const AppState(language: 'fr_FR')],
        verify: (_) {
          verify(() => mockLocalStorageService.saveLanguage(language: 'fr_FR'))
              .called(1);
        },
      );
    });

    group('changeTheme', () {
      blocTest<AppCubit, AppState>(
        'calls saveTheme and emits new state',
        setUp: () {
          when(() => mockLocalStorageService.saveTheme(theme: 'DARK'))
              .thenReturn(null);
        },
        build: AppCubit.new,
        act: (cubit) => cubit.changeTheme(theme: 'DARK'),
        expect: () => [const AppState(theme: 'DARK')],
        verify: (_) {
          verify(() => mockLocalStorageService.saveTheme(theme: 'DARK'))
              .called(1);
        },
      );
    });

    group('changeBaseColor', () {
      blocTest<AppCubit, AppState>(
        'calls saveBaseColor and emits new state',
        setUp: () {
          when(() => mockLocalStorageService.saveBaseColor(baseColor: 'GREEN'))
              .thenReturn(null);
        },
        build: AppCubit.new,
        act: (cubit) => cubit.changeBaseColor(baseColor: 'GREEN'),
        expect: () => [const AppState(baseColor: 'GREEN')],
        verify: (_) {
          verify(
            () => mockLocalStorageService.saveBaseColor(baseColor: 'GREEN'),
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
