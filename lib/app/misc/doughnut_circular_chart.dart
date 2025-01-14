import 'package:flutter/material.dart';
import 'package:saver_expense_manager/models/models.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoughnutCircularChart extends StatefulWidget {
  const DoughnutCircularChart({
    required this.data,
    super.key,
  });

  final List<ChartData> data;

  @override
  State<DoughnutCircularChart> createState() => _DoughnutCircularChartState();
}

class _DoughnutCircularChartState extends State<DoughnutCircularChart> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      animationDuration: 500,
      duration: 1000,
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SfCircularChart(
      legend: const Legend(
        isVisible: true,
        position: LegendPosition.bottom,
      ),
      series: _buildDoughnutSeries(),
      tooltipBehavior: _tooltipBehavior,
    );
  }

  List<DoughnutSeries<ChartData, String>> _buildDoughnutSeries() {
    return <DoughnutSeries<ChartData, String>>[
      DoughnutSeries<ChartData, String>(
        dataSource: widget.data,
        xValueMapper: (ChartData data, _) => data.name,
        yValueMapper: (ChartData data, _) => data.value,
        dataLabelMapper: (ChartData data, _) => data.name,
        animationDuration: 500,
        innerRadius: '40%',
        legendIconType: LegendIconType.diamond,
        explode: true,
        explodeIndex: 0,
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
        ),
      ),
    ];
  }
}
