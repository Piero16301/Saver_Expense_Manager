import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

class MockUser extends Mock implements AppUser {}

void main() {
  late AuthenticationService authenticationService;
  late LocalStorageService localStorageService;
  late MockAnalyticsService mockAnalyticsService;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(const Locale('en', 'US'));
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(Colors.green);
    AppVariables.useTestFonts = true;
  });

  setUp(() async {
    authenticationService = MockAuthenticationService();
    localStorageService = MockLocalStorageService();
    mockAnalyticsService = MockAnalyticsService();
    mockUser = MockUser();

    when(() => mockUser.uid).thenReturn('test_uid');

    when(() => mockAnalyticsService.getRouteObserver())
        .thenReturn(NavigatorObserver());

    when(() => mockAnalyticsService.setUserId(id: any(named: 'id')))
        .thenAnswer((_) {});

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthenticationService>()) {
      await getIt.unregister<AuthenticationService>();
    }
    if (getIt.isRegistered<LocalStorageService>()) {
      await getIt.unregister<LocalStorageService>();
    }
    if (getIt.isRegistered<AnalyticsService>()) {
      await getIt.unregister<AnalyticsService>();
    }

    getIt
      ..registerLazySingleton<AuthenticationService>(
        () => authenticationService,
      )
      ..registerLazySingleton<LocalStorageService>(() => localStorageService)
      ..registerLazySingleton<AnalyticsService>(() => mockAnalyticsService);

    when(() => authenticationService.userChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => authenticationService.authStateChanges)
        .thenAnswer((_) => const Stream.empty());
    when(() => authenticationService.isLoggedIn).thenReturn(false);
    when(() => authenticationService.currentUser).thenReturn(null);

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

  group('AppView', () {
    testWidgets('renders MaterialApp.router with correct theme and locale',
        (tester) async {
      final appCubit = MockAppCubit();
      const state = AppState(
        language: Locale('es', 'ES'),
        theme: ThemeMode.dark,
        baseColor: Colors.red,
        fontFamily: 'Roboto',
      );
      when(() => appCubit.state).thenReturn(state);
      whenListen(appCubit, Stream.fromIterable([state]));

      await tester.pumpWidget(
        BlocProvider<AppCubit>.value(
          value: appCubit,
          child: const AppView(),
        ),
      );

      final materialApp = tester.widget<MaterialApp>(find.byType(MaterialApp));
      expect(materialApp.locale, equals(state.language));
      expect(materialApp.themeMode, equals(state.theme));
    });
  });
}
