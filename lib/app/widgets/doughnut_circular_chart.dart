import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:user_api/user_api.dart';

class DoughnutCircularChart extends StatefulWidget {
  const DoughnutCircularChart({
    required this.data,
    this.explodeIndex = 0,
    this.onPointTap,
    super.key,
  });

  final List<ChartData> data;
  final int explodeIndex;
  final void Function(ChartPointDetails)? onPointTap;

  @override
  State<DoughnutCircularChart> createState() => _DoughnutCircularChartState();
}

class _DoughnutCircularChartState extends State<DoughnutCircularChart> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return SfCircularChart(
      series: _buildDoughnutSeries(l10n),
      annotations: [
        CircularChartAnnotation(
          height: '90%',
          width: '90%',
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                getCategoryName(
                  widget.data[widget.explodeIndex].category.name,
                  l10n,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                moneyFormat.format(widget.data[widget.explodeIndex].value),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${_percentage.toInt()}%',
                style: Theme.of(context).textTheme.titleMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: () {},
                  child: Text(
                    l10n.homeDetails,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  double get _percentage {
    return widget.data[widget.explodeIndex].value /
        widget.data.map((e) => e.value).reduce((a, b) => a + b) *
        100;
  }

  List<DoughnutSeries<ChartData, String>> _buildDoughnutSeries(
    AppLocalizations l10n,
  ) {
    return <DoughnutSeries<ChartData, String>>[
      DoughnutSeries<ChartData, String>(
        dataSource: widget.data,
        xValueMapper: (ChartData data, _) =>
            getCategoryName(data.category.name, l10n),
        yValueMapper: (ChartData data, _) => data.value,
        dataLabelMapper: (ChartData data, _) => null,
        animationDuration: 500,
        innerRadius: '60%',
        radius: '95%',
        legendIconType: LegendIconType.circle,
        explode: true,
        explodeIndex: widget.explodeIndex,
        onPointTap: widget.onPointTap,
        pointColorMapper: (data, index) =>
            HexColor.fromHex(data.category.color),
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
        ),
      ),
    ];
  }
}
