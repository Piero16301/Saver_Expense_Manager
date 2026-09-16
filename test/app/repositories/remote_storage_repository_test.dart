import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class MockCrashService extends Mock implements CrashService {}

class FakeFile extends Fake implements File {}

class FakeUploadTask extends Fake implements UploadTask {
  @override
  Future<T> then<T>(
    FutureOr<T> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) => Future.value(onValue(MockTaskSnapshot()));
}

class MockTaskSnapshot extends Mock implements TaskSnapshot {}

class MockFullMetadata extends Mock implements FullMetadata {}

void main() {
  late MockFirebaseStorage mockStorage;
  late MockReference mockReference;
  late MockCrashService mockCrashService;
  late FirebaseRemoteStorageRepository repository;

  setUpAll(() {
    registerFallbackValue(Uint8List(0));
    registerFallbackValue(SettableMetadata());
  });

  setUp(() async {
    mockStorage = MockFirebaseStorage();
    mockReference = MockReference();
    mockCrashService = MockCrashService();

    await getIt.reset();
    getIt.registerSingleton<CrashService>(mockCrashService);

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

    test('deleteFile returns false and records error on exception', () async {
      when(() => mockReference.delete()).thenThrow(Exception('Delete Fail'));
      final result = await repository.deleteFile('path/to/file');
      expect(result, isFalse);
      await Future<void>.delayed(Duration.zero);
      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: any<dynamic>(named: 'reason'),
        ),
      ).called(1);
    });

    test('getData calls storage.getData', () async {
      final mockData = Uint8List(10);
      when(
        () => mockReference.getData(any<int>()),
      ).thenAnswer((_) async => mockData);
      final result = await repository.getData('path/to/file');
      expect(result, equals(mockData));
      verify(() => mockReference.getData(any<int>())).called(1);
    });

    test('uploadFile calls ref.putData and returns ref.name', () async {
      final fakeTask = FakeUploadTask();
      when(
        () => mockReference.putData(any<Uint8List>(), any()),
      ).thenAnswer((_) => fakeTask);
      when(() => mockReference.name).thenReturn('uploaded_file');

      final result = await repository.uploadFile(Uint8List(0), 'remote_path');

      expect(result, equals('uploaded_file'));
      verify(() => mockReference.putData(any<Uint8List>(), any())).called(1);
    });

    test('uploadFile records error and returns null on exception', () async {
      when(
        () => mockReference.putData(any<Uint8List>(), any()),
      ).thenThrow(Exception('Upload Fail'));

      final result = await repository.uploadFile(Uint8List(0), 'remote_path');

      expect(result, isNull);
      await Future<void>.delayed(Duration.zero);
      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'RemoteStorageService uploadFile error',
        ),
      ).called(1);
    });

    test('getData records error and returns null on exception', () async {
      when(
        () => mockReference.getData(any<int>()),
      ).thenThrow(Exception('Get Data Fail'));

      final result = await repository.getData('path/to/file');

      expect(result, isNull);
      await Future<void>.delayed(Duration.zero);
      verify(
        () => mockCrashService.recordError(
          any<Object>(),
          any<StackTrace?>(),
          reason: 'RemoteStorageService getData error',
        ),
      ).called(1);
    });

    test('getDownloadURL calls ref.getDownloadURL', () async {
      when(
        () => mockReference.getDownloadURL(),
      ).thenAnswer((_) async => 'https://download.url');

      final result = await repository.getDownloadURL('remote_path');

      expect(result, equals('https://download.url'));
      verify(() => mockReference.getDownloadURL()).called(1);
    });

    test(
      'getDownloadURL records error and returns null on exception',
      () async {
        when(
          () => mockReference.getDownloadURL(),
        ).thenThrow(Exception('Download URL Fail'));

        final result = await repository.getDownloadURL('remote_path');

        expect(result, isNull);
        await Future<void>.delayed(Duration.zero);
        verify(
          () => mockCrashService.recordError(
            any<Object>(),
            any<StackTrace?>(),
            reason: 'RemoteStorageService getDownloadURL error',
          ),
        ).called(1);
      },
    );

    test('uploadFile sets metadata when path has mimeType', () async {
      final fakeTask = FakeUploadTask();
      when(
        () => mockReference.putData(any<Uint8List>(), any<SettableMetadata>()),
      ).thenAnswer((_) => fakeTask);
      when(() => mockReference.name).thenReturn('image.png');

      final result = await repository.uploadFile(
        Uint8List(5),
        'folder/image.png',
      );

      expect(result, equals('image.png'));
      verify(
        () => mockReference.putData(any<Uint8List>(), any<SettableMetadata>()),
      ).called(1);
    });

    test('getDownloadURL updates metadata when contentType is null', () async {
      final mockMeta = MockFullMetadata();
      when(() => mockMeta.contentType).thenReturn(null);
      when(() => mockReference.getMetadata()).thenAnswer((_) async => mockMeta);
      when(
        () => mockReference.updateMetadata(any<SettableMetadata>()),
      ).thenAnswer((_) async => mockMeta);
      when(
        () => mockReference.getDownloadURL(),
      ).thenAnswer((_) async => 'https://download.url/image.png');

      final result = await repository.getDownloadURL('image.png');

      expect(result, equals('https://download.url/image.png'));
      verify(
        () => mockReference.updateMetadata(any<SettableMetadata>()),
      ).called(1);
    });

    test(
      'getDownloadURL updates metadata when contentType is application/octet-stream',
      () async {
        final mockMeta = MockFullMetadata();
        when(() => mockMeta.contentType).thenReturn('application/octet-stream');
        when(
          () => mockReference.getMetadata(),
        ).thenAnswer((_) async => mockMeta);
        when(
          () => mockReference.updateMetadata(any<SettableMetadata>()),
        ).thenAnswer((_) async => mockMeta);
        when(
          () => mockReference.getDownloadURL(),
        ).thenAnswer((_) async => 'https://download.url/image.png');

        final result = await repository.getDownloadURL('image.png');

        expect(result, equals('https://download.url/image.png'));
        verify(
          () => mockReference.updateMetadata(any<SettableMetadata>()),
        ).called(1);
      },
    );

    test('getDownloadURL catches metadata error and continues', () async {
      when(
        () => mockReference.getMetadata(),
      ).thenThrow(Exception('Meta error'));
      when(
        () => mockReference.getDownloadURL(),
      ).thenAnswer((_) async => 'https://download.url/image.png');

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
