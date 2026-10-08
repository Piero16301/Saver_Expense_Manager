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

    test('generateContentRemote calls repository and returns result', () async {
      final prompt = [PromptPart.text(text: 'test')];
      when(
        () => mockRepository.generateContentRemote(
          prompt: any<List<PromptPart>>(named: 'prompt'),
          responseMimeType: any<String>(named: 'responseMimeType'),
        ),
      ).thenAnswer((_) async => 'result');
      final result = await service.generateContentRemote(prompt: prompt);
      expect(result, equals('result'));
      verify(
        () => mockRepository.generateContentRemote(prompt: prompt),
      ).called(1);
    });

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
