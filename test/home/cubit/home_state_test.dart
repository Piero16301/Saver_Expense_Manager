import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/home/cubit/home_cubit.dart';

void main() {
  group('HomeState', () {
    test('supports value equality', () {
      expect(
        const HomeState(selectedIndex: 0),
        equals(const HomeState(selectedIndex: 0)),
      );
    });

    test('props are correct', () {
      expect(
        const HomeState(selectedIndex: 1).props,
        equals(<Object?>[
          1,
        ]),
      );
    });

    test('copyWith returns object with updated properties', () {
      expect(
        const HomeState(selectedIndex: 0).copyWith(
          selectedIndex: 2,
        ),
        equals(const HomeState(selectedIndex: 2)),
      );
    });

    test('copyWith returns original object when properties are null', () {
      expect(
        const HomeState(selectedIndex: 3).copyWith(),
        equals(const HomeState(selectedIndex: 3)),
      );
    });
  });
}
