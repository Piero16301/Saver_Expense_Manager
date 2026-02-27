import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

class FakeTaskSnapshot extends Fake implements TaskSnapshot {}

class FakeUploadTask extends Fake implements UploadTask {
  @override
  Future<S> then<S>(
    FutureOr<S> Function(TaskSnapshot) onValue, {
    Function? onError,
  }) {
    return Future.value(FakeTaskSnapshot()).then(onValue, onError: onError);
  }
}

void main() {
  late RemoteStorageService remoteStorageService;
  late MockFirebaseStorage mockFirebaseStorage;
  late MockReference mockReference;
  late MockReference mockChildReference;

  setUp(() {
    mockFirebaseStorage = MockFirebaseStorage();
    mockReference = MockReference();
    mockChildReference = MockReference();

    when(() => mockFirebaseStorage.ref()).thenReturn(mockReference);
    when(() => mockReference.child(any())).thenReturn(mockChildReference);

    remoteStorageService = RemoteStorageService(storage: mockFirebaseStorage);
  });

  setUpAll(() {
    registerFallbackValue(File('dummy.png'));
  });

  group('RemoteStorageService', () {
    test('deleteFile calls delete on reference', () async {
      when(() => mockChildReference.delete()).thenAnswer((_) async {});

      await remoteStorageService.deleteFile('path/to/file.png');

      verify(() => mockReference.child('path/to/file.png')).called(1);
      verify(() => mockChildReference.delete()).called(1);
    });

    test('uploadFile returns ref.name on success', () async {
      final fakeUploadTask = FakeUploadTask();
      when(() => mockChildReference.putFile(any()))
          .thenAnswer((_) => fakeUploadTask);
      when(() => mockChildReference.name).thenReturn('file.png');

      final result = await remoteStorageService.uploadFile(
        File('dummy.png'),
        'path/to/file.png',
      );

      if (result != null) {
        expect(result, 'file.png');
        verify(() => mockReference.child('path/to/file.png')).called(1);
        verify(() => mockChildReference.putFile(any())).called(1);
      }
    });

    test('uploadFile returns null on Exception', () async {
      when(() => mockChildReference.putFile(any()))
          .thenThrow(Exception('Upload failed'));

      final result = await remoteStorageService.uploadFile(
        File('dummy.png'),
        'path/to/file.png',
      );

      expect(result, isNull);
    });

    test('getData calls getData on reference', () async {
      final data = Uint8List.fromList([1, 2, 3]);
      when(() => mockChildReference.getData()).thenAnswer((_) async => data);

      final result = await remoteStorageService.getData('path/to/file.png');

      expect(result, data);
      verify(() => mockReference.child('path/to/file.png')).called(1);
      verify(() => mockChildReference.getData()).called(1);
    });
  });
}
