import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:saver_expense_manager/app/app.dart';

abstract class RemoteStorageRepository {
  Future<bool> deleteFile(String path);
  Future<String?> uploadFile(File file, String path);
  Future<Uint8List?> getData(String path);
}

class MockRemoteStorageRepository implements RemoteStorageRepository {
  @override
  Future<bool> deleteFile(String path) async => true;

  @override
  Future<Uint8List?> getData(String path) {
    return Future.value(Uint8List(0));
  }

  @override
  Future<String?> uploadFile(File file, String path) {
    return Future.value(file.path);
  }
}

class FirebaseRemoteStorageRepository implements RemoteStorageRepository {
  FirebaseRemoteStorageRepository({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<bool> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
      return true;
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'RemoteStorageService deleteFile error',
      );
      return false;
    }
  }

  @override
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

  @override
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
