import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockLocalStorageRepository extends Mock
    implements LocalStorageRepository {}

void main() {
  late LocalStorageService service;
  late MockLocalStorageRepository mockRepository;

  setUp(() {
    mockRepository = MockLocalStorageRepository();
    service = LocalStorageService(localStorageRepository: mockRepository);
  });

  group('LocalStorageService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
  });
}
