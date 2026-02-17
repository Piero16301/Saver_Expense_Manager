import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/category.dart';
import 'package:saver_expense_manager/app/models/category_expense_data.dart';

void main() {
  group('CategoryExpenseData', () {
    const category = Category(
      id: '1',
      name: 'Shopping',
      icon: 'shopping_bag',
      color: 'blue',
      type: CategoryType.expense,
    );
    const categoryExpenseData = CategoryExpenseData(
      category: category,
      totalExpense: 200,
    );

    test('supports value comparisons', () {
      expect(
        const CategoryExpenseData(category: category, totalExpense: 200),
        const CategoryExpenseData(category: category, totalExpense: 200),
      );
    });

    test('props are correct', () {
      expect(
        categoryExpenseData.props,
        equals([category, 200.0]),
      );
    });

    group('fromJson', () {
      test('returns correct object from valid json', () {
        final json = {
          'category': category.toJson(),
          'totalExpense': 200.0,
        };
        expect(CategoryExpenseData.fromJson(json), categoryExpenseData);
      });

      test('returns default object when json is empty', () {
        final instance = CategoryExpenseData.fromJson(const {});
        expect(instance.totalExpense, 0.0);
        expect(instance.category, isA<Category>());
        expect(instance.category.id, '');
        expect(instance.category.name, '');
      });

      test('handles null value correctly', () {
        final json = {
          'category': category.toJson(),
          'totalExpense': null,
        };
        final instance = CategoryExpenseData.fromJson(json);
        expect(instance.totalExpense, 0.0);
        expect(instance.category, category);
      });

      test('handles int value correctly for totalExpense', () {
        final json = {
          'category': category.toJson(),
          'totalExpense': 200,
        };
        final instance = CategoryExpenseData.fromJson(json);
        expect(instance.totalExpense, 200.0);
      });
    });

    group('toJson', () {
      test('returns correct map', () {
        expect(
          categoryExpenseData.toJson(),
          {
            'category': category.toJson(),
            'totalExpense': 200.0,
          },
        );
      });
    });
  });
}
