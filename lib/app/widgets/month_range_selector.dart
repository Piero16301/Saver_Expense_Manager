import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:saver_expense_manager/app/app.dart';

class MonthRangeSelector extends StatelessWidget {
  const MonthRangeSelector({
    required this.startMonth,
    required this.endMonth,
    required this.onChangeStartMonth,
    required this.onChangeEndMonth,
    super.key,
  });

  final DateTime startMonth;
  final DateTime endMonth;
  final void Function(DateTime?) onChangeStartMonth;
  final void Function(DateTime?) onChangeEndMonth;

  @override
  Widget build(BuildContext context) {
    final language = context.select<AppCubit, String>(
      (cubit) => cubit.state.language,
    );

    return Row(
      children: [
        SizedBox(
          height: 40,
          width: 130,
          child: Card(
            child: GestureDetector(
              onTap: () async {
                await showMonthPicker(
                  context: context,
                  initialDate: startMonth,
                  firstDate: AppVariables.minDate,
                  lastDate: endMonth.copyWith(month: endMonth.month - 1),
                ).then(onChangeStartMonth);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Text(
                    DateFormat(
                      'MMM yyyy',
                      language.split('_').first,
                    ).format(startMonth).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        const Expanded(
          child: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03, size: 30),
        ),
        SizedBox(
          height: 40,
          width: 130,
          child: Card(
            child: GestureDetector(
              onTap: () async {
                await showMonthPicker(
                  context: context,
                  initialDate: endMonth,
                  firstDate: startMonth.copyWith(month: startMonth.month + 1),
                  lastDate: DateTime.now(),
                ).then(onChangeEndMonth);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Center(
                  child: Text(
                    DateFormat(
                      'MMM yyyy',
                      language.split('_').first,
                    ).format(endMonth).toUpperCase(),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
