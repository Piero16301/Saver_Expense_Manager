import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/linear_chart_data.dart';

void main() {
  group('LinearChartData', () {
    const linearChartData = LinearChartData(
      xValue: 'Jan',
      yValue: 100,
    );

    test('supports value comparisons', () {
      expect(
        const LinearChartData(xValue: 'Jan', yValue: 100),
        const LinearChartData(xValue: 'Jan', yValue: 100),
      );
    });

    test('props are correct', () {
      expect(
        linearChartData.props,
        equals(['Jan', 100.0]),
      );
    });

    group('fromJson', () {
      test('returns correct object from valid json', () {
        final json = {
          'xValue': 'Jan',
          'yValue': 100.0,
        };
        expect(LinearChartData.fromJson(json), linearChartData);
      });

      test('returns default object when json is empty', () {
        final instance = LinearChartData.fromJson(const {});
        expect(instance.xValue, '');
        expect(instance.yValue, 0.0);
      });

      test('handles null values correctly', () {
        final json = {
          'xValue': null,
          'yValue': null,
        };
        final instance = LinearChartData.fromJson(json);
        expect(instance.xValue, '');
        expect(instance.yValue, 0.0);
      });

      test('handles int value correctly for yValue', () {
        final json = {
          'xValue': 'Feb',
          'yValue': 200,
        };
        final instance = LinearChartData.fromJson(json);
        expect(instance.xValue, 'Feb');
        expect(instance.yValue, 200.0);
      });
    });

    group('toJson', () {
      test('returns correct map', () {
        expect(
          linearChartData.toJson(),
          {
            'xValue': 'Jan',
            'yValue': 100.0,
          },
        );
      });
    });
  });
}
