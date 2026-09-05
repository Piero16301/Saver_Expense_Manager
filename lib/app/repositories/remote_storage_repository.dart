import 'dart:async';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:mime/mime.dart';
import 'package:saver_expense_manager/app/app.dart';

abstract class RemoteStorageRepository {
  Future<bool> deleteFile(String path);
  Future<String?> uploadFile(Uint8List bytes, String path);
  Future<Uint8List?> getData(String path);
  Future<String?> getDownloadURL(String path);
}

class MockRemoteStorageRepository implements RemoteStorageRepository {
  @override
  Future<bool> deleteFile(String path) async => true;

  @override
  Future<Uint8List?> getData(String path) {
    return Future.value(Uint8List(0));
  }

  @override
  Future<String?> uploadFile(Uint8List bytes, String path) {
    return Future.value(path);
  }

  @override
  Future<String?> getDownloadURL(String path) {
    return Future.value('https://example.com/$path');
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
  Future<String?> uploadFile(Uint8List bytes, String path) async {
    try {
      if (!(await AppFunctions.hasInternetConnection())) {
        return null;
      }

      final ref = _storage.ref().child(path);
      final mimeType = lookupMimeType(path);
      final metadata =
          mimeType != null ? SettableMetadata(contentType: mimeType) : null;
      await ref.putData(bytes, metadata);
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

  @override
  Future<String?> getDownloadURL(String path) async {
    try {
      final ref = _storage.ref().child(path);
      final mimeType = lookupMimeType(path);
      if (mimeType != null) {
        try {
          final meta = await ref.getMetadata();
          if (meta.contentType == null ||
              meta.contentType == 'application/octet-stream') {
            await ref.updateMetadata(SettableMetadata(contentType: mimeType));
          }
        } on Exception catch (_) {
          // Ignore metadata update error if any, proceed to get download URL
        }
      }
      return await ref.getDownloadURL();
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'RemoteStorageService getDownloadURL error',
      );
      return null;
    }
  }
}
