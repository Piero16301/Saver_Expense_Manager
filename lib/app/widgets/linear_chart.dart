import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:user_api/user_api.dart';

class LinearChart extends StatelessWidget {
  const LinearChart({
    required this.category,
    required this.data,
    super.key,
  });

  final Category category;
  final List<TrendData> data;

  @override
  Widget build(BuildContext context) {
    final maximum = data.map((e) => e.value).reduce((a, b) => a > b ? a : b);
    final maximumRounded = (maximum / 100).ceil() * 100;

    return Expanded(
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: SizedBox(
          width: 50 + (data.length * 70).toDouble(),
          child: SfCartesianChart(
            tooltipBehavior: TooltipBehavior(
              enable: true,
              animationDuration: 100,
              decimalPlaces: 2,
              opacity: 0.7,
            ),
            series: _buildLineSeries(),
            primaryXAxis: const CategoryAxis(
              labelPlacement: LabelPlacement.onTicks,
              majorGridLines: MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              minimum: 0,
              maximum: maximum == maximumRounded
                  ? (maximum + 100)
                  : maximumRounded.toDouble(),
            ),
          ),
        ),
      ),
    );
  }

  List<SplineSeries<TrendData, String>> _buildLineSeries() {
    return <SplineSeries<TrendData, String>>[
      SplineSeries<TrendData, String>(
        dataSource: data,
        xValueMapper: (TrendData trend, _) => trend.month,
        yValueMapper: (TrendData trend, _) => trend.value,
        color: HexColor.fromHex(category.color),
        animationDuration: 500,
        markerSettings: const MarkerSettings(isVisible: true),
      ),
    ];
  }
}
