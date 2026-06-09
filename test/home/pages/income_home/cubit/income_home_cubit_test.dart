import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/home/pages/income_home/cubit/income_home_cubit.dart';

void main() {
  group('IncomeHomeCubit', () {
    late IncomeHomeCubit incomeHomeCubit;

    setUp(() {
      incomeHomeCubit = IncomeHomeCubit();
    });

    test('initial state is correct', () {
      expect(incomeHomeCubit.state, const IncomeHomeState());
    });

    blocTest<IncomeHomeCubit, IncomeHomeState>(
      'emits correct state on init',
      build: () => incomeHomeCubit,
      act: (cubit) => cubit.init(),
      expect: () => [
        isA<IncomeHomeState>().having(
          (s) => s.monthSelected,
          'monthSelected',
          isNotNull,
        ),
      ],
    );

    blocTest<IncomeHomeCubit, IncomeHomeState>(
      'changeMonth emits correct state',
      build: () => incomeHomeCubit,
      seed: () => const IncomeHomeState(selectedIndex: 2),
      act: (cubit) => cubit.changeMonth(DateTime(2023, 5)),
      expect: () => [IncomeHomeState(monthSelected: DateTime(2023, 5))],
    );

    blocTest<IncomeHomeCubit, IncomeHomeState>(
      'changeMonth does nothing if null',
      build: () => incomeHomeCubit,
      act: (cubit) => cubit.changeMonth(null),
      expect: () => const <IncomeHomeState>[],
    );

    blocTest<IncomeHomeCubit, IncomeHomeState>(
      'changeExplodeIndex emits correct state',
      build: () => incomeHomeCubit,
      act: (cubit) => cubit.changeExplodeIndex(5),
      expect: () => [const IncomeHomeState(selectedIndex: 5)],
    );

    blocTest<IncomeHomeCubit, IncomeHomeState>(
      'nextMonth emits correct state (not December)',
      build: () => incomeHomeCubit,
      seed: () => IncomeHomeState(monthSelected: DateTime(2023, 5)),
      act: (cubit) => cubit.nextMonth(),
      expect: () => [IncomeHomeState(monthSelected: DateTime(2023, 6))],
    );

    blocTest<IncomeHomeCubit, IncomeHomeState>(
      'nextMonth emits correct state (December)',
      build: () => incomeHomeCubit,
      seed: () => IncomeHomeState(monthSelected: DateTime(2023, 12)),
      act: (cubit) => cubit.nextMonth(),
      expect: () => [IncomeHomeState(monthSelected: DateTime(2024))],
    );

    blocTest<IncomeHomeCubit, IncomeHomeState>(
      'previousMonth emits correct state (not January)',
      build: () => incomeHomeCubit,
      seed: () => IncomeHomeState(monthSelected: DateTime(2023, 5)),
      act: (cubit) => cubit.previousMonth(),
      expect: () => [IncomeHomeState(monthSelected: DateTime(2023, 4))],
    );

    blocTest<IncomeHomeCubit, IncomeHomeState>(
      'previousMonth emits correct state (January)',
      build: () => incomeHomeCubit,
      seed: () => IncomeHomeState(monthSelected: DateTime(2023)),
      act: (cubit) => cubit.previousMonth(),
      expect: () => [IncomeHomeState(monthSelected: DateTime(2022, 12))],
    );
  });
}
