import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  late DatabaseService databaseService;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    databaseService = DatabaseService(firestore: fakeFirestore);
  });

  group('DatabaseService', () {
    test('getCategoriesStream returns a stream of categories', () async {
      const category = Category(
        id: 'cat_1',
        name: 'Food',
        icon: 'pizza',
        color: 'red',
        type: CategoryType.expense,
      );

      await fakeFirestore
          .collection(AppVariables.categoriesCollection)
          .doc(category.id)
          .set(category.toJson());

      final stream = databaseService.getCategoriesStream();
      final docs = await stream.first;

      expect(docs, isNotEmpty);
      expect(docs.first.id, category.id);
      expect(docs.first.name, category.name);
    });

    test('getMonthMovementsStream returns correct movements', () async {
      final date = DateTime(2023, 10, 15);
      final movement = Movement(
        id: 'mov_1',
        title: 'Lunch',
        description: 'Pizza',
        date: date,
        category: const Category(
          id: 'cat_1',
          name: 'Food',
          icon: 'pizza',
          color: 'red',
          type: CategoryType.expense,
        ),
        price: 15,
        user: 'user_1',
        movementRecap: r'Lunch: $15.0',
      );

      await fakeFirestore
          .collection(AppVariables.movementsCollection)
          .doc(movement.id)
          .set(movement.toJson());

      final movement2 = movement.copyWith(id: 'mov_2', user: 'user_2');
      await fakeFirestore
          .collection(AppVariables.movementsCollection)
          .doc(movement2.id)
          .set(movement2.toJson());

      final stream = databaseService.getMonthMovementsStream(
        userId: 'user_1',
        monthSelected: date,
        type: CategoryType.expense,
      );
      final docs = await stream.first;

      expect(docs.length, 1);
      expect(docs.first.id, movement.id);
    });

    test('getUserMovementsRangeStream returns correct movements', () async {
      final date = DateTime(2023, 10, 15);
      final movement = Movement(
        id: 'mov_1',
        title: 'Lunch',
        description: '',
        date: date,
        category: Category.empty,
        price: 15,
        user: 'user_1',
        movementRecap: '',
      );

      await fakeFirestore
          .collection(AppVariables.movementsCollection)
          .doc(movement.id)
          .set(movement.toJson());

      final stream = databaseService.getUserMovementsRangeStream(
        userId: 'user_1',
        startMonth: DateTime(2023, 10),
        endMonth: DateTime(2023, 10, 31),
      );
      final docs = await stream.first;

      expect(docs.length, 1);
      expect(docs.first.id, movement.id);
    });

    test('getCategoryMovementsQuery filters correctly', () async {
      const category = Category(
        id: 'cat_1',
        name: 'Food',
        icon: '',
        color: '',
        type: CategoryType.expense,
      );
      final query = databaseService.getCategoryMovementsQuery(
        userId: 'user_1',
        monthSelected: DateTime(2023, 10, 15),
        category: category,
      );

      final snapshot = await query.get();
      expect(snapshot.docs, isEmpty);
    });

    test('getExpenseTypeMovementsQuery filters correctly', () async {
      final query = databaseService.getExpenseTypeMovementsQuery(
        userId: 'user_1',
        monthSelected: DateTime(2023, 10, 15),
        expenseType: CategoryType.income,
      );

      final snapshot = await query.get();
      expect(snapshot.docs, isEmpty);
    });

    test('getUserMovementsQuery filters correctly', () async {
      const category = Category(
        id: 'cat_1',
        name: 'Food',
        icon: '',
        color: '',
        type: CategoryType.expense,
      );
      final query = databaseService.getUserMovementsQuery(
        userId: 'user_1',
        type: CategoryType.expense,
        category: category,
      );

      final snapshot = await query.get();
      expect(snapshot.docs, isEmpty);
    });

    test('getTrendChartStream filters correctly', () async {
      const category = Category(
        id: 'cat_1',
        name: 'Food',
        icon: '',
        color: '',
        type: CategoryType.expense,
      );

      final stream = databaseService.getTrendChartStream(
        userId: 'user_1',
        startMonth: DateTime(2023, 8),
        endMonth: DateTime(2023, 10),
        category: category,
      );

      final snapshot = await stream.first;
      expect(snapshot, isEmpty);
    });

    test('getMovementsStream filters correctly', () async {
      final stream = databaseService.getMovementsStream(
        userId: 'user_1',
        from: DateTime(2023, 8),
        to: DateTime(2023, 10),
        limit: 5,
      );

      final snapshot = await stream.first;
      expect(snapshot, isEmpty);
    });

    test('getMovements returns correct results passed filters', () async {
      final result = await databaseService.getMovements(
        userId: 'user_1',
        from: DateTime(2023, 8),
        to: DateTime(2023, 10),
      );

      expect(result, isEmpty);
    });
  });
}
