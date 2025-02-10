import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:user_api/user_api.dart';

class DoughnutCircularChart extends StatelessWidget {
  const DoughnutCircularChart({
    required this.data,
    this.selectedIndex = 0,
    this.onPointTap,
    super.key,
  });

  final List<CategoryData> data;
  final int selectedIndex;
  final void Function(ChartPointDetails)? onPointTap;

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
                  data[selectedIndex].category.name,
                  l10n,
                ),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                moneyFormat.format(data[selectedIndex].value),
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
    return data[selectedIndex].value /
        data.map((e) => e.value).reduce((a, b) => a + b) *
        100;
  }

  List<DoughnutSeries<CategoryData, String>> _buildDoughnutSeries(
    AppLocalizations l10n,
  ) {
    return <DoughnutSeries<CategoryData, String>>[
      DoughnutSeries<CategoryData, String>(
        dataSource: data,
        xValueMapper: (CategoryData data, _) =>
            getCategoryName(data.category.name, l10n),
        yValueMapper: (CategoryData data, _) => data.value,
        dataLabelMapper: (CategoryData data, _) => null,
        animationDuration: 500,
        innerRadius: '55%',
        radius: '100%',
        legendIconType: LegendIconType.circle,
        onPointTap: onPointTap,
        pointColorMapper: (data, index) {
          if (index == selectedIndex) {
            return HexColor.fromHex(data.category.color);
          } else {
            return HexColor.fromHex(data.category.color).withValues(alpha: 0.5);
          }
        },
        dataLabelSettings: const DataLabelSettings(
          isVisible: true,
          labelPosition: ChartDataLabelPosition.outside,
        ),
      ),
    ];
  }
}
