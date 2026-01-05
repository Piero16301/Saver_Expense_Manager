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
    this.rangeMonths = 1,
    super.key,
  });

  final DateTime startMonth;
  final DateTime endMonth;
  final void Function(DateTime?) onChangeStartMonth;
  final void Function(DateTime?) onChangeEndMonth;
  final int rangeMonths;

  @override
  Widget build(BuildContext context) {
    final language = context.select<AppCubit, String>(
      (cubit) => cubit.state.language,
    );

    return Row(
      children: [
        SizedBox(
          height: 40,
          width: 110,
          child: Card(
            margin: EdgeInsets.zero,
            child: GestureDetector(
              onTap: () async {
                await showMonthPicker(
                  context: context,
                  initialDate: startMonth,
                  firstDate: AppVariables.minDate,
                  lastDate: endMonth.copyWith(
                    month: endMonth.month - rangeMonths,
                  ),
                ).then(onChangeStartMonth);
              },
              child: Center(
                child: Text(
                  DateFormat(
                    'MMM yyyy',
                    language,
                  ).format(startMonth).toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ),
          ),
        ),
        const Expanded(
          child: HugeIcon(icon: HugeIcons.strokeRoundedCalendar03),
        ),
        SizedBox(
          height: 40,
          width: 110,
          child: Card(
            margin: EdgeInsets.zero,
            child: GestureDetector(
              onTap: () async {
                await showMonthPicker(
                  context: context,
                  initialDate: endMonth,
                  firstDate: startMonth.copyWith(
                    month: startMonth.month + rangeMonths,
                  ),
                  lastDate: DateTime.now(),
                ).then(onChangeEndMonth);
              },
              child: Center(
                child: Text(
                  DateFormat(
                    'MMM yyyy',
                    language,
                  ).format(endMonth).toUpperCase(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
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
