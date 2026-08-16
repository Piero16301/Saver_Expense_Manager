import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';

extension HexColor on Color {
  /// String is in the format "aabbcc" or "ffaabbcc" with an optional
  /// leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true`
  /// (default is `true`).
  String toHex({bool leadingHashSign = true}) =>
      '${leadingHashSign ? '#' : ''}'
      '${(a * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${(r * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${(g * 255).round().toRadixString(16).padLeft(2, '0')}'
      '${(b * 255).round().toRadixString(16).padLeft(2, '0')}';
}

class AppExtensions {
  static final moneyFormat = NumberFormat('###,###,###,##0.00');

  static DateFormat largeDateFormat(String language) {
    return DateFormat('EEE dd', language);
  }
}
