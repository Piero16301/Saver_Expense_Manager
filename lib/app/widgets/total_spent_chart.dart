import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class TotalSpentChart extends StatelessWidget {
  const TotalSpentChart({
    required this.data,
    super.key,
  });

  final List<ChartData> data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Column(
        children: [
          Text(
            l10n.homeTotal,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          Text(
            moneyFormat.format(
              data.fold<double>(
                0,
                (previousValue, element) => previousValue + element.value,
              ),
            ),
            style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
    );
  }
}
