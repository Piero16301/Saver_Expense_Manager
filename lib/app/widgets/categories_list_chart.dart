import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class CategoriesListChart extends StatefulWidget {
  const CategoriesListChart({
    required this.data,
    super.key,
  });

  final List<ChartData> data;

  @override
  State<CategoriesListChart> createState() => _CategoriesListChartState();
}

class _CategoriesListChartState extends State<CategoriesListChart> {
  late List<ChartData> _data;

  @override
  void initState() {
    _data = widget.data.toList()..sort((a, b) => b.value.compareTo(a.value));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            ..._data.map(
              (e) => ListTile(
                onTap: () {},
                contentPadding: const EdgeInsets.only(left: 16, right: 16),
                title: Text(
                  getCategoryName(e.category.name, l10n),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                subtitle: Text(moneyFormat.format(e.value)),
                trailing: Container(
                  width: 60,
                  decoration: BoxDecoration(
                    color: HexColor.fromHex(e.category.color).withValues(
                      alpha: 0.5,
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      '${percentage(_data.indexOf(e))}%',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                leading: Icon(getIconData(e.category.icon), size: 30),
              ),
            ),
            const SizedBox(height: 70),
          ],
        ),
      ),
    );
  }

  int percentage(int index) {
    final percentage = _data[index].value /
        _data.map((e) => e.value).reduce((a, b) => a + b) *
        100;
    return percentage.toInt();
  }
}
