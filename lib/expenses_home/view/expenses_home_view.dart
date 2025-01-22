import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:month_picker_dialog/month_picker_dialog.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/expenses_home/expenses_home.dart';
import 'package:saver_expense_manager/models/models.dart';

class ExpensesHomeView extends StatelessWidget {
  const ExpensesHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const MonthSelector(),
        DoughnutCircularChart(
          data: const [
            ChartData(
              name: 'Transporte',
              value: 50,
              color: '#FF4285F4',
            ),
            ChartData(
              name: 'Entretenimiento',
              value: 75,
              color: 'FFEA4335',
            ),
            ChartData(
              name: 'Salud',
              value: 30,
              color: 'FFFBBC05',
            ),
            ChartData(
              name: 'Educación',
              value: 90,
              color: 'FF34A853',
            ),
            ChartData(
              name: 'Vivienda',
              value: 120,
              color: 'FF9C27B0',
            ),
          ],
          category: Category(
            id: '1',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
            name: 'Transporte',
            color: '#FF4285F4',
          ),
          total: 264981,
          percentage: 65,
        ),
      ],
    );
  }
}

class MonthSelector extends StatelessWidget {
  const MonthSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final monthSelected = context.select<ExpensesHomeCubit, DateTime?>(
      (cubit) => cubit.state.monthSelected,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Card(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              padding: const EdgeInsets.only(left: 8),
              onPressed: () => context.read<ExpensesHomeCubit>().changeMonth(
                    monthSelected!.subtract(const Duration(days: 30)),
                  ),
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => showMonthPicker(
                  context: context,
                  initialDate: DateTime.now(),
                  lastDate: DateTime.now(),
                ).then((date) {
                  if (date != null) {
                    // ignore: use_build_context_synchronously
                    context.read<ExpensesHomeCubit>().changeMonth(date);
                  }
                }),
                child: Text(
                  DateFormat('MMMM yyyy').format(monthSelected!),
                  style: Theme.of(context).textTheme.labelLarge,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () => context.read<ExpensesHomeCubit>().changeMonth(
                    monthSelected.add(const Duration(days: 30)),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
