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
  static final Uint8List _samplePngBytes = Uint8List.fromList([
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, // PNG signature
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, // IHDR chunk
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, // 1x1
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89,
    0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, // IDAT chunk
    0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01,
    0x0D, 0x0A, 0x2D, 0xB4,
    0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, // IEND chunk
    0xAE, 0x42, 0x60, 0x82,
  ]);

  final Map<String, Uint8List> _files = {
    '1/mock_receipt_metro.png': _samplePngBytes,
  };

  @override
  Future<bool> deleteFile(String path) async {
    _files.remove(path);
    return true;
  }

  @override
  Future<Uint8List?> getData(String path) async {
    return _files[path] ?? Uint8List(0);
  }

  @override
  Future<String?> uploadFile(Uint8List bytes, String path) async {
    _files[path] = Uint8List.fromList(bytes);
    return path;
  }

  @override
  Future<String?> getDownloadURL(String path) async {
    return 'https://example.com/$path';
  }
}

class FirebaseRemoteStorageRepository implements RemoteStorageRepository {
  new({FirebaseStorage? storage})
    : _storage = storage ?? FirebaseStorage.instance;

  final FirebaseStorage _storage;

  @override
  Future<bool> deleteFile(String path) async {
    await _storage
        .ref()
        .child(path)
        .delete()
        .timeout(AppVariables.timeoutDuration);
    return true;
  }

  @override
  Future<String?> uploadFile(Uint8List bytes, String path) async {
    if (!(await AppFunctions.hasInternetConnection())) {
      return null;
    }

    final ref = _storage.ref().child(path);
    final mimeType = lookupMimeType(path, headerBytes: bytes);
    final metadata = mimeType != null
        ? SettableMetadata(contentType: mimeType)
        : null;
    final uploadTask = ref.putData(bytes, metadata);
    await (() async => await uploadTask)().timeout(
      AppVariables.storageTimeoutDuration,
      onTimeout: () {
        try {
          unawaited(uploadTask.cancel());
        } on Object catch (_) {}
        throw TimeoutException('Upload timed out');
      },
    );
    return ref.fullPath;
  }

  @override
  Future<Uint8List?> getData(String path) {
    return _storage
        .ref()
        .child(path)
        .getData()
        .timeout(AppVariables.storageTimeoutDuration);
  }

  @override
  Future<String?> getDownloadURL(String path) async {
    final ref = _storage.ref().child(path);
    final mimeType = lookupMimeType(path);
    if (mimeType != null) {
      try {
        final meta = await ref.getMetadata().timeout(
          AppVariables.timeoutDuration,
        );
        if (meta.contentType == null ||
            meta.contentType == 'application/octet-stream') {
          await ref
              .updateMetadata(SettableMetadata(contentType: mimeType))
              .timeout(AppVariables.timeoutDuration);
        }
      } on Object catch (_) {
        // Ignore metadata update error if any, proceed to get download URL
      }
    }
    return await ref.getDownloadURL().timeout(AppVariables.timeoutDuration);
  }
}
