import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockDatabaseRepository extends Mock implements DatabaseRepository;

class MockTrace extends Mock implements Trace;

class MockPerformanceService extends Mock implements PerformanceService;

class MockCrashService extends Mock implements CrashService;

void main() {
  late DatabaseService databaseService;
  late MockDatabaseRepository mockDatabaseRepository;
  late MockTrace mockTrace;
  late MockPerformanceService mockPerformanceService;
  late MockCrashService mockCrashService;

  setUpAll(() {
    registerFallbackValue(MockTrace());
    registerFallbackValue(
      Movement(
        id: '1',
        title: 'test',
        description: '',
        date: DateTime.now(),
        category: Category.empty,
        price: 0,
        user: '1',
      ),
    );
  });

  setUp(() async {
    mockDatabaseRepository = MockDatabaseRepository();
    mockTrace = MockTrace();
    mockPerformanceService = MockPerformanceService();
    mockCrashService = MockCrashService();

    await getIt.reset();
    getIt
      ..registerSingleton<PerformanceService>(mockPerformanceService)
      ..registerSingleton<CrashService>(mockCrashService);

    when(() => mockPerformanceService.startTrace(any<String>()))
        .thenReturn(mockTrace);
    when(() => mockPerformanceService.stopTrace(any<Trace>())).thenReturn(null);

    databaseService = DatabaseService(
      databaseRepository: mockDatabaseRepository,
    );
  });

  group('DatabaseService Delegation', () {
    test('newId delegates to repository', () {
      when(() => mockDatabaseRepository.newId).thenReturn('test_id');

      final result = databaseService.newId;

      expect(result, 'test_id');
      verify(() => mockDatabaseRepository.newId).called(1);
    });

    test('saveMovement delegates to repository', () {
      final movement = Movement(
        id: '1',
        title: 'test',
        description: '',
        date: DateTime.now(),
        category: Category.empty,
        price: 0,
        user: '1',
      );

      when(() => mockDatabaseRepository.saveMovement(movement: movement))
          .thenAnswer((_) async {});

      databaseService.saveMovement(movement: movement);

      verify(() => mockDatabaseRepository.saveMovement(movement: movement))
          .called(1);
    });

    test('getCategoriesStream delegates to repository', () {
      when(() => mockDatabaseRepository.getCategoriesStream())
          .thenAnswer((_) => Stream.value([]));

      final stream = databaseService.getCategoriesStream();

      expect(stream, isNotNull);
      verify(() => mockDatabaseRepository.getCategoriesStream()).called(1);
    });

    test('getMovementsStream delegates to repository', () {
      when(
        () => mockDatabaseRepository.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any(named: 'startDate'),
          endDate: any(named: 'endDate'),
          type: any(named: 'type'),
          categoryId: any(named: 'categoryId'),
          limit: any(named: 'limit'),
          orderByDate: any(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      final stream = databaseService.getMovementsStream(
        userId: 'user_1',
        limit: 10,
      );

      expect(stream, isNotNull);
      verify(
        () => mockDatabaseRepository.getMovementsStream(
          userId: 'user_1',
          limit: 10,
          orderByDate: any(named: 'orderByDate'),
        ),
      ).called(1);
    });

    test('getMovements delegates to repository', () async {
      when(
        () => mockDatabaseRepository.getMovements(
          userId: any(named: 'userId'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => []);

      final movements = await databaseService.getMovements(userId: 'user_1');

      expect(movements, isEmpty);
      verify(() => mockDatabaseRepository.getMovements(userId: 'user_1'))
          .called(1);
      verify(() => mockPerformanceService.startTrace('firestore_get_movements'))
          .called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('getMovements records error, stops trace, and rethrows', () async {
      when(
        () => mockDatabaseRepository.getMovements(
          userId: any(named: 'userId'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenThrow(Exception('Get Fail'));

      await expectLater(
        () => databaseService.getMovements(userId: 'user_1'),
        throwsException,
      );

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'DatabaseService getMovements error',
        ),
      ).called(1);
      verify(() => mockPerformanceService.stopTrace(mockTrace)).called(1);
    });

    test('saveMovement records error on exception', () {
      final movement = Movement.empty.copyWith(id: '1');
      when(() => mockDatabaseRepository.saveMovement(movement: movement))
          .thenThrow(Exception('Save Fail'));

      databaseService.saveMovement(movement: movement);

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'DatabaseService saveMovement error',
        ),
      ).called(1);
    });

    test('saveMovement records error on async failure', () async {
      final movement = Movement.empty.copyWith(id: '1');
      when(() => mockDatabaseRepository.saveMovement(movement: movement))
          .thenAnswer((_) => Future.error(Exception('Async Save Fail')));

      databaseService.saveMovement(movement: movement);
      await Future<void>.delayed(Duration.zero);

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'DatabaseService saveMovement error',
        ),
      ).called(1);
    });

    test('deleteMovement delegates to repository', () {
      when(() => mockDatabaseRepository.deleteMovement(movementId: 'mov_1'))
          .thenAnswer((_) async {});

      databaseService.deleteMovement(movementId: 'mov_1');

      verify(() => mockDatabaseRepository.deleteMovement(movementId: 'mov_1'))
          .called(1);
    });

    test('deleteMovement records error on exception', () {
      when(() => mockDatabaseRepository.deleteMovement(movementId: 'mov_1'))
          .thenThrow(Exception('Delete Fail'));

      databaseService.deleteMovement(movementId: 'mov_1');

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'DatabaseService deleteMovement error',
        ),
      ).called(1);
    });

    test('deleteMovement records error on async failure', () async {
      when(() => mockDatabaseRepository.deleteMovement(movementId: 'mov_1'))
          .thenAnswer((_) => Future.error(Exception('Async Delete Fail')));

      databaseService.deleteMovement(movementId: 'mov_1');
      await Future<void>.delayed(Duration.zero);

      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'DatabaseService deleteMovement error',
        ),
      ).called(1);
    });
  });
}
