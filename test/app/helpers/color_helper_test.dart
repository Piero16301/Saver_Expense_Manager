import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/helpers/color_helper.dart';

void main() {
  group('ColorHelper', () {
    test('getColorByName returns correct color for valid uppercase names', () {
      expect(ColorHelper.getColorByName('RED'), Colors.red);
      expect(ColorHelper.getColorByName('BLUE'), Colors.blue);
      expect(ColorHelper.getColorByName('GREEN'), Colors.green);
      expect(ColorHelper.getColorByName('YELLOW'), Colors.yellow);
      expect(ColorHelper.getColorByName('DEEP_PURPLE'), Colors.deepPurple);
      expect(ColorHelper.getColorByName('BLUE_GREY'), Colors.blueGrey);
    });

    test(
        'getColorByName returns correct color for valid lowercase or '
        'mixed-case names', () {
      expect(ColorHelper.getColorByName('red'), Colors.red);
      expect(ColorHelper.getColorByName('Blue'), Colors.blue);
      expect(ColorHelper.getColorByName('gReEn'), Colors.green);
      expect(ColorHelper.getColorByName('deep_purple'), Colors.deepPurple);
    });

    test('getColorByName returns default color (Indigo) for invalid names', () {
      expect(ColorHelper.getColorByName('NON_EXISTENT_COLOR'), Colors.indigo);
      expect(
        ColorHelper.getColorByName('magenta'),
        Colors.indigo,
      );
      expect(ColorHelper.getColorByName(''), Colors.indigo);
      expect(ColorHelper.getColorByName('123'), Colors.indigo);
    });
  });
}
