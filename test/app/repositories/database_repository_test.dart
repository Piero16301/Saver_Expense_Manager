// Mocktail mocks sealed Firestore classes for repository unit testing.
// ignore_for_file: subtype_of_sealed_class
import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore;

class MockCollectionReference<T extends Object?> extends Mock
    implements CollectionReference<T>;

class MockDocumentReference<T extends Object?> extends Mock
    implements DocumentReference<T>;

class MockQuery<T extends Object?> extends Mock implements Query<T>;

class MockQuerySnapshot<T extends Object?> extends Mock
    implements QuerySnapshot<T>;

class MockQueryDocumentSnapshot<T extends Object?> extends Mock
    implements QueryDocumentSnapshot<T>;

void main() {
  late FirestoreDatabaseRepository repository;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference<Map<String, dynamic>> mockCollection;
  late MockDocumentReference<Map<String, dynamic>> mockDoc;
  late MockQuery<Map<String, dynamic>> mockQuery;
  late MockQuerySnapshot<Map<String, dynamic>> mockQuerySnapshot;
  late MockQueryDocumentSnapshot<Map<String, dynamic>> mockDocSnapshot;

  setUpAll(() {
    registerFallbackValue(Timestamp.now());
  });

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockCollection = MockCollectionReference<Map<String, dynamic>>();
    mockDoc = MockDocumentReference<Map<String, dynamic>>();
    mockQuery = MockQuery<Map<String, dynamic>>();
    mockQuerySnapshot = MockQuerySnapshot<Map<String, dynamic>>();
    mockDocSnapshot = MockQueryDocumentSnapshot<Map<String, dynamic>>();

    repository = FirestoreDatabaseRepository(firestore: mockFirestore);
  });

  group('MockDatabaseRepository', () {
    test(
      'provides 25 categories, filtered reactive streams, and CRUD',
      () async {
        final mock = MockDatabaseRepository();
        expect(mock.newId, isNotEmpty);

        final categories = await mock.getCategoriesStream().first;
        expect(categories, hasLength(25));
        expect(
          () => categories.sort((a, b) => a.name.compareTo(b.name)),
          returnsNormally,
        );

        final allMovements = await mock.getMovements(userId: '1');
        expect(allMovements.length, greaterThanOrEqualTo(20));

        final limited = await mock
            .getMovementsStream(userId: '1', limit: 5, orderByDate: true)
            .first;
        expect(limited, hasLength(5));
        expect(
          limited.first.date.isAfter(limited.last.date) ||
              limited.first.date.isAtSameMomentAs(limited.last.date),
          isTrue,
        );

        final expenseOnly = await mock
            .getMovementsStream(userId: '1', type: CategoryType.expense)
            .first;
        expect(
          expenseOnly.every((m) => m.category.type == CategoryType.expense),
          isTrue,
        );

        final newId = mock.newId;
        final added = Movement(
          id: newId,
          title: 'Test movement',
          description: 'Desc',
          date: DateTime.now(),
          category: categories.first,
          price: 42,
          user: '1',
        );
        await mock.saveMovement(movement: added);
        final afterAdd = await mock.getMovements(userId: '1');
        expect(afterAdd.any((m) => m.id == newId && m.price == 42), isTrue);

        await mock.saveMovement(movement: added.copyWith(price: 99));
        final afterUpdate = await mock.getMovements(userId: '1');
        expect(
          afterUpdate.where((m) => m.id == newId).single.price,
          equals(99),
        );

        await mock.deleteMovement(movementId: newId);
        final afterDelete = await mock.getMovements(userId: '1');
        expect(afterDelete.any((m) => m.id == newId), isFalse);
      },
    );
  });

  group('FirestoreDatabaseRepository', () {
    test('newId returns a document id', () {
      when(() => mockFirestore.collection(AppVariables.movementsCollection))
          .thenReturn(mockCollection);
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

      when(() => mockFirestore.collection(AppVariables.categoriesCollection))
          .thenReturn(mockCollection);
      when(() => mockCollection.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));
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

      when(() => mockFirestore.collection(AppVariables.movementsCollection))
          .thenReturn(mockCollection);
      when(
        () => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')),
      ).thenReturn(mockQuery);
      when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')))
          .thenReturn(mockQuery);
      when(
        () => mockQuery.where(
          any(),
          isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(() => mockQuery.where(any(), isLessThan: any(named: 'isLessThan')))
          .thenReturn(mockQuery);
      when(() => mockQuery.orderBy(any(), descending: any(named: 'descending')))
          .thenReturn(mockQuery);
      when(() => mockQuery.limit(any())).thenReturn(mockQuery);
      when(() => mockQuery.snapshots())
          .thenAnswer((_) => Stream.value(mockQuerySnapshot));
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

      when(() => mockFirestore.collection(AppVariables.movementsCollection))
          .thenReturn(mockCollection);
      when(() => mockCollection.doc(movement.id)).thenReturn(mockDoc);
      when(() => mockDoc.set(any())).thenAnswer((_) async {});

      await repository.saveMovement(movement: movement);

      verify(() => mockDoc.set(movement.toJson())).called(1);
    });

    test('saveMovement rethrows on exception', () {
      when(() => mockFirestore.collection(any<String>()))
          .thenThrow(Exception('Firestore Fail'));

      expect(
        () =>
            repository.saveMovement(movement: Movement.empty.copyWith(id: '1')),
        throwsException,
      );
    });

    test('deleteMovement removes movement correctly', () async {
      const movementId = 'mov_1';
      when(() => mockFirestore.collection(AppVariables.movementsCollection))
          .thenReturn(mockCollection);
      when(() => mockCollection.doc(movementId)).thenReturn(mockDoc);
      when(() => mockDoc.delete()).thenAnswer((_) async {});

      await repository.deleteMovement(movementId: movementId);

      verify(() => mockDoc.delete()).called(1);
    });

    test('deleteMovement rethrows on exception', () {
      when(() => mockFirestore.collection(any<String>()))
          .thenThrow(Exception('Delete Fail'));

      expect(() => repository.deleteMovement(movementId: '1'), throwsException);
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

      when(() => mockFirestore.collection(AppVariables.movementsCollection))
          .thenReturn(mockCollection);
      when(
        () => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')),
      ).thenReturn(mockQuery);
      when(
        () => mockQuery.where(
          any(),
          isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo'),
        ),
      ).thenReturn(mockQuery);
      when(() => mockQuery.where(any(), isLessThan: any(named: 'isLessThan')))
          .thenReturn(mockQuery);
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
    });

    test('getMovements rethrows on failure', () async {
      when(() => mockFirestore.collection(AppVariables.movementsCollection))
          .thenReturn(mockCollection);
      when(
        () => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')),
      ).thenReturn(mockQuery);
      when(() => mockQuery.get()).thenThrow(Exception('Firestore Get Fail'));

      await expectLater(
        () => repository.getMovements(userId: 'user_1'),
        throwsA(isA<Exception>()),
      );
    });

    test('getMovements falls back to cache on TimeoutException', () async {
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

      when(() => mockFirestore.collection(AppVariables.movementsCollection))
          .thenReturn(mockCollection);
      when(
        () => mockCollection.where(any(), isEqualTo: any(named: 'isEqualTo')),
      ).thenReturn(mockQuery);
      when(() => mockQuery.get())
          .thenThrow(TimeoutException('Firestore timeout'));
      when(() => mockQuery.get(const GetOptions(source: Source.cache)))
          .thenAnswer((_) async => mockQuerySnapshot);
      when(() => mockQuerySnapshot.docs).thenReturn([mockDocSnapshot]);
      when(() => mockDocSnapshot.data()).thenReturn(movementData);

      final result = await repository.getMovements(userId: 'user_1');

      expect(result.length, 1);
      expect(result.first.id, equals('1'));
      verify(() => mockQuery.get(const GetOptions(source: Source.cache)))
          .called(1);
    });
  });
}
