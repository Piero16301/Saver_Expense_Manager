import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:saver_expense_manager/app/app.dart';

class RemoteStorageService {
  RemoteStorageService({FirebaseStorage? storage})
      : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  FirebaseStorage get storage => _storage;

  Future<void> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
    } catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'RemoteStorageService deleteFile error',
      );
      rethrow;
    }
  }

  Future<String?> uploadFile(File file, String path) async {
    try {
      if (!(await AppFunctions.hasInternetConnection())) {
        return null;
      }

      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return ref.name;
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'RemoteStorageService uploadFile error',
      );
      return null;
    }
  }

  Future<Uint8List?> getData(String path) async {
    try {
      return await _storage.ref().child(path).getData();
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'RemoteStorageService getData error',
      );
      return null;
    }
  }
}
