import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:mime/mime.dart';
import 'package:web/web.dart' as web;

Future<void> openAttachment(
  String fileName,
  Future<Uint8List?> Function() getData,
) async {
  final data = await getData();
  if (data != null && data.isNotEmpty) {
    final mimeType = lookupMimeType(fileName) ?? 'application/octet-stream';
    final blob = web.Blob(
      [data.toJS].toJS,
      web.BlobPropertyBag(type: mimeType),
    );
    final url = web.URL.createObjectURL(blob);
    web.window.open(url, '_blank');
    unawaited(
      Future<void>.delayed(const Duration(minutes: 2)).then((_) {
        web.URL.revokeObjectURL(url);
      }),
    );
  }
}
