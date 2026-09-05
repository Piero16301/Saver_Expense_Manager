import 'dart:typed_data';

import 'package:saver_expense_manager/movement/cubit/attachment_helper/attachment_opener_io.dart'
    if (dart.library.js_interop) 'package:saver_expense_manager/movement/cubit/attachment_helper/attachment_opener_web.dart'
    as opener;

Future<void> openAttachment(
  String fileName,
  Future<Uint8List?> Function() getData,
) async {
  await opener.openAttachment(fileName, getData);
}
