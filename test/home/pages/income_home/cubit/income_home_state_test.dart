import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/pages/income_home/cubit/income_home_cubit.dart';

void main() {
  group('IncomeHomeState', () {
    test('supports value equality', () {
      expect(const IncomeHomeState(), equals(const IncomeHomeState()));
    });

    test('props are correct', () {
      expect(
        const IncomeHomeState().props,
        equals(<Object?>[null, 0, const <CategoryData>[]]),
      );
    });

    test('copyWith returns object with updated properties', () {
      final date = DateTime(2023);
      const data = <CategoryData>[];
      expect(
        const IncomeHomeState().copyWith(
          monthSelected: date,
          selectedIndex: 1,
          data: data,
        ),
        equals(IncomeHomeState(monthSelected: date, selectedIndex: 1)),
      );
    });

    test('copyWith returns original object when properties are null', () {
      expect(
        const IncomeHomeState().copyWith(),
        equals(const IncomeHomeState()),
      );
    });
  });
}
