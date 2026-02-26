import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/linear_chart_data.dart';

void main() {
  group('LinearChartData', () {
    const xValue = 'Label';
    const yValue = 100.5;

    test('supports value equality', () {
      expect(
        const LinearChartData(xValue: xValue, yValue: yValue),
        equals(const LinearChartData(xValue: xValue, yValue: yValue)),
      );
    });

    group('fromJson', () {
      test('returns correct instance from fully populated map', () {
        final json = <String, dynamic>{
          'xValue': xValue,
          'yValue': yValue,
        };

        expect(
          LinearChartData.fromJson(json),
          equals(const LinearChartData(xValue: xValue, yValue: yValue)),
        );
      });

      test('returns correct instance with defaults from empty map', () {
        expect(
          LinearChartData.fromJson(const {}),
          equals(const LinearChartData(xValue: '', yValue: 0)),
        );
      });
    });

    group('toJson', () {
      test('returns correct map', () {
        const data = LinearChartData(xValue: xValue, yValue: yValue);
        expect(
          data.toJson(),
          equals({
            'xValue': xValue,
            'yValue': yValue,
          }),
        );
      });
    });
  });
}
