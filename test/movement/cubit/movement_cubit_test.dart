import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/movement/cubit/movement_cubit.dart';

void main() {
  group('MovementCubit', () {
    late MovementCubit movementCubit;
    final date = DateTime(2023);
    const category = Category(
      id: '1',
      name: 'test',
      icon: 'test',
      color: 'red',
      type: CategoryType.expense,
    );
    final categories = [category];
    final movement = Movement(
      id: 'm1',
      title: 'Coffee',
      description: 'Morning',
      date: date,
      category: category,
      price: 5,
      user: 'u1',
      company: 'Starbucks',
      attachments: const ['file1'],
      movementRecap: 'Recap',
    );

    setUp(() {
      movementCubit = MovementCubit();
    });

    test('initial state is correct', () {
      expect(movementCubit.state, const MovementState());
    });

    blocTest<MovementCubit, MovementState>(
      'init emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.init(movement, categories),
      expect: () => [
        isA<MovementState>()
            .having((s) => s.id, 'id', 'm1')
            .having((s) => s.title, 'title', 'Coffee')
            .having((s) => s.description, 'description', 'Morning')
            .having((s) => s.date, 'date', date)
            .having((s) => s.categories, 'categories', categories)
            .having((s) => s.category, 'category', category)
            .having((s) => s.price, 'price', 5)
            .having((s) => s.company, 'company', 'Starbucks')
            .having((s) => s.attachments, 'attachments', const ['file1'])
            .having((s) => s.movementRecap, 'movementRecap', 'Recap')
            .having((s) => s.formKey, 'formKey', isNotNull),
      ],
    );

    blocTest<MovementCubit, MovementState>(
      'titleChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.titleChanged('New Title'),
      expect: () => [const MovementState(title: 'New Title')],
    );

    blocTest<MovementCubit, MovementState>(
      'descriptionChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.descriptionChanged('New Description'),
      expect: () => [const MovementState(description: 'New Description')],
    );

    blocTest<MovementCubit, MovementState>(
      'dateChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.dateChanged(date),
      expect: () => [MovementState(date: date)],
    );

    blocTest<MovementCubit, MovementState>(
      'categoryChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.categoryChanged(category),
      expect: () => [const MovementState(category: category)],
    );

    blocTest<MovementCubit, MovementState>(
      'priceChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.priceChanged('10.5'),
      expect: () => [const MovementState(price: 10.5)],
    );

    blocTest<MovementCubit, MovementState>(
      'priceChanged defaults to 0 on invalid input',
      build: () => movementCubit,
      act: (cubit) => cubit.priceChanged('invalid'),
      expect: () => [const MovementState()],
    );

    blocTest<MovementCubit, MovementState>(
      'companyChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.companyChanged('New Company'),
      expect: () => [const MovementState(company: 'New Company')],
    );

    blocTest<MovementCubit, MovementState>(
      'attachAdd adds string to list and emits',
      build: () => movementCubit,
      act: (cubit) {
        cubit
          ..attachAdd('file1')
          ..attachAdd('file2');
      },
      expect: () => [
        const MovementState(attachments: ['file1']),
        const MovementState(attachments: ['file1', 'file2']),
      ],
    );
  });
}
