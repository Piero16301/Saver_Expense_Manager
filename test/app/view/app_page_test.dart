import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

void main() {
  late AuthenticationService authenticationService;
  late LocalStorageService localStorageService;

  setUpAll(() {
    registerFallbackValue(const Locale('en', 'US'));
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(Colors.green);
    AppVariables.useTestFonts = true;
  });

  setUp(() async {
    authenticationService = MockAuthenticationService();
    localStorageService = MockLocalStorageService();

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthenticationService>()) {
      await getIt.unregister<AuthenticationService>();
    }
    if (getIt.isRegistered<LocalStorageService>()) {
      await getIt.unregister<LocalStorageService>();
    }

    getIt
      ..registerLazySingleton<AuthenticationService>(
        () => authenticationService,
      )
      ..registerLazySingleton<LocalStorageService>(() => localStorageService);

    when(() => authenticationService.userChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => authenticationService.isLoggedIn).thenReturn(false);

    when(() => localStorageService.getLanguage())
        .thenReturn(const Locale('en', 'US'));
    when(() => localStorageService.getTheme()).thenReturn(ThemeMode.system);
    when(() => localStorageService.getBaseColor()).thenReturn(Colors.green);
    when(() => localStorageService.getFontFamily()).thenReturn('Poppins');

    when(
      () => localStorageService.saveLanguage(language: any(named: 'language')),
    ).thenAnswer((_) async {});
    when(() => localStorageService.saveTheme(theme: any(named: 'theme')))
        .thenAnswer((_) async {});
    when(
      () => localStorageService.saveBaseColor(
        baseColor: any(named: 'baseColor'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => localStorageService.saveFontFamily(
        fontFamily: any(named: 'fontFamily'),
      ),
    ).thenAnswer((_) async {});
  });

  group('AppPage', () {
    testWidgets('renders AppView and provides AppCubit', (tester) async {
      await tester.pumpWidget(const AppPage());
      expect(find.byType(AppView), findsOneWidget);
      expect(find.byType(BlocProvider<AppCubit>), findsOneWidget);

      verify(() => localStorageService.getLanguage()).called(2);
    });
  });
}
