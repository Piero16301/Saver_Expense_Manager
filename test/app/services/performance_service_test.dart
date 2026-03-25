import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockPerformanceRepository extends Mock implements PerformanceRepository {}

void main() {
  late PerformanceService service;
  late MockPerformanceRepository mockRepository;

  setUp(() {
    mockRepository = MockPerformanceRepository();
    service = PerformanceService(performanceRepository: mockRepository);
  });

  group('PerformanceService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
  });
}
