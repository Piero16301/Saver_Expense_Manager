import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  group('MonthSelector', () {
    late AppCubit appCubit;
    final monthSelected = DateTime(2024, 3, 5);
    var backCalled = false;
    var forwardCalled = false;

    setUp(() {
      appCubit = MockAppCubit();
      when(() => appCubit.state).thenReturn(const AppState());
      backCalled = false;
      forwardCalled = false;
    });

    testWidgets('renders normally and formats date based on locale',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthSelector(
                monthSelected: monthSelected,
                onBack: () {},
                onForward: () {},
                onChangeMonth: (d) {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('MARCH 2024'), findsOneWidget);

      when(() => appCubit.state)
          .thenReturn(const AppState(language: Locale('es')));
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('es'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthSelector(
                monthSelected: monthSelected,
                onBack: () {},
                onForward: () {},
                onChangeMonth: (d) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('MARZO 2024'), findsOneWidget);
    });

    testWidgets('disables back button at min date', (tester) async {
      final minDate = AppVariables.minDate;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthSelector(
                monthSelected: minDate,
                onBack: () => backCalled = true,
                onForward: () {},
                onChangeMonth: (d) {},
              ),
            ),
          ),
        ),
      );

      final backButton = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (w) => w is IconButton && w.onPressed == null,
        ),
      );
      expect(backButton, isNotNull);

      await tester.tap(find.byType(IconButton).first, warnIfMissed: false);
      expect(backCalled, isFalse);
    });

    testWidgets('disables forward button at current month', (tester) async {
      final now = DateTime.now();
      final currentMonth = DateTime(now.year, now.month);

      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthSelector(
                monthSelected: currentMonth,
                onBack: () {},
                onForward: () => forwardCalled = true,
                onChangeMonth: (d) {},
              ),
            ),
          ),
        ),
      );

      final forwardButton = tester.widget<IconButton>(
        find.byWidgetPredicate(
          (w) => w is IconButton && w.onPressed == null,
        ),
      );
      expect(forwardButton, isNotNull);

      await tester.tap(find.byType(IconButton).last, warnIfMissed: false);
      expect(forwardCalled, isFalse);
    });

    testWidgets('calls onBack and onForward when enabled', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthSelector(
                monthSelected: monthSelected,
                onBack: () => backCalled = true,
                onForward: () => forwardCalled = true,
                onChangeMonth: (d) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton).first);
      expect(backCalled, isTrue);

      await tester.tap(find.byType(IconButton).last);
      expect(forwardCalled, isTrue);
    });

    testWidgets('opens month picker and triggers onChangeMonth',
        (tester) async {
      DateTime? changedDate;
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthSelector(
                monthSelected: monthSelected,
                onBack: () {},
                onForward: () {},
                onChangeMonth: (d) => changedDate = d,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('MARCH 2024'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);

      await tester.tap(
        find
            .byWidgetPredicate(
              (w) =>
                  w is Text && (w.data?.toUpperCase().contains('FEB') ?? false),
            )
            .first,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(changedDate?.month, DateTime.february);
    });

    testWidgets('handles January for backEnabled', (tester) async {
      final january = DateTime(2024, 1, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthSelector(
                monthSelected: january,
                onBack: () => backCalled = true,
                onForward: () {},
                onChangeMonth: (d) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton).first);
      expect(backCalled, isTrue);
    });

    testWidgets('handles December for forwardEnabled', (tester) async {
      final december = DateTime(2023, 12, 15);
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthSelector(
                monthSelected: december,
                onBack: () {},
                onForward: () => forwardCalled = true,
                onChangeMonth: (d) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton).last);
      expect(forwardCalled, isTrue);
    });
  });
}
