import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
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
    final l10n = context.l10n;

    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.horizontal,
        controller: ScrollController(
          initialScrollOffset: 50 + (data.length * 70).toDouble(),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            SizedBox(
              width: 50 + (data.length * 70).toDouble(),
              child: SfCartesianChart(
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  animationDuration: 100,
                  decimalPlaces: 2,
                ),
                series: _buildLineSeries(l10n),
                primaryXAxis: CategoryAxis(
                  labelPlacement: LabelPlacement.onTicks,
                  majorGridLines: const MajorGridLines(width: 0),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                primaryYAxis: NumericAxis(
                  opposedPosition: true,
                  minimum: 0,
                  maximum: maximum == maximumRounded
                      ? (maximum + 100)
                      : maximumRounded.toDouble(),
                  labelStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<SplineSeries<TrendData, String>> _buildLineSeries(
    AppLocalizations l10n,
  ) {
    return <SplineSeries<TrendData, String>>[
      SplineSeries<TrendData, String>(
        dataSource: data,
        width: 5,
        splineType: SplineType.monotonic,
        xValueMapper: (TrendData trend, _) => trend.month,
        yValueMapper: (TrendData trend, _) => trend.value,
        name: getCategoryName(category.name, l10n),
        color: HexColor.fromHex(category.color).withValues(alpha: 0.7),
        animationDuration: 500,
        markerSettings: const MarkerSettings(
          isVisible: true,
          height: 10,
          width: 10,
        ),
      ),
    ];
  }
}
