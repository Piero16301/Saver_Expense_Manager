import 'dart:async';
import 'dart:typed_data';

import 'package:saver_expense_manager/app/app.dart';

class RemoteStorageService {
  RemoteStorageService({required this._remoteStorageRepository});

  final RemoteStorageRepository _remoteStorageRepository;

  Future<bool> deleteFile(String path) {
    return _remoteStorageRepository.deleteFile(path);
  }

  Future<String?> uploadFile(Uint8List bytes, String path) async {
    return await _remoteStorageRepository.uploadFile(bytes, path);
  }

  Future<Uint8List?> getData(String path) async {
    return await _remoteStorageRepository.getData(path);
  }
}
