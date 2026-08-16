import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  late AppCubit appCubit;

  setUpAll(() {
    registerFallbackValue(ThemeMode.system);
  });

  setUp(() {
    appCubit = MockAppCubit();
  });

  group('AppChangeTheme', () {
    testWidgets('renders normally and changes theme', (tester) async {
      const state = AppState(theme: ThemeMode.light);
      when(() => appCubit.state).thenReturn(state);
      whenListen(appCubit, Stream.fromIterable([state]));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: BlocProvider<AppCubit>.value(
              value: appCubit,
              child: const AppChangeTheme(),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppChangeTheme));
      await tester.pumpAndSettle();

      await tester.tap(
        find.byWidgetPredicate(
          (widget) =>
              widget is PopupMenuItem<ThemeMode> &&
              widget.value == ThemeMode.dark,
        ),
      );
      await tester.pumpAndSettle();

      verify(() => appCubit.changeTheme(theme: ThemeMode.dark)).called(1);
    });
  });
}
