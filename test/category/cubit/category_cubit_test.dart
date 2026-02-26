import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/category/category.dart';

void main() {
  group('CategoryCubit', () {
    late CategoryCubit categoryCubit;

    setUp(() {
      categoryCubit = CategoryCubit();
    });

    test('initial state is correct', () {
      expect(categoryCubit.state, const CategoryState());
    });

    blocTest<CategoryCubit, CategoryState>(
      'emits updated state when init is called',
      build: () => categoryCubit,
      act: (cubit) => cubit.init(
        const Category(
          id: '1',
          name: 'Food',
          icon: 'pizza',
          color: 'red',
          type: CategoryType.expense,
        ),
      ),
      expect: () => [
        const CategoryState(
          category: Category(
            id: '1',
            name: 'Food',
            icon: 'pizza',
            color: 'red',
            type: CategoryType.expense,
          ),
        ),
      ],
    );
  });
}
