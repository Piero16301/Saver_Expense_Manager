import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/models.dart';

void main() {
  group('CategoryData', () {
    const category = Category.empty;
    const value = 50.0;

    test('supports value equality', () {
      expect(
        const CategoryData(category: category, value: value),
        equals(const CategoryData(category: category, value: value)),
      );
    });

    group('fromJson', () {
      test('returns correct instance from fully populated map', () {
        final json = <String, dynamic>{
          'category': category.toJson(),
          'value': value,
        };

        expect(
          CategoryData.fromJson(json),
          equals(const CategoryData(category: category, value: value)),
        );
      });

      test('returns correct instance with defaults from empty map', () {
        expect(
          CategoryData.fromJson(const {}),
          equals(
            CategoryData(
              category: Category.fromJson(const {}),
              value: 0,
            ),
          ),
        );
      });
    });

    group('toJson', () {
      test('returns correct map', () {
        const data = CategoryData(category: category, value: value);
        expect(
          data.toJson(),
          equals({
            'category': category.toJson(),
            'value': value,
          }),
        );
      });
    });
  });
}
