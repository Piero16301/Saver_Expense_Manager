import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class TotalSpentChart extends StatelessWidget {
  const TotalSpentChart({required this.data, super.key});

  final List<CategoryData> data;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(l10n.homeTotal, style: Theme.of(context).textTheme.bodyMedium),
          Text(
            AppExtensions.moneyFormat.format(
              data.fold<double>(
                0,
                (previousValue, element) => previousValue + element.value,
              ),
            ),
            style:
                Theme.of(
                  context,
                ).textTheme.titleLarge!.copyWith(
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
        ],
      ),
    );
  }
}
