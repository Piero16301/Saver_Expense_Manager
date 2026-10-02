import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAiRepository extends Mock implements AiRepository {}

void main() {
  late AiService service;
  late MockAiRepository mockRepository;

  setUp(() {
    mockRepository = MockAiRepository();
    service = AiService(aiRepository: mockRepository);
  });

  group('AiService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
    test('initialize calls repository initialize', () async {
      when(() => mockRepository.initialize()).thenAnswer((_) async {});
      await service.initialize();
      verify(() => mockRepository.initialize()).called(1);
    });

    test('isLocalModelAvailable returns value from repository', () {
      when(() => mockRepository.isLocalModelAvailable).thenReturn(true);
      expect(service.isLocalModelAvailable, isTrue);
    });

    test(
      'generateContentFromTemplate calls repository and returns result',
      () async {
        when(
          () => mockRepository.generateContentFromTemplate(
            templateId: 'extractor-de-gastos',
            attachment: any(named: 'attachment'),
            inputs: any(named: 'inputs'),
          ),
        ).thenAnswer((_) async => 'result');
        final result = await service.generateContentFromTemplate(
          templateId: 'extractor-de-gastos',
        );
        expect(result, equals('result'));
        verify(
          () => mockRepository.generateContentFromTemplate(
            templateId: 'extractor-de-gastos',
            attachment: any(named: 'attachment'),
            inputs: any(named: 'inputs'),
          ),
        ).called(1);
      },
    );

    test('generateContentLocal calls repository and returns result', () async {
      final textPrompt = PromptPart.text(text: 'text');
      when(
        () => mockRepository.generateContentLocal(textPrompt: textPrompt),
      ).thenAnswer((_) async => 'result');
      final result = await service.generateContentLocal(textPrompt: textPrompt);
      expect(result, equals('result'));
      verify(
        () => mockRepository.generateContentLocal(textPrompt: textPrompt),
      ).called(1);
    });
  });
}
