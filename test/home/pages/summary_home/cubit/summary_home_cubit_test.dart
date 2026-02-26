import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/pages/summary_home/cubit/summary_home_cubit.dart';

void main() {
  group('SummaryHomeCubit', () {
    late SummaryHomeCubit summaryHomeCubit;

    setUp(() {
      summaryHomeCubit = SummaryHomeCubit();
    });

    test('initial state is correct', () {
      expect(summaryHomeCubit.state.endMonth, isNotNull);
      expect(summaryHomeCubit.state.startMonth, isNotNull);
      expect(summaryHomeCubit.state.selResumeItems, const {
        ResumeItemType.income: true,
        ResumeItemType.balance: true,
        ResumeItemType.expense: true,
      });
    });

    blocTest<SummaryHomeCubit, SummaryHomeState>(
      'changeStartMonth emits correct state',
      build: () => summaryHomeCubit,
      act: (cubit) => cubit.changeStartMonth(DateTime(2023)),
      expect: () => [
        isA<SummaryHomeState>()
            .having((s) => s.startMonth, 'startMonth', DateTime(2023)),
      ],
    );

    blocTest<SummaryHomeCubit, SummaryHomeState>(
      'changeEndMonth emits correct state',
      build: () => summaryHomeCubit,
      act: (cubit) => cubit.changeEndMonth(DateTime(2023, 12)),
      expect: () => [
        isA<SummaryHomeState>()
            .having((s) => s.endMonth, 'endMonth', DateTime(2023, 12)),
      ],
    );

    blocTest<SummaryHomeCubit, SummaryHomeState>(
      'toggleResumeItem toggles boolean correctly',
      build: () => summaryHomeCubit,
      act: (cubit) {
        cubit
          ..toggleResumeItem(ResumeItemType.income)
          ..toggleResumeItem(ResumeItemType.income);
      },
      expect: () => [
        isA<SummaryHomeState>().having(
          (s) => s.selResumeItems[ResumeItemType.income],
          'income value',
          false,
        ),
        isA<SummaryHomeState>().having(
          (s) => s.selResumeItems[ResumeItemType.income],
          'income value',
          true,
        ),
      ],
    );
  });
}
