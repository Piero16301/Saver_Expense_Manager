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
  group('SettingsPage', () {
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

    testWidgets('renders SettingsView', (tester) async {
      final appCubit = MockAppCubit();
      when(() => appCubit.state).thenReturn(const AppState());
      when(() => appCubit.stream).thenAnswer((_) => const Stream.empty());
      when(appCubit.close).thenAnswer((_) async {});

      await tester.pumpWidget(
        BlocProvider<AppCubit>.value(
          value: appCubit,
          child: const MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: SettingsPage(),
          ),
        ),
      );

      expect(find.byType(SettingsView), findsOneWidget);
    });
  });
}
