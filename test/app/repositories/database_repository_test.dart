import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockPerformanceService extends Mock implements PerformanceService {}

class MockTrace extends Mock implements Trace {}

class MockCrashService extends Mock implements CrashService {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

void main() {
  late FirestoreDatabaseRepository repository;
  late FakeFirebaseFirestore fakeFirestore;
  late MockPerformanceService mockPerformanceService;
  late MockTrace mockTrace;
  late MockCrashService mockCrashService;

  setUpAll(() {
    registerFallbackValue(MockTrace());
  });

  setUp(() async {
    fakeFirestore = FakeFirebaseFirestore();
    mockPerformanceService = MockPerformanceService();
    mockTrace = MockTrace();
    mockCrashService = MockCrashService();

    await getIt.reset();
    getIt
      ..registerSingleton<PerformanceService>(mockPerformanceService)
      ..registerSingleton<CrashService>(mockCrashService);

    when(
      () => mockCrashService.recordError(
        any<Object>(),
        any<StackTrace?>(),
        reason: any<dynamic>(named: 'reason'),
      ),
    ).thenAnswer((_) async {});

    when(() => mockPerformanceService.startTrace(any<String>()))
        .thenReturn(mockTrace);
    when(() => mockPerformanceService.stopTrace(any())).thenReturn(null);

    repository = FirestoreDatabaseRepository(firestore: fakeFirestore);
  });

  group('MockDatabaseRepository', () {
    test('Mock tests for coverage', () async {
      final mock = MockDatabaseRepository();
      expect(mock.newId, isNotEmpty);
      expect(await mock.saveMovement(movement: Movement.empty), isTrue);
      expect(await mock.getCategoriesStream().first, isNotEmpty);
      expect(await mock.getMovementsStream(userId: '1').first, isNotEmpty);
      expect(await mock.getMovements(userId: '1'), isNotEmpty);
      expect(await mock.deleteMovement(movementId: '1'), isTrue);
    });
  });

  group('FirestoreDatabaseRepository', () {
    test('newId returns a document id', () {
      expect(repository.newId, isNotEmpty);
    });

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

      final stream = repository.getCategoriesStream();
      final docs = await stream.first;

      expect(docs, isNotEmpty);
      expect(docs.first.id, category.id);
    });

    test('getMovementsStream returns filtered movements', () async {
      final movement = Movement(
        id: 'mov_1',
        title: 'Lunch',
        description: 'Pizza',
        date: DateTime(2023, 10, 15),
        category: const Category(
          id: 'cat_1',
          name: 'Food',
          icon: 'pizza',
          color: 'red',
          type: CategoryType.expense,
        ),
        price: 15,
        user: 'user_1',
      );

      await fakeFirestore
          .collection(AppVariables.movementsCollection)
          .doc(movement.id)
          .set(movement.toJson());

      // Test with multiple filters to hit branches
      final stream = repository.getMovementsStream(
        userId: 'user_1',
        startDate: DateTime(2023, 10),
        endDate: DateTime(2023, 11),
        type: CategoryType.expense,
        categoryId: 'cat_1',
        limit: 10,
        orderByDate: true,
      );

      final docs = await stream.first;
      expect(docs.length, 1);
      expect(docs.first.id, movement.id);
    });

    test('saveMovement stores movement correctly', () async {
      final movement = Movement(
        id: 'mov_1',
        title: 'Lunch',
        description: 'Pizza',
        date: DateTime.now(),
        category: Category.empty,
        price: 15,
        user: 'user_1',
      );

      final result = await repository.saveMovement(movement: movement);
      expect(result, isTrue);

      final doc = await fakeFirestore
          .collection(AppVariables.movementsCollection)
          .doc(movement.id)
          .get();
      expect(doc.exists, isTrue);
    });

    test('saveMovement returns false and records error on exception', () async {
      final mockFirestore = MockFirebaseFirestore();
      final repo = FirestoreDatabaseRepository(firestore: mockFirestore);

      when(() => mockFirestore.collection(any<String>()))
          .thenThrow(Exception('Firestore Fail'));

      final result =
          await repo.saveMovement(movement: Movement.empty.copyWith(id: '1'));

      expect(result, isFalse);
      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: any<dynamic>(named: 'reason'),
        ),
      ).called(1);
    });

    test('deleteMovement removes movement correctly', () async {
      const movementId = 'mov_1';
      await fakeFirestore
          .collection(AppVariables.movementsCollection)
          .doc(movementId)
          .set({'title': 'test'});

      final result = await repository.deleteMovement(movementId: movementId);
      expect(result, isTrue);

      final doc = await fakeFirestore
          .collection(AppVariables.movementsCollection)
          .doc(movementId)
          .get();
      expect(doc.exists, isFalse);
    });

    test('deleteMovement returns false and records error on exception',
        () async {
      final mockFirestore = MockFirebaseFirestore();
      final repo = FirestoreDatabaseRepository(firestore: mockFirestore);

      when(() => mockFirestore.collection(any<String>()))
          .thenThrow(Exception('Delete Fail'));

      final result = await repo.deleteMovement(movementId: '1');

      expect(result, isFalse);
    });

    test('getMovements returns full list', () async {
      final date = DateTime(2023, 10, 15);
      final movement =
          Movement.empty.copyWith(id: '1', user: 'user_1', date: date);

      await fakeFirestore
          .collection(AppVariables.movementsCollection)
          .doc('1')
          .set(movement.toJson());

      final result = await repository.getMovements(
        userId: 'user_1',
        from: DateTime(2023, 10),
        to: DateTime(2023, 11),
      );

      expect(result.length, 1);
    });
  });
}
