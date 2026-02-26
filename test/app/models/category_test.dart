import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/category.dart';

void main() {
  group('Category', () {
    const id = 'id';
    const name = 'name';
    const icon = 'icon';
    const color = 'color';
    const type = CategoryType.expense;

    test('supports value equality', () {
      expect(
        const Category(
          id: id,
          name: name,
          icon: icon,
          color: color,
          type: type,
        ),
        equals(
          const Category(
            id: id,
            name: name,
            icon: icon,
            color: color,
            type: type,
          ),
        ),
      );
    });

    group('fromJson', () {
      test('returns correct Category entirely from json', () {
        final json = <String, dynamic>{
          'id': id,
          'name': name,
          'icon': icon,
          'color': color,
          'type': 'EXPENSE',
        };

        expect(
          Category.fromJson(json),
          equals(
            const Category(
              id: id,
              name: name,
              icon: icon,
              color: color,
              type: type,
            ),
          ),
        );
      });

      test('returns correct Category with default empty values', () {
        final json = <String, dynamic>{};

        expect(
          Category.fromJson(json),
          equals(
            Category.empty,
          ),
        );
      });
    });

    group('toJson', () {
      test('returns correct map', () {
        const category = Category(
          id: id,
          name: name,
          icon: icon,
          color: color,
          type: type,
        );

        final json = category.toJson();

        expect(
          json,
          equals(<String, dynamic>{
            'id': id,
            'name': name,
            'icon': icon,
            'color': color,
            'type': 'EXPENSE',
          }),
        );
      });
    });

    test('empty category has correct empty values', () {
      expect(
        Category.empty,
        equals(
          Category.empty,
        ),
      );
    });
  });

  group('CategoryType', () {
    test('categoryTypeFromJson returns income for "INCOME"', () {
      expect(
        CategoryType.categoryTypeFromJson('INCOME'),
        equals(CategoryType.income),
      );
    });

    test('categoryTypeFromJson returns expense for anything else', () {
      expect(
        CategoryType.categoryTypeFromJson('EXPENSE'),
        equals(CategoryType.expense),
      );
      expect(
        CategoryType.categoryTypeFromJson('RANDOM'),
        equals(CategoryType.expense),
      );
      expect(
        CategoryType.categoryTypeFromJson(''),
        equals(CategoryType.expense),
      );
    });
  });
}
