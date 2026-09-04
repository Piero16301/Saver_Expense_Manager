import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:saver_expense_manager/app/app.dart';

class RemoteStorageService {
  RemoteStorageService({required this._remoteStorageRepository});

  final RemoteStorageRepository _remoteStorageRepository;

  Future<bool> deleteFile(String path) {
    return _remoteStorageRepository.deleteFile(path);
  }

  Future<String?> uploadFile(File file, String path) async {
    return await _remoteStorageRepository.uploadFile(file, path);
  }

  Future<Uint8List?> getData(String path) async {
    return await _remoteStorageRepository.getData(path);
  }
}
