import 'package:flutter/material.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/movements_home/movements_home.dart';
import 'package:user_api/user_api.dart';

class MovementsHomeView extends StatelessWidget {
  const MovementsHomeView({
    required this.categories,
    required this.movementsShowType,
    super.key,
  });

  final List<Category> categories;
  final MovementsShowType movementsShowType;

  @override
  Widget build(BuildContext context) {
    switch (movementsShowType) {
      case MovementsShowType.list:
        return MovementsListType(categories: categories);
      case MovementsShowType.chart:
        return MovementsChartType(categories: categories);
    }
  }
}
