import 'dart:io';
import 'dart:typed_data';

import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';

Future<void> openAttachment(
  String fileName,
  Future<Uint8List?> Function() getData,
) async {
  final appTemDir = await getApplicationCacheDirectory();
  final filePath = '${appTemDir.path}/$fileName';
  final file = File(filePath);

  final data = await getData() ?? Uint8List(0);
  await file.writeAsBytes(data.toList());
  await OpenFile.open(filePath);
}
