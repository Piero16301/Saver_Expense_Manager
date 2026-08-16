import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAuthService extends Mock implements AuthService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late AuthService authenticationService;
  late LocalStorageService localStorageService;
  late MockAnalyticsService mockAnalyticsService;

  setUpAll(() {
    registerFallbackValue(const Locale('en', 'US'));
    registerFallbackValue(ThemeMode.system);
    registerFallbackValue(Colors.green);
    AppVariables.useTestFonts = true;
  });

  setUp(() async {
    authenticationService = MockAuthService();
    localStorageService = MockLocalStorageService();
    mockAnalyticsService = MockAnalyticsService();

    when(
      () => mockAnalyticsService.setUserId(id: any(named: 'id')),
    ).thenAnswer((_) {});

    final getIt = GetIt.instance;
    if (getIt.isRegistered<AuthService>()) {
      await getIt.unregister<AuthService>();
    }
    if (getIt.isRegistered<LocalStorageService>()) {
      await getIt.unregister<LocalStorageService>();
    }
    if (getIt.isRegistered<AnalyticsService>()) {
      await getIt.unregister<AnalyticsService>();
    }

    getIt
      ..registerLazySingleton<AuthService>(() => authenticationService)
      ..registerLazySingleton<LocalStorageService>(() => localStorageService)
      ..registerLazySingleton<AnalyticsService>(() => mockAnalyticsService);

    when(
      () => authenticationService.userChanges,
    ).thenAnswer((_) => const Stream.empty());
    when(
      () => authenticationService.authStateChanges,
    ).thenAnswer((_) => const Stream.empty());
    when(() => authenticationService.isLoggedIn).thenReturn(false);
    when(() => authenticationService.currentUser).thenReturn(null);

    when(
      () => localStorageService.getLanguage(),
    ).thenReturn(const Locale('en', 'US'));
    when(() => localStorageService.getTheme()).thenReturn(ThemeMode.system);
    when(() => localStorageService.getBaseColor()).thenReturn(Colors.green);
    when(() => localStorageService.getFontFamily()).thenReturn('Poppins');

    when(
      () => localStorageService.saveLanguage(language: any(named: 'language')),
    ).thenAnswer((_) async {});
    when(
      () => localStorageService.saveTheme(theme: any(named: 'theme')),
    ).thenAnswer((_) async {});
    when(
      () =>
          localStorageService.saveBaseColor(baseColor: any(named: 'baseColor')),
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
