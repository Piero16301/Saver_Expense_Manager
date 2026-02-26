import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/models.dart';

void main() {
  group('CategoryExpenseData', () {
    const category = Category.empty;
    const totalExpense = 150.0;

    test('supports value equality', () {
      expect(
        const CategoryExpenseData(
          category: category,
          totalExpense: totalExpense,
        ),
        equals(
          const CategoryExpenseData(
            category: category,
            totalExpense: totalExpense,
          ),
        ),
      );
    });

    group('fromJson', () {
      test('returns correct instance from fully populated map', () {
        final json = <String, dynamic>{
          'category': category.toJson(),
          'totalExpense': totalExpense,
        };

        expect(
          CategoryExpenseData.fromJson(json),
          equals(
            const CategoryExpenseData(
              category: category,
              totalExpense: totalExpense,
            ),
          ),
        );
      });

      test('returns correct instance with defaults from empty map', () {
        expect(
          CategoryExpenseData.fromJson(const {}),
          equals(
            CategoryExpenseData(
              category: Category.fromJson(const {}),
              totalExpense: 0,
            ),
          ),
        );
      });
    });

    group('toJson', () {
      test('returns correct map', () {
        const data =
            CategoryExpenseData(category: category, totalExpense: totalExpense);
        expect(
          data.toJson(),
          equals({
            'category': category.toJson(),
            'totalExpense': totalExpense,
          }),
        );
      });
    });
  });
}
