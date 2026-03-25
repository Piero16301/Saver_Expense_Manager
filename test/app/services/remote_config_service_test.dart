import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockRemoteConfigRepository extends Mock
    implements RemoteConfigRepository {}

void main() {
  late RemoteConfigService service;
  late MockRemoteConfigRepository mockRepository;

  setUp(() {
    mockRepository = MockRemoteConfigRepository();
    service = RemoteConfigService(remoteConfigRepository: mockRepository);
  });

  group('RemoteConfigService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });

    test('initialize calls repository initialize', () async {
      when(() => mockRepository.initialize()).thenAnswer((_) async {});
      await service.initialize();
      verify(() => mockRepository.initialize()).called(1);
    });

    test('homeInitialTab returns from repository', () {
      when(() => mockRepository.homeInitialTab).thenReturn('home');
      expect(service.homeInitialTab, equals('home'));
    });

    test('geminiModelId returns from repository', () {
      when(() => mockRepository.geminiModelId).thenReturn('model');
      expect(service.geminiModelId, equals('model'));
    });

    test('geminiPromptExtractReceiptData returns from repository', () {
      when(() => mockRepository.geminiPromptExtractReceiptData)
          .thenReturn('prompt1');
      expect(service.geminiPromptExtractReceiptData, equals('prompt1'));
    });

    test('geminiPromptDetectAntExpense returns from repository', () {
      when(() => mockRepository.geminiPromptDetectAntExpense)
          .thenReturn('prompt2');
      expect(service.geminiPromptDetectAntExpense, equals('prompt2'));
    });

    test('geminiAntLookbackDays returns from repository', () {
      when(() => mockRepository.geminiAntLookbackDays).thenReturn(30);
      expect(service.geminiAntLookbackDays, equals(30));
    });

    test('paginationLimit returns from repository', () {
      when(() => mockRepository.paginationLimit).thenReturn(20);
      expect(service.paginationLimit, equals(20));
    });
  });
}
