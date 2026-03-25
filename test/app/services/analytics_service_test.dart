import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAnalyticsRepository extends Mock implements AnalyticsRepository {}

void main() {
  late AnalyticsService service;
  late MockAnalyticsRepository mockRepository;

  setUp(() {
    mockRepository = MockAnalyticsRepository();
    service = AnalyticsService(analyticsRepository: mockRepository);
  });

  group('AnalyticsService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
  });
}
