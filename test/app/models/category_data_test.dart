import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/category.dart';
import 'package:saver_expense_manager/app/models/category_data.dart';

void main() {
  group('CategoryData', () {
    const category = Category(
      id: '1',
      name: 'Food',
      icon: 'fastfood',
      color: 'red',
      type: CategoryType.expense,
    );
    const categoryData = CategoryData(
      category: category,
      value: 100,
    );

    test('supports value comparisons', () {
      expect(
        const CategoryData(category: category, value: 100),
        const CategoryData(category: category, value: 100),
      );
    });

    test('props are correct', () {
      expect(
        categoryData.props,
        equals([category, 100.0]),
      );
    });

    group('fromJson', () {
      test('returns correct object from valid json', () {
        final json = {
          'category': category.toJson(),
          'value': 100.0,
        };
        expect(CategoryData.fromJson(json), categoryData);
      });

      test('returns default object when json is empty', () {
        final instance = CategoryData.fromJson(const {});
        expect(instance.value, 0.0);
        expect(instance.category, isA<Category>());
        expect(instance.category.id, '');
        expect(instance.category.name, '');
      });

      test('handles null value correctly', () {
        final json = {
          'category': category.toJson(),
          'value': null,
        };
        final instance = CategoryData.fromJson(json);
        expect(instance.value, 0.0);
        expect(instance.category, category);
      });

      test('handles int value correctly', () {
        final json = {
          'category': category.toJson(),
          'value': 100,
        };
        final instance = CategoryData.fromJson(json);
        expect(instance.value, 100.0);
      });
    });

    group('toJson', () {
      test('returns correct map', () {
        expect(
          categoryData.toJson(),
          {
            'category': category.toJson(),
            'value': 100.0,
          },
        );
      });
    });
  });
}
