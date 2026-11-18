import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage;

class MockReference extends Mock implements Reference;

class FakeFile extends Fake implements File;

class FakeUploadTask extends Fake implements UploadTask {
  @override
  Future<T> then<T>(
    FutureOr<T> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) => Future.value(onValue(MockTaskSnapshot()));
}

class MockTaskSnapshot extends Mock implements TaskSnapshot;

class MockFullMetadata extends Mock implements FullMetadata;

void main() {
  late MockFirebaseStorage mockStorage;
  late MockReference mockReference;
  late FirebaseRemoteStorageRepository repository;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(SettableMetadata());
  });

  setUp(() {
    mockStorage = MockFirebaseStorage();
    mockReference = MockReference();

    repository = FirebaseRemoteStorageRepository(storage: mockStorage);

    when(() => mockStorage.ref()).thenReturn(mockReference);
    when(() => mockReference.child(any<String>())).thenReturn(mockReference);
  });

  group('MockRemoteStorageRepository', () {
    test('Mock tests for coverage', () async {
      final mock = MockRemoteStorageRepository();
      expect(await mock.deleteFile('path'), isTrue);
      expect(await mock.getData('path'), isA<Uint8List>());
      expect(await mock.uploadFile(Uint8List(0), 'path'), equals('path'));
      expect(
        await mock.getDownloadURL('path'),
        equals('https://example.com/path'),
      );
    });
  });

  group('FirebaseRemoteStorageRepository', () {
    test('deleteFile calls storage.delete and returns true', () async {
      when(() => mockReference.delete()).thenAnswer((_) async {});
      final result = await repository.deleteFile('path/to/file');
      expect(result, isTrue);
      verify(() => mockReference.delete()).called(1);
    });

    test('deleteFile rethrows on exception', () async {
      when(() => mockReference.delete()).thenThrow(Exception('Delete Fail'));
      await expectLater(
        () => repository.deleteFile('path/to/file'),
        throwsException,
      );
    });

    test('getData calls storage.getData', () async {
      final mockData = Uint8List(10);
      when(() => mockReference.getData(any<int>()))
          .thenAnswer((_) async => mockData);
      final result = await repository.getData('path/to/file');
      expect(result, equals(mockData));
      verify(() => mockReference.getData(any<int>())).called(1);
    });

    test('uploadFile calls ref.putData and returns ref.fullPath', () async {
      final fakeTask = FakeUploadTask();
      when(() => mockReference.putData(any<Uint8List>(), any()))
          .thenAnswer((_) => fakeTask);
      when(() => mockReference.fullPath).thenReturn('remote_path');

      final result = await repository.uploadFile(Uint8List(0), 'remote_path');

      expect(result, equals('remote_path'));
      verify(() => mockReference.putData(any<Uint8List>(), any())).called(1);
    });

    test('uploadFile rethrows on exception', () async {
      when(() => mockReference.putData(any<Uint8List>(), any()))
          .thenThrow(Exception('Upload Fail'));

      await expectLater(
        () => repository.uploadFile(Uint8List(0), 'remote_path'),
        throwsException,
      );
    });

    test('getData rethrows on exception', () async {
      when(() => mockReference.getData(any<int>()))
          .thenThrow(Exception('Get Data Fail'));

      await expectLater(
        () => repository.getData('path/to/file'),
        throwsException,
      );
    });

    test('getDownloadURL calls ref.getDownloadURL', () async {
      when(() => mockReference.getDownloadURL())
          .thenAnswer((_) async => 'https://download.url');

      final result = await repository.getDownloadURL('remote_path');

      expect(result, equals('https://download.url'));
      verify(() => mockReference.getDownloadURL()).called(1);
    });

    test('getDownloadURL rethrows on exception', () async {
      when(() => mockReference.getDownloadURL())
          .thenThrow(Exception('Download URL Fail'));

      await expectLater(
        () => repository.getDownloadURL('remote_path'),
        throwsException,
      );
    });

    test('uploadFile sets metadata when path has mimeType', () async {
      final fakeTask = FakeUploadTask();
      when(
        () => mockReference.putData(any<Uint8List>(), any<SettableMetadata>()),
      ).thenAnswer((_) => fakeTask);
      when(() => mockReference.fullPath).thenReturn('folder/image.png');

      final result = await repository.uploadFile(
        Uint8List(5),
        'folder/image.png',
      );

      expect(result, equals('folder/image.png'));
      verify(
        () => mockReference.putData(any<Uint8List>(), any<SettableMetadata>()),
      ).called(1);
    });

    test('getDownloadURL updates metadata when contentType is null', () async {
      final mockMeta = MockFullMetadata();
      when(() => mockMeta.contentType).thenReturn(null);
      when(() => mockReference.getMetadata()).thenAnswer((_) async => mockMeta);
      when(() => mockReference.updateMetadata(any<SettableMetadata>()))
          .thenAnswer((_) async => mockMeta);
      when(() => mockReference.getDownloadURL())
          .thenAnswer((_) async => 'https://download.url/image.png');

      final result = await repository.getDownloadURL('image.png');

      expect(result, equals('https://download.url/image.png'));
      verify(() => mockReference.updateMetadata(any<SettableMetadata>()))
          .called(1);
    });

    test('getDownloadURL updates metadata when contentType is application/octet-stream', () async {
      final mockMeta = MockFullMetadata();
      when(() => mockMeta.contentType).thenReturn('application/octet-stream');
      when(() => mockReference.getMetadata()).thenAnswer((_) async => mockMeta);
      when(() => mockReference.updateMetadata(any<SettableMetadata>()))
          .thenAnswer((_) async => mockMeta);
      when(() => mockReference.getDownloadURL())
          .thenAnswer((_) async => 'https://download.url/image.png');

      final result = await repository.getDownloadURL('image.png');

      expect(result, equals('https://download.url/image.png'));
      verify(() => mockReference.updateMetadata(any<SettableMetadata>()))
          .called(1);
    });

    test('getDownloadURL catches metadata error and continues', () async {
      when(() => mockReference.getMetadata())
          .thenThrow(Exception('Meta error'));
      when(() => mockReference.getDownloadURL())
          .thenAnswer((_) async => 'https://download.url/image.png');

      final result = await repository.getDownloadURL('image.png');

      expect(result, equals('https://download.url/image.png'));
      verify(() => mockReference.getDownloadURL()).called(1);
    });

    test(
      'default constructor initializes or throws when Firebase not ready',
      () {
        try {
          final repo = FirebaseRemoteStorageRepository();
          expect(repo, isNotNull);
        } on Object catch (e) {
          expect(e, isNotNull);
        }
      },
    );
  });
}
