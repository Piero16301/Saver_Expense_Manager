import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseStorage extends Mock implements FirebaseStorage {}

class MockReference extends Mock implements Reference {}

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

  group('RemoteStorageService', () {
    test('deleteFile calls delete on reference', () async {
      when(() => mockChildReference.delete()).thenAnswer((_) async {});

      await remoteStorageService.deleteFile('path/to/file.png');

      verify(() => mockReference.child('path/to/file.png')).called(1);
      verify(() => mockChildReference.delete()).called(1);
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
