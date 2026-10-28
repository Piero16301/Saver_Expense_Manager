import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/settings/settings.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class FakeAppLocalizations extends Fake implements AppLocalizations {}

void main() {
  group('SettingsView', () {
    late AppCubit appCubit;

    setUpAll(() {
      registerFallbackValue(FakeAppLocalizations());
      AppVariables.useTestFonts = true;
      PackageInfo.setMockInitialValues(
        appName: 'Saver',
        packageName: 'com.saver',
        version: '1.0.0',
        buildNumber: '1',
        buildSignature: 'buildSignature',
      );
    });

    setUp(() {
      appCubit = MockAppCubit();
      when(() => appCubit.state).thenReturn(const AppState());
      when(() => appCubit.stream).thenAnswer((_) => const Stream.empty());
      when(appCubit.close).thenAnswer((_) async {});
    });

    Future<void> pumpSettingsView(
      WidgetTester tester, {
      GoRouter? router,
    }) async {
      final testRouter =
          router ??
          GoRouter(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const SettingsView(),
              ),
            ],
          );

      await tester.pumpWidget(
        BlocProvider.value(
          value: appCubit,
          child: MaterialApp.router(
            localizationsDelegates: const [
              ...AppLocalizations.localizationsDelegates,
              ExpressiveLocalizations.delegate,
            ],
            supportedLocales: ExpressiveLanguages.supportedLocales,
            routerConfig: testRouter,
          ),
        ),
      );
    }

    testWidgets('renders Setting sections and tiles', (tester) async {
      await pumpSettingsView(tester);

      expect(find.byType(ExpressiveTopAppBar), findsOneWidget);
      expect(find.byType(ExpressiveCardGroup), findsNWidgets(2));
      expect(find.byType(ExpressiveListTile), findsNWidgets(4));
      expect(find.byType(SettingsAppSpecs), findsOneWidget);

      expect(find.text('Appearance'), findsOneWidget);
      expect(find.text('Theme'), findsOneWidget);
      expect(find.text('Base color'), findsOneWidget);
      expect(find.text('Font'), findsOneWidget);
      expect(find.text('Language'), findsNWidgets(2));
    });

    testWidgets('changes language when Language tile is tapped', (
      tester,
    ) async {
      await pumpSettingsView(tester);

      final languageTile = find.widgetWithText(ExpressiveListTile, 'Language');
      await tester.dragUntilVisible(
        languageTile,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(languageTile);
      await tester.pumpAndSettle();

      expect(find.text('Select language'), findsOneWidget);

      await tester.tap(find.widgetWithText(ListTile, 'Spanish'));
      await tester.pumpAndSettle();

      verify(
        () => appCubit.changeLanguage(language: const Locale('es', 'ES')),
      ).called(1);
    });

    testWidgets('changes theme when Theme tile is tapped', (tester) async {
      await pumpSettingsView(tester);

      final themeTile = find.widgetWithText(ExpressiveListTile, 'Theme');
      await tester.dragUntilVisible(
        themeTile,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(themeTile);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Dark'));
      await tester.pumpAndSettle();

      verify(() => appCubit.changeTheme(theme: ThemeMode.dark)).called(1);
    });

    testWidgets('changes color when Color tile is tapped', (tester) async {
      when(() => appCubit.state).thenReturn(const AppState());
      await pumpSettingsView(tester);

      final colorTile = find.widgetWithText(ExpressiveListTile, 'Base color');
      await tester.dragUntilVisible(
        colorTile,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(colorTile);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Red'));
      await tester.pumpAndSettle();

      verify(() => appCubit.changeBaseColor(baseColor: Colors.red)).called(1);
    });

    testWidgets('changes font when Font tile is tapped', (tester) async {
      when(() => appCubit.state).thenReturn(const AppState());
      await pumpSettingsView(tester);

      final fontTile = find.widgetWithText(ExpressiveListTile, 'Font');
      await tester.dragUntilVisible(
        fontTile,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(fontTile);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(ListTile, 'Merriweather'));
      await tester.pumpAndSettle();

      verify(
        () =>
            appCubit.changeFontFamily(fontFamily: ExpressiveFonts.merriweather),
      ).called(1);
    });

    testWidgets('pops navigation when back button is tapped', (tester) async {
      final router = GoRouter(
        initialLocation: '/settings',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) =>
                const Scaffold(body: Text('Home Page')),
            routes: [
              GoRoute(
                path: 'settings',
                builder: (context, state) => const SettingsView(),
              ),
            ],
          ),
        ],
      );

      await pumpSettingsView(tester, router: router);

      final backButton = find.byType(ExpressiveIconButton);
      expect(backButton, findsOneWidget);

      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('Home Page'), findsOneWidget);
    });
  });
}
