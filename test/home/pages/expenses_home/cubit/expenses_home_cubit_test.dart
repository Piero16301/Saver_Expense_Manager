import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/home/pages/expenses_home/cubit/expenses_home_cubit.dart';

void main() {
  group('ExpensesHomeCubit', () {
    late ExpensesHomeCubit expensesHomeCubit;

    setUp(() {
      expensesHomeCubit = ExpensesHomeCubit();
    });

    test('initial state is correct', () {
      expect(expensesHomeCubit.state, const ExpensesHomeState());
    });

    blocTest<ExpensesHomeCubit, ExpensesHomeState>(
      'emits correct state on init',
      build: () => expensesHomeCubit,
      act: (cubit) => cubit.init(),
      expect: () => [
        isA<ExpensesHomeState>().having(
          (s) => s.monthSelected,
          'monthSelected',
          isNotNull,
        ),
      ],
    );

    blocTest<ExpensesHomeCubit, ExpensesHomeState>(
      'changeMonth emits correct state',
      build: () => expensesHomeCubit,
      seed: () => const ExpensesHomeState(selectedIndex: 2),
      act: (cubit) => cubit.changeMonth(DateTime(2023, 5)),
      expect: () => [ExpensesHomeState(monthSelected: DateTime(2023, 5))],
    );

    blocTest<ExpensesHomeCubit, ExpensesHomeState>(
      'changeMonth does nothing if null',
      build: () => expensesHomeCubit,
      act: (cubit) => cubit.changeMonth(null),
      expect: () => const <ExpensesHomeState>[],
    );

    blocTest<ExpensesHomeCubit, ExpensesHomeState>(
      'changeExplodeIndex emits correct state',
      build: () => expensesHomeCubit,
      act: (cubit) => cubit.changeExplodeIndex(5),
      expect: () => [const ExpensesHomeState(selectedIndex: 5)],
    );

    blocTest<ExpensesHomeCubit, ExpensesHomeState>(
      'nextMonth emits correct state (not December)',
      build: () => expensesHomeCubit,
      seed: () => ExpensesHomeState(monthSelected: DateTime(2023, 5)),
      act: (cubit) => cubit.nextMonth(),
      expect: () => [ExpensesHomeState(monthSelected: DateTime(2023, 6))],
    );

    blocTest<ExpensesHomeCubit, ExpensesHomeState>(
      'nextMonth emits correct state (December)',
      build: () => expensesHomeCubit,
      seed: () => ExpensesHomeState(monthSelected: DateTime(2023, 12)),
      act: (cubit) => cubit.nextMonth(),
      expect: () => [ExpensesHomeState(monthSelected: DateTime(2024))],
    );

    blocTest<ExpensesHomeCubit, ExpensesHomeState>(
      'previousMonth emits correct state (not January)',
      build: () => expensesHomeCubit,
      seed: () => ExpensesHomeState(monthSelected: DateTime(2023, 5)),
      act: (cubit) => cubit.previousMonth(),
      expect: () => [ExpensesHomeState(monthSelected: DateTime(2023, 4))],
    );

    blocTest<ExpensesHomeCubit, ExpensesHomeState>(
      'previousMonth emits correct state (January)',
      build: () => expensesHomeCubit,
      seed: () => ExpensesHomeState(monthSelected: DateTime(2023)),
      act: (cubit) => cubit.previousMonth(),
      expect: () => [ExpensesHomeState(monthSelected: DateTime(2022, 12))],
    );
  });
}
