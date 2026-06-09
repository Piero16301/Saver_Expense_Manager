import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class FakeFile extends Fake implements File {}

class MockRemoteStorageRepository extends Mock
    implements RemoteStorageRepository {}

void main() {
  late RemoteStorageService service;
  late MockRemoteStorageRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  setUp(() {
    mockRepository = MockRemoteStorageRepository();
    service = RemoteStorageService(remoteStorageRepository: mockRepository);
  });

  group('RemoteStorageService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });

    test('deleteFile calls repository', () async {
      when(
        () => mockRepository.deleteFile(any<String>()),
      ).thenAnswer((_) async => true);
      final result = await service.deleteFile('path');
      expect(result, isTrue);
      verify(() => mockRepository.deleteFile('path')).called(1);
    });

    test('uploadFile calls repository', () async {
      final file = FakeFile();
      when(
        () => mockRepository.uploadFile(any<File>(), any<String>()),
      ).thenAnswer((_) async => 'url');
      final result = await service.uploadFile(file, 'path');
      expect(result, equals('url'));
      verify(() => mockRepository.uploadFile(file, 'path')).called(1);
    });

    test('getData calls repository', () async {
      final data = Uint8List(0);
      when(
        () => mockRepository.getData(any<String>()),
      ).thenAnswer((_) async => data);
      final result = await service.getData('path');
      expect(result, equals(data));
      verify(() => mockRepository.getData('path')).called(1);
    });
  });
}
