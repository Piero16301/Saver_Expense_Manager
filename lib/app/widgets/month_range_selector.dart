import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
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
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(
          padding: const EdgeInsets.only(left: 10),
          height: 40,
          width: 110,
          child: Align(
            alignment: AlignmentGeometry.centerLeft,
            child: Text(
              _capitalizeFirst(
                DateFormat(
                  'MMM yyyy',
                  language.toString(),
                ).format(startMonth),
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
        Card(
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: IconButton(
            padding: EdgeInsets.zero,
            onPressed: () async {
              await MonthPicker.showRangeMonthPicker(
                context: context,
                initialStartDate: startMonth,
                initialEndDate: endMonth,
                firstDate: AppVariables.minDate,
                lastDate: DateTime.now(),
              ).then((value) {
                if (value != null) {
                  onChangeStartMonth(value.start);
                  onChangeEndMonth(value.end);
                }
              });
            },
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedCalendar03,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.only(right: 10),
          height: 40,
          width: 110,
          child: Align(
            alignment: AlignmentGeometry.centerRight,
            child: Text(
              _capitalizeFirst(
                DateFormat(
                  'MMM yyyy',
                  language.toString(),
                ).format(endMonth),
              ),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ),
      ],
    );
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return '${text[0].toUpperCase()}${text.substring(1)}';
  }
}
