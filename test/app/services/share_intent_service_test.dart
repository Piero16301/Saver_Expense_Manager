import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockShareIntentRepo extends Mock implements ShareIntentRepository;

void main() {
  late MockShareIntentRepo mockRepo;
  late ShareIntentService service;

  setUp(() {
    mockRepo = MockShareIntentRepo();
    service = ShareIntentService(shareIntentRepository: mockRepo);
  });

  group('ShareIntentService', () {
    test('delegates initialize to repository', () async {
      when(() => mockRepo.initialize()).thenAnswer((_) async {});

      await service.initialize();

      verify(() => mockRepo.initialize()).called(1);
    });

    test('delegates consumePendingSharedFile to repository', () {
      const file = SharedFile(
        path: '/tmp/receipt.pdf',
        name: 'receipt.pdf',
        movementType: CategoryType.expense,
      );
      when(() => mockRepo.consumePendingSharedFile()).thenReturn(file);

      expect(service.consumePendingSharedFile(), equals(file));
      verify(() => mockRepo.consumePendingSharedFile()).called(1);
    });

    test('delegates sharedFileStream to repository', () async {
      final controller = StreamController<SharedFile>.broadcast();
      when(() => mockRepo.sharedFileStream)
          .thenAnswer((_) => controller.stream);

      expect(service.sharedFileStream, equals(controller.stream));
      await controller.close();
    });

    test('delegates dispose to repository', () async {
      when(() => mockRepo.dispose()).thenAnswer((_) async {});

      await service.dispose();

      verify(() => mockRepo.dispose()).called(1);
    });
  });
}
