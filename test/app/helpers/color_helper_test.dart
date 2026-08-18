import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/helpers/color_helper.dart';

void main() {
  group('ColorHelper', () {
    test('getColorByName returns correct color for valid name', () {
      expect(ColorHelper.getColorByName('RED'), equals(Colors.red));
      expect(ColorHelper.getColorByName('red'), equals(Colors.red));
    });

    test('getColorByName returns default color (green) for invalid name', () {
      expect(ColorHelper.getColorByName('INVALID'), equals(Colors.green));
    });

    test('getColorName returns correct name for valid color', () {
      expect(ColorHelper.getColorName(Colors.blue), equals('BLUE'));
      expect(
        ColorHelper.getColorName(Colors.deepOrange),
        equals('DEEP_ORANGE'),
      );
    });

    test('getColorName throws state error for unmapped color', () {
      expect(() => ColorHelper.getColorName(Colors.black), throwsStateError);
    });
  });
}
