import 'dart:async';
import 'dart:typed_data';

import 'package:saver_expense_manager/app/app.dart';

class RemoteStorageService {
  new({required this._remoteStorageRepository});

  final RemoteStorageRepository _remoteStorageRepository;

  Future<T> _runTraced<T>({
    required String traceName,
    required String errorReason,
    required T fallback,
    required Future<T> Function() action,
  }) async {
    final performance = getIt<PerformanceService>();
    final trace = performance.startTrace(traceName);
    try {
      return await action();
    } on Object catch (e, stackTrace) {
      getIt<CrashService>().recordError(e, stackTrace, reason: errorReason);
      return fallback;
    } finally {
      performance.stopTrace(trace);
    }
  }

  Future<bool> deleteFile(String path) {
    return _runTraced(
      traceName: 'storage_delete_file',
      errorReason: 'RemoteStorageService deleteFile error',
      fallback: false,
      action: () => _remoteStorageRepository.deleteFile(path),
    );
  }

  Future<String?> uploadFile(Uint8List bytes, String path) {
    return _runTraced(
      traceName: 'storage_upload_file',
      errorReason: 'RemoteStorageService uploadFile error',
      fallback: null,
      action: () => _remoteStorageRepository.uploadFile(bytes, path),
    );
  }

  Future<Uint8List?> getData(String path) {
    return _runTraced(
      traceName: 'storage_get_data',
      errorReason: 'RemoteStorageService getData error',
      fallback: null,
      action: () => _remoteStorageRepository.getData(path),
    );
  }

  Future<String?> getDownloadURL(String path) {
    return _runTraced(
      traceName: 'storage_get_download_url',
      errorReason: 'RemoteStorageService getDownloadURL error',
      fallback: null,
      action: () => _remoteStorageRepository.getDownloadURL(path),
    );
  }
}
