import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

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
    final l10n = AppLocalizations.of(context);

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
                AppFunctions.getCategoryName(
                  data[selectedIndex].category.name,
                  l10n,
                ),
                style: Theme.of(context).textTheme.titleSmall,
              ),
              Text(
                AppExtensions.moneyFormat.format(data[selectedIndex].value),
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontVariations: <FontVariation>[
                    ...(Theme.of(
                              context,
                            ).textTheme.titleLarge?.fontVariations ??
                            const <FontVariation>[])
                        .where((v) => v.axis != 'wght'),
                    const FontVariation('wght', 700),
                  ],
                ),
              ),
              Text(
                '${_percentage.toInt()}%',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 5),
              SizedBox(
                height: 30,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                  ),
                  onPressed: () => context.pushNamed(
                    AppRoute.category.name,
                    extra: data[selectedIndex].category,
                  ),
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
        xValueMapper: (data, _) =>
            AppFunctions.getCategoryName(data.category.name, l10n),
        yValueMapper: (data, _) => data.value,
        dataLabelMapper: (data, _) => null,
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
