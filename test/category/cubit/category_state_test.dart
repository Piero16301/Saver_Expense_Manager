import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/category/category.dart';

void main() {
  group('CategoryState', () {
    test('supports value equality', () {
      expect(const CategoryState(), equals(const CategoryState()));
    });

    test('props are correct', () {
      expect(const CategoryState().props, equals(<Object?>[Category.empty]));
    });

    test('copyWith returns object with updated properties', () {
      const category = Category(
        id: '1',
        name: 'Food',
        icon: 'pizza',
        color: 'red',
        type: CategoryType.expense,
      );
      expect(
        const CategoryState().copyWith(category: category),
        equals(const CategoryState(category: category)),
      );
    });

    test('copyWith returns original object when properties are null', () {
      expect(const CategoryState().copyWith(), equals(const CategoryState()));
    });
  });
}
