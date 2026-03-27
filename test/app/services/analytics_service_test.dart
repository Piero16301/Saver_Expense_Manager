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
    test('logEvent calls repository logEvent', () {
      when(
        () => mockRepository.logEvent(
          name: any<String>(named: 'name'),
          parameters: any<Map<String, Object>?>(named: 'parameters'),
        ),
      ).thenReturn(null);
      service.logEvent(name: 'event', parameters: {'k': 'v'});
      verify(
        () => mockRepository.logEvent(
          name: 'event',
          parameters: {'k': 'v'},
        ),
      ).called(1);
    });

    test('setCurrentScreen calls repository setCurrentScreen', () {
      when(
        () => mockRepository.setCurrentScreen(
          screenName: any<String>(named: 'screenName'),
        ),
      ).thenReturn(null);
      service.setCurrentScreen(screenName: 'screen');
      verify(
        () => mockRepository.setCurrentScreen(
          screenName: 'screen',
        ),
      ).called(1);
    });

    test('setUserId calls repository setUserId', () {
      when(
        () => mockRepository.setUserId(
          id: any<String>(named: 'id'),
        ),
      ).thenReturn(null);
      service.setUserId(id: '123');
      verify(() => mockRepository.setUserId(id: '123')).called(1);
    });
  });
}
