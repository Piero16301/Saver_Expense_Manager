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
  });
}
