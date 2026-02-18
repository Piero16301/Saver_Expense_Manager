import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

class RemoteStorageService {
  RemoteStorageService() : _storage = FirebaseStorage.instance;

  final FirebaseStorage _storage;

  FirebaseStorage get storage => _storage;

  Future<void> deleteFile(String path) async {
    await _storage.ref().child(path).delete();
  }

  Future<String?> uploadFile(File file, String path) async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) return null;

      final ref = _storage.ref().child(path);
      await ref.putFile(file);
      return ref.name;
    } on Exception catch (_) {
      return null;
    }
  }

  Future<Uint8List?> getData(String path) async {
    return _storage.ref().child(path).getData();
  }
}
