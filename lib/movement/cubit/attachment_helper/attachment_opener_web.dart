import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:web/web.dart' as web;

Future<void> openAttachment(
  String fileName, {
  required Future<Uint8List?> Function() getData,
  Future<String?> Function()? getDownloadURL,
}) async {
  final newWindow = web.window.open('about:blank', '_blank');

  try {
    String? url;
    if (getDownloadURL != null) {
      try {
        url = await getDownloadURL();
      } on Object {
        url = null;
      }
    }

    if (url != null && url.isNotEmpty) {
      if (newWindow != null) {
        newWindow.location.href = url;
      } else {
        web.window.open(url, '_blank');
      }
      return;
    }

    final data = await getData();
    if (data != null && data.isNotEmpty) {
      final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
      final blob = web.Blob(
        [data.toJS].toJS,
        web.BlobPropertyBag(type: mimeType),
      );
      final blobUrl = web.URL.createObjectURL(blob);
      if (newWindow != null) {
        newWindow.location.href = blobUrl;
      } else {
        web.window.open(blobUrl, '_blank');
      }
      unawaited(
        Future<void>.delayed(const Duration(minutes: 5)).then((_) {
          web.URL.revokeObjectURL(blobUrl);
        }),
      );
      return;
    }

    newWindow?.close();
  } on Object {
    newWindow?.close();
    rethrow;
  }
}
