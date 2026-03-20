import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
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
      when(() => appCubit.close()).thenAnswer((_) async {});
    });

    Future<void> pumpSettingsView(WidgetTester tester) async {
      await tester.pumpWidget(
        BlocProvider.value(
          value: appCubit,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsView(),
          ),
        ),
      );
    }

    testWidgets('renders Setting cards', (tester) async {
      await pumpSettingsView(tester);

      expect(find.byType(LocaleSettingsCard), findsOneWidget);
      expect(find.byType(ThemeSettingsCard), findsOneWidget);
      expect(find.byType(ColorSettingsCard), findsOneWidget);
      expect(find.byType(FontSettingsCard), findsOneWidget);
      expect(find.byType(SettingsAppSpecs), findsOneWidget);
    });

    testWidgets('changes language when LocaleSettingsCard is interacted',
        (tester) async {
      await pumpSettingsView(tester);

      final localeDropdown = find.byType(DropdownButton<Locale>);
      await tester.dragUntilVisible(
        localeDropdown,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(localeDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Spanish').last);
      await tester.pumpAndSettle();

      verify(() => appCubit.changeLanguage(language: const Locale('es', 'ES')))
          .called(1);
    });

    testWidgets('changes theme when ThemeSettingsCard is interacted',
        (tester) async {
      await pumpSettingsView(tester);

      final themeDropdown = find.byType(DropdownButton<ThemeMode>);
      await tester.dragUntilVisible(
        themeDropdown,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(themeDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dark').last);
      await tester.pumpAndSettle();

      verify(() => appCubit.changeTheme(theme: ThemeMode.dark)).called(1);
    });

    testWidgets('changes color when ColorSettingsCard is interacted',
        (tester) async {
      when(() => appCubit.state).thenReturn(const AppState());
      await pumpSettingsView(tester);

      final colorDropdown = find.byType(DropdownButton<Color>);
      await tester.dragUntilVisible(
        colorDropdown,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(colorDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Teal').last);
      await tester.pumpAndSettle();

      verify(() => appCubit.changeBaseColor(baseColor: Colors.teal)).called(1);
    });

    testWidgets('changes font when FontSettingsCard is interacted',
        (tester) async {
      when(() => appCubit.state).thenReturn(const AppState());
      await pumpSettingsView(tester);

      final fontDropdown = find.byType(DropdownButton<String>);
      await tester.dragUntilVisible(
        fontDropdown,
        find.byType(ListView),
        const Offset(0, -200),
      );
      await tester.tap(fontDropdown);
      await tester.pumpAndSettle();

      await tester.tap(find.text('Merriweather').last);
      await tester.pumpAndSettle();

      verify(() => appCubit.changeFontFamily(fontFamily: 'Merriweather'))
          .called(1);
    });
  });
}
