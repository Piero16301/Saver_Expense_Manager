import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/pages/expenses_home/cubit/expenses_home_cubit.dart';

void main() {
  group('ExpensesHomeState', () {
    test('supports value equality', () {
      expect(
        const ExpensesHomeState(),
        equals(const ExpensesHomeState()),
      );
    });

    test('props are correct', () {
      expect(
        const ExpensesHomeState().props,
        equals(<Object?>[
          null,
          0,
          const <CategoryData>[],
        ]),
      );
    });

    test('copyWith returns object with updated properties', () {
      final date = DateTime(2023);
      const data = <CategoryData>[];
      expect(
        const ExpensesHomeState().copyWith(
          monthSelected: date,
          selectedIndex: 1,
          data: data,
        ),
        equals(
          ExpensesHomeState(
            monthSelected: date,
            selectedIndex: 1,
          ),
        ),
      );
    });

    test('copyWith returns original object when properties are null', () {
      expect(
        const ExpensesHomeState().copyWith(),
        equals(const ExpensesHomeState()),
      );
    });
  });
}
