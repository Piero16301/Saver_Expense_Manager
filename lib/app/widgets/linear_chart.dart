import 'package:flutter/material.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:user_api/user_api.dart';

class LinearChart extends StatelessWidget {
  const LinearChart({
    required this.titles,
    required this.colors,
    required this.data,
    super.key,
  });

  final List<String> titles;
  final List<Color> colors;
  final List<List<LinearChartData>> data;

  @override
  Widget build(BuildContext context) {
    final maximum = data.isNotEmpty
        ? data
            .expand((list) => list)
            .map((e) => e.yValue)
            .reduce((a, b) => a > b ? a : b)
        : 10;
    final maximumRounded = (maximum / 100).ceil() * 100;

    final minimum = data.isNotEmpty
        ? data
            .expand((list) => list)
            .map((e) => e.yValue)
            .reduce((a, b) => a < b ? a : b)
        : 0;
    final minimumRounded = (minimum / 100).floor() * 100;

    final l10n = AppLocalizations.of(context);

    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(
        enable: true,
        animationDuration: 100,
        decimalPlaces: 2,
      ),
      series: _buildLineSeries(l10n),
      primaryXAxis: CategoryAxis(
        labelPlacement: LabelPlacement.onTicks,
        majorGridLines: const MajorGridLines(width: 0),
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
      ),
      primaryYAxis: NumericAxis(
        opposedPosition: true,
        minimum: minimum == minimumRounded
            ? (minimum - 100)
            : minimumRounded.toDouble(),
        maximum: maximum == maximumRounded
            ? (maximum + 100)
            : maximumRounded.toDouble(),
        labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
            ),
      ),
      trackballBehavior: TrackballBehavior(
        enable: true,
        activationMode: ActivationMode.singleTap,
      ),
    );
  }

  List<SplineSeries<LinearChartData, String>> _buildLineSeries(
    AppLocalizations l10n,
  ) {
    return data.asMap().entries.map((entry) {
      final index = entry.key;
      final seriesData = entry.value;

      return SplineSeries<LinearChartData, String>(
        splineType: SplineType.cardinal,
        dataSource: seriesData,
        width: 4,
        xValueMapper: (trend, _) => trend.xValue,
        yValueMapper: (trend, _) => trend.yValue,
        name: titles[index],
        color: colors[index].withValues(alpha: 0.7),
        animationDuration: 500,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 10,
          width: 10,
        ),
      );
    }).toList();
  }
}
