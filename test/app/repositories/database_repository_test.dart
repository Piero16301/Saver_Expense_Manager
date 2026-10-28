// Mocktail mocks sealed Firestore classes for repository unit testing.
// ignore_for_file: subtype_of_sealed_class
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockPerformanceService extends Mock implements PerformanceService {}

class MockTrace extends Mock implements Trace {}

class MockCrashService extends Mock implements CrashService {}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockCollectionReference<T extends Object?> extends Mock
    implements CollectionReference<T> {}

class MockDocumentReference<T extends Object?> extends Mock
    implements DocumentReference<T> {}

class MockQuery<T extends Object?> extends Mock implements Query<T> {}

class MockQuerySnapshot<T extends Object?> extends Mock
    implements QuerySnapshot<T> {}

class MockQueryDocumentSnapshot<T extends Object?> extends Mock
    implements QueryDocumentSnapshot<T> {}

void main() {
  late FirestoreDatabaseRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDoc;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;
  late MockPerformanceService mockPerformanceService;
  late MockTrace mockTrace;
  late MockCrashService mockCrashService;

  setUpAll(() {
    registerFallbackValue(MockTrace());
    registerFallbackValue(Timestamp.now());
  });

  setUp(() async {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDoc = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDocSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();
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

    when(
      () => mockPerformanceService.startTrace(any<String>()),
    ).thenReturn(mockTrace);
    when(() => mockPerformanceService.stopTrace(any())).thenReturn(null);

    repository = FirestoreDatabaseRepository(firestore: mockFirestore);
  });

  group('MockDatabaseRepository', () {
    test('Mock tests for coverage', () async {
      final mock = MockDatabaseRepository();
      expect(mock.newId, isNotEmpty);
      mock.saveMovement(movement: Movement.empty);
      expect(await mock.getCategoriesStream().first, isNotEmpty);
      expect(await mock.getMovementsStream(userId: '1').first, isNotEmpty);
      expect(await mock.getMovements(userId: '1'), isNotEmpty);
      mock.deleteMovement(movementId: '1');
    });
  });

  group('FirestoreDatabaseRepository', () {
    test('newId returns a document id', () {
      when(
        () => mockFirestore.collection(AppVariables.movementsCollection),
      ).thenReturn(mockCollection);
      when(() => mockCollection.doc()).thenReturn(mockDoc);
      when(() => mockDoc.id).thenReturn('generated_id_123');

      expect(repository.newId, equals('generated_id_123'));
    });

    test('getCategoriesStream returns a stream of categories', () async {
      const category = Category(
        id: 'cat_1',
        name: 'Food',
        icon: 'pizza',
        color: 'red',
        type: CategoryType.expense,
      );

      when(
        () => mockFirestore.collection(AppVariables.categoriesCollection),
      ).thenReturn(mockCollection);
      when(
        () => mockCollection.snapshots(),
      ).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(() => mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(() => mockDocSnapshot.data()).thenReturn(category.toJson());

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

      final movementData = <String, dynamic>{
        ...movement.toJson(),
        'date': Timestamp.fromDate(movement.date),
      };

      when(
        () => mockFirestore.collection(AppVariables.movementsCollection),
      ).thenReturn(mockCollection);
      when(
        () => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        () => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        () => mockQuery.where(
          any(),
          isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        () => mockQuery.where(any(), isLessThan: any(named: 'isLessThan')),
      ).thenReturn(mockQuery);
      when(
        () => mockQuery.orderBy(any(), descending: any(named: 'descending')),
      ).thenReturn(mockQuery);
      when(() => mockQuery.limit(any())).thenReturn(mockQuery);
      when(
        () => mockQuery.snapshots(),
      ).thenAnswer((_) => Stream.value(mockQuerySnapshot));
      when(() => mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(() => mockDocSnapshot.data()).thenReturn(movementData);

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

      when(
        () => mockFirestore.collection(AppVariables.movementsCollection),
      ).thenReturn(mockCollection);
      when(() => mockCollection.doc(movement.id)).thenReturn(mockDoc);
      when(() => mockDoc.set(any())).thenAnswer((_) async {});

      repository.saveMovement(movement: movement);

      verify(() => mockDoc.set(movement.toJson())).called(1);
    });

    test('saveMovement records error on exception', () async {
      when(
        () => mockFirestore.collection(any<String>()),
      ).thenThrow(Exception('Firestore Fail'));

      repository.saveMovement(movement: Movement.empty.copyWith(id: '1'));

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
      when(
        () => mockFirestore.collection(AppVariables.movementsCollection),
      ).thenReturn(mockCollection);
      when(() => mockCollection.doc(movementId)).thenReturn(mockDoc);
      when(() => mockDoc.delete()).thenAnswer((_) async {});

      repository.deleteMovement(movementId: movementId);

      verify(() => mockDoc.delete()).called(1);
    });

    test('deleteMovement records error on exception', () async {
      when(
        () => mockFirestore.collection(any<String>()),
      ).thenThrow(Exception('Delete Fail'));

      repository.deleteMovement(movementId: '1');

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: any<dynamic>(named: 'reason'),
        ),
      ).called(1);
    });

    test('getMovements returns full list', () async {
      final date = DateTime(2023, 10, 15);
      final movement = Movement.empty.copyWith(
        id: '1',
        user: 'user_1',
        date: date,
      );

      final movementData = <String, dynamic>{
        ...movement.toJson(),
        'date': Timestamp.fromDate(movement.date),
      };

      when(
        () => mockFirestore.collection(AppVariables.movementsCollection),
      ).thenReturn(mockCollection);
      when(
        () => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        () => mockQuery.where(
          any(),
          isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(
        () => mockQuery.where(any(), isLessThan: any(named: 'isLessThan')),
      ).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(() => mockDocSnapshot.data()).thenReturn(movementData);

      final result = await repository.getMovements(
        userId: 'user_1',
        from: DateTime(2023, 10),
        to: DateTime(2023, 11),
      );

      expect(result.length, 1);
      expect(result.first.id, equals('1'));
      verify(
        () => mockPerformanceService.startTrace('firestore_get_movements'),
      ).called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('getMovements records error and rethrows on failure', () async {
      when(
        () => mockFirestore.collection(AppVariables.movementsCollection),
      ).thenReturn(mockCollection);
      when(
        () => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')),
      ).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Firestore Get Fail'));

      await expectLater(
        () => repository.getMovements(userId: 'user_1'),
        throwsA(isA<Exception>()),
      );

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: any<dynamic>(named: 'reason'),
        ),
      ).called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });
  });
}
