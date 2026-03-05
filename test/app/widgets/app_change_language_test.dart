import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  late AppCubit appCubit;

  setUpAll(() {
    registerFallbackValue(const Locale('en', 'US'));
  });

  setUp(() {
    appCubit = MockAppCubit();
  });

  group('AppChangeLanguage', () {
    testWidgets('renders normally and changes language', (tester) async {
      const state = AppState();
      when(() => appCubit.state).thenReturn(state);
      whenListen(appCubit, Stream.fromIterable([state]));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<AppCubit>.value(
              value: appCubit,
              child: const AppChangeLanguage(),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppChangeLanguage));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is PopupMenuItem<Locale> &&
              widget.value == const Locale('es', 'ES'),
        ),
      );
      await tester.pumpAndSettle();

      verify(() => appCubit.changeLanguage(language: const Locale('es', 'ES')))
          .called(1);
    });
  });
}
