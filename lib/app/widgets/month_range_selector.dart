import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MonthRangeSelector extends StatelessWidget {
  const MonthRangeSelector({
    required this.startMonth,
    required this.endMonth,
    this.onChangeMonthRange,
    super.key,
  });

  final DateTime startMonth;
  final DateTime endMonth;
  final void Function(DateTime?, DateTime?)? onChangeMonthRange;

  @override
  Widget build(BuildContext context) {
    final locale =
        context.select<AppCubit, Locale>((cubit) => cubit.state.locale!);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.only(top: 20, right: 50, left: 50),
      child: SizedBox(
        height: 50,
        child: Card(
          child: GestureDetector(
            onTap: () async {
              await showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  contentPadding: const EdgeInsets.only(
                    left: 24,
                    top: 20,
                    right: 24,
                  ),
                  title: Text(l10n.categoryMonthRange),
                  content: SizedBox(
                    height: 300,
                    width: 300,
                    child: SfDateRangePicker(
                      minDate: minDate,
                      maxDate: DateTime.now(),
                      view: DateRangePickerView.year,
                      selectionMode: DateRangePickerSelectionMode.range,
                      initialSelectedRange: PickerDateRange(
                        startMonth,
                        endMonth,
                      ),
                    ),
                  ),
                ),
              );
            },
            child: Center(
              child: Text(
                '${DateFormat(
                  'MMM yyyy',
                  locale.languageCode,
                ).format(startMonth).toUpperCase()} - '
                '${DateFormat(
                  'MMM yyyy',
                  locale.languageCode,
                ).format(endMonth).toUpperCase()}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
