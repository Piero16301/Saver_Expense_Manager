import 'package:intl/intl.dart';
import 'package:web/web.dart' as web;

DateTime? getWebLastModified() {
  try {
    final lastModified = web.document.lastModified;
    if (lastModified.isNotEmpty) {
      return DateFormat('MM/dd/yyyy HH:mm:ss').tryParse(lastModified) ??
          DateTime.tryParse(lastModified);
    }
  } on Object catch (_) {}
  return null;
}
