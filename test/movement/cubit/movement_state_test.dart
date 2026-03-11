import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/movement/cubit/movement_cubit.dart';

void main() {
  group('MovementState', () {
    test('supports value equality', () {
      expect(
        const MovementState(),
        equals(const MovementState()),
      );
    });

    test('props are correct', () {
      expect(
        const MovementState().props,
        equals(<Object?>[
          '',
          '',
          '',
          null,
          const <Category>[],
          null,
          0.0,
          '',
          const <String>[],
          null,
        ]),
      );
    });

    test('copyWith returns object with updated properties', () {
      final date = DateTime(2023);
      const category = Category(
        id: '1',
        name: 'Food',
        icon: 'pizza',
        color: 'red',
        type: CategoryType.expense,
      );
      expect(
        const MovementState().copyWith(
          id: '123',
          title: 'Title',
          description: 'Desc',
          date: date,
          categories: [category],
          category: category,
          price: 15,
          company: 'Co',
          attachments: ['att1'],
        ),
        equals(
          MovementState(
            id: '123',
            title: 'Title',
            description: 'Desc',
            date: date,
            categories: const [category],
            category: category,
            price: 15,
            company: 'Co',
            attachments: const ['att1'],
          ),
        ),
      );
    });

    test('copyWith returns original object when properties are null', () {
      expect(
        const MovementState().copyWith(),
        equals(const MovementState()),
      );
    });
  });
}
