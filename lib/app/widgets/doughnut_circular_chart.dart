import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/models/models.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class DoughnutCircularChart extends StatefulWidget {
  const DoughnutCircularChart({
    required this.data,
    required this.category,
    required this.total,
    required this.percentage,
    super.key,
  });

  final List<ChartData> data;
  final Category category;
  final double total;
  final double percentage;

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
      annotations: [
        CircularChartAnnotation(
          height: '90%',
          width: '90%',
          widget: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                widget.category.name,
                style: Theme.of(context).textTheme.labelMedium!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                moneyFormat.format(widget.total),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              Text(
                '${widget.percentage.toInt()}%',
                style: Theme.of(context).textTheme.labelSmall!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 20,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                  onPressed: () {},
                  child: Text(
                    'Detalles',
                    style: Theme.of(context).textTheme.labelMedium!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
        innerRadius: '60%',
        legendIconType: LegendIconType.diamond,
        explode: true,
        explodeIndex: 0,
        pointColorMapper: (data, index) => HexColor.fromHex(data.color),
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
        ),
      ),
    ];
  }
}
