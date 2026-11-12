import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit;

void main() {
  group('MonthRangeSelector', () {
    late AppCubit appCubit;
    final startMonth = DateTime(2024);
    final endMonth = DateTime(2024, 3);

    setUp(() {
      appCubit = MockAppCubit();
      when(() => appCubit.state).thenReturn(const AppState());
    });

    testWidgets('renders normally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthRangeSelector(
                startMonth: startMonth,
                endMonth: endMonth,
                onChangeStartMonth: (d) {},
                onChangeEndMonth: (d) {},
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('Jan 2024'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.textContaining('Mar 2024'), findsOneWidget);
    });

    testWidgets('triggers onChangeStartMonth when tapping start month', (
      tester,
    ) async {
      DateTime? changedDate;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthRangeSelector(
                startMonth: startMonth,
                endMonth: endMonth,
                onChangeStartMonth: (d) => changedDate = d,
                onChangeEndMonth: (d) {},
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MonthRangeSelector));
      await tester.pumpAndSettle();

      expect(find.byType(MonthPickerDialog), findsOneWidget);

      await tester.tap(
        find
            .byWidgetPredicate(
              (w) =>
                  w is Text && (w.data?.toUpperCase().contains('FEB') ?? false),
            )
            .first,
      );
      await tester.pumpAndSettle();

      final okFinder = find
          .descendant(
            of: find.byType(MonthPickerDialog),
            matching: find.byType(TextButton),
          )
          .last;
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      expect(changedDate?.month, DateTime.february);
    });

    testWidgets('triggers onChangeEndMonth when tapping end month', (
      tester,
    ) async {
      DateTime? changedDate;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthRangeSelector(
                startMonth: startMonth,
                endMonth: endMonth,
                onChangeStartMonth: (d) {},
                onChangeEndMonth: (d) => changedDate = d,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MonthRangeSelector));
      await tester.pumpAndSettle();

      expect(find.byType(MonthPickerDialog), findsOneWidget);

      await tester.tap(
        find
            .byWidgetPredicate(
              (w) =>
                  w is Text && (w.data?.toUpperCase().contains('APR') ?? false),
            )
            .first,
      );
      await tester.pumpAndSettle();

      final okFinder = find
          .descendant(
            of: find.byType(MonthPickerDialog),
            matching: find.byType(TextButton),
          )
          .last;
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      expect(changedDate?.month, DateTime.april);
    });

    testWidgets('renders and selects years when isYear is true', (
      tester,
    ) async {
      DateTime? changedStartYear;
      DateTime? changedEndYear;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthRangeSelector(
                startMonth: DateTime(2023),
                endMonth: DateTime(2024, 12, 31),
                isYear: true,
                onChangeStartMonth: (d) => changedStartYear = d,
                onChangeEndMonth: (d) => changedEndYear = d,
              ),
            ),
          ),
        ),
      );

      expect(find.text('2023'), findsOneWidget);
      expect(find.text('-'), findsOneWidget);
      expect(find.text('2024'), findsOneWidget);

      await tester.tap(find.byType(MonthRangeSelector));
      await tester.pumpAndSettle();

      expect(find.byType(MonthPickerDialog), findsOneWidget);

      await tester.tap(find.text('2022').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('2025').first);
      await tester.pumpAndSettle();

      final okFinder = find
          .descendant(
            of: find.byType(MonthPickerDialog),
            matching: find.byType(TextButton),
          )
          .last;
      await tester.tap(okFinder);
      await tester.pumpAndSettle();

      expect(changedStartYear?.year, 2022);
      expect(changedEndYear?.year, 2025);
    });
  });
}
