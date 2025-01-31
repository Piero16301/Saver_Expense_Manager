import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:user_api/user_api.dart';

class RadialCircularChart extends StatefulWidget {
  const RadialCircularChart({
    required this.data,
    this.image,
    super.key,
  });

  final List<ChartData> data;
  final String? image;

  @override
  State<RadialCircularChart> createState() => _RadialCircularChartState();
}

class _RadialCircularChartState extends State<RadialCircularChart> {
  late TooltipBehavior _tooltipBehavior;

  @override
  void initState() {
    _tooltipBehavior = TooltipBehavior(
      enable: true,
      animationDuration: 500,
      duration: 1000,
      format: 'point.x : point.y%',
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
      series: _buildRadialSeries(),
      tooltipBehavior: _tooltipBehavior,
      annotations: [
        CircularChartAnnotation(
          height: '90%',
          width: '90%',
          widget: ClipRRect(
            borderRadius: BorderRadius.circular(60),
            child: widget.image == null
                ? const Icon(Icons.person, size: 100)
                : Image.network(
                    widget.image!,
                    fit: BoxFit.cover,
                    height: 100,
                    width: 100,
                  ),
          ),
        ),
      ],
    );
  }

  List<RadialBarSeries<ChartData, String>> _buildRadialSeries() {
    return <RadialBarSeries<ChartData, String>>[
      RadialBarSeries<ChartData, String>(
        dataSource: widget.data,
        xValueMapper: (ChartData data, _) => data.category.name,
        yValueMapper: (ChartData data, _) => data.value,
        dataLabelMapper: (ChartData data, _) => data.category.name,
        animationDuration: 500,
        maximumValue: 100,
        radius: '100%',
        cornerStyle: CornerStyle.endCurve,
        legendIconType: LegendIconType.circle,
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
