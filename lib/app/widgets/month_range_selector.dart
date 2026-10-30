import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
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

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: () async {
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              spacing: 8,
              children: [
                Text(
                  DateFormat(
                    'MMM yyyy',
                    language.toString(),
                  ).format(startMonth).capitalize(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Text('-', style: Theme.of(context).textTheme.titleMedium),
                Text(
                  DateFormat(
                    'MMM yyyy',
                    language.toString(),
                  ).format(endMonth).capitalize(),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
