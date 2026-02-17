import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/global/app_extensions.dart';

void main() {
  group('HexColor', () {
    group('fromHex', () {
      test('returns correct color from 6-digit hex string', () {
        final color = HexColor.fromHex('aabbcc');
        expect(color.toARGB32(), const Color(0xffaabbcc).toARGB32());
      });

      test('returns correct color from 7-digit hex string with #', () {
        final color = HexColor.fromHex('#aabbcc');
        expect(color.toARGB32(), const Color(0xffaabbcc).toARGB32());
      });

      test('returns correct color from 8-digit hex string', () {
        final color = HexColor.fromHex('ffaabbcc');
        expect(color.toARGB32(), const Color(0xffaabbcc).toARGB32());
      });

      test('returns correct color from 9-digit hex string with #', () {
        final color = HexColor.fromHex('#ffaabbcc');
        expect(color.toARGB32(), const Color(0xffaabbcc).toARGB32());
      });
    });

    group('toHex', () {
      test('returns correct hex string with leading hash by default', () {
        const color = Color(0xffaabbcc);
        expect(color.toHex(), '#ffaabbcc');
      });

      test(
          'returns correct hex string without leading hash when leadingHashSign'
          ' is false', () {
        const color = Color(0xffaabbcc);
        expect(color.toHex(leadingHashSign: false), 'ffaabbcc');
      });

      test('handles transparency correctly', () {
        const color = Color(0x00aabbcc);
        expect(color.toHex(), '#00aabbcc');
      });
    });
  });

  group('AppExtensions', () {
    test('moneyFormat formats numbers correctly', () {
      final formatter = AppExtensions.moneyFormat;
      expect(formatter.format(123456.78), '123,456.78');
      expect(formatter.format(0), '0.00');
      expect(formatter.format(100), '100.00');
    });

    test('largeDateFormat formats date correctly with language', () {
      final date = DateTime(2023, 10, 25);
      final formatterEn = AppExtensions.largeDateFormat('en_US');
      expect(formatterEn.format(date), 'Wed 25');
    });
  });
}
