import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/global/app_extensions.dart';

void main() {
  group('HexColor Extension', () {
    test('fromHex creates correct color without leading hash', () {
      final color = HexColor.fromHex('aabbcc');
      expect(color.toARGB32(), equals(0xffaabbcc));
    });

    test('fromHex creates correct color with leading hash', () {
      final color = HexColor.fromHex('#aabbcc');
      expect(color.toARGB32(), equals(0xffaabbcc));
    });

    test('fromHex creates correct color with alpha channel', () {
      final color = HexColor.fromHex('80aabbcc');
      expect(color.toARGB32(), equals(0x80aabbcc));
    });

    test('toHex returns correct string with hash by default', () {
      const color = Color(0xffaabbcc);
      expect(color.toHex(), equals('#ffaabbcc'));
    });

    test('toHex returns correct string without hash', () {
      const color = Color(0xffaabbcc);
      expect(color.toHex(leadingHashSign: false), equals('ffaabbcc'));
    });
  });

  group('AppExtensions', () {
    test('moneyFormat formats correctly', () {
      final format = AppExtensions.moneyFormat;
      expect(format.format(1234.56), equals('1,234.56'));
    });

    test('largeDateFormat formats correctly based on locale', () {
      final date = DateTime(2023);
      final usFormat = AppExtensions.largeDateFormat('en_US');
      expect(usFormat.format(date), equals('Sun 01'));
    });
  });
}
