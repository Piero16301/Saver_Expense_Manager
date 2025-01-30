import 'package:flutter/material.dart';
import 'package:saver_expense_manager/models/models.dart';

class CategoriesListChart extends StatelessWidget {
  const CategoriesListChart({
    required this.data,
    super.key,
  });

  final List<ChartData> data;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: data
              .map(
                (e) => ListTile(
                  title: Text(e.name),
                  trailing: Text('\$${e.value.toStringAsFixed(2)}'),
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
