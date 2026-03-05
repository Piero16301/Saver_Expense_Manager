import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

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

      expect(find.textContaining('JAN 2024'), findsOneWidget);
      expect(find.textContaining('MAR 2024'), findsOneWidget);
    });

    testWidgets('triggers onChangeStartMonth when tapping start month',
        (tester) async {
      DateTime? changedDate;
      await tester.pumpWidget(
        MaterialApp(
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

      await tester.tap(find.textContaining('JAN 2024'));
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

    testWidgets('triggers onChangeEndMonth when tapping end month',
        (tester) async {
      DateTime? changedDate;
      await tester.pumpWidget(
        MaterialApp(
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

      await tester.tap(find.textContaining('MAR 2024'));
      await tester.pumpAndSettle();

      expect(find.text('OK'), findsOneWidget);

      await tester.tap(
        find
            .byWidgetPredicate(
              (w) =>
                  w is Text && (w.data?.toUpperCase().contains('APR') ?? false),
            )
            .first,
      );
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(changedDate?.month, DateTime.april);
    });
  });
}
