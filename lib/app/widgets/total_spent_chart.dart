import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class TotalSpentChart extends StatelessWidget {
  const TotalSpentChart({required this.data, super.key});

  final List<CategoryData> data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final totalValue = data.fold<double>(
      0,
      (previousValue, element) => previousValue + element.value,
    );

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.homeTotal, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            AppExtensions.moneyFormat.format(totalValue),
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
              fontVariations: <FontVariation>[
                ...(Theme.of(context).textTheme.titleLarge?.fontVariations ??
                        const <FontVariation>[])
                    .where((v) => v.axis != 'wght'),
                const FontVariation('wght', 700),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
