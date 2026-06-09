import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockDatabaseRepository extends Mock implements DatabaseRepository {}

void main() {
  late DatabaseService databaseService;
  late MockDatabaseRepository mockDatabaseRepository;

  setUpAll(() {
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

  setUp(() {
    mockDatabaseRepository = MockDatabaseRepository();
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

      when(
        () => mockDatabaseRepository.saveMovement(movement: movement),
      ).thenReturn(null);

      databaseService.saveMovement(movement: movement);

      verify(
        () => mockDatabaseRepository.saveMovement(movement: movement),
      ).called(1);
    });

    test('getCategoriesStream delegates to repository', () {
      when(
        () => mockDatabaseRepository.getCategoriesStream(),
      ).thenAnswer((_) => Stream.value([]));

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
      verify(
        () => mockDatabaseRepository.getMovements(userId: 'user_1'),
      ).called(1);
    });

    test('deleteMovement delegates to repository', () {
      when(
        () => mockDatabaseRepository.deleteMovement(movementId: 'mov_1'),
      ).thenReturn(null);

      databaseService.deleteMovement(movementId: 'mov_1');

      verify(
        () => mockDatabaseRepository.deleteMovement(movementId: 'mov_1'),
      ).called(1);
    });
  });
}
