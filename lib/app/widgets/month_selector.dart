import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    required this.monthSelected,
    required this.onBack,
    required this.onForward,
    required this.onChangeMonth,
    super.key,
  });

  final DateTime monthSelected;
  final void Function() onBack;
  final void Function() onForward;
  final void Function(DateTime?) onChangeMonth;

  @override
  Widget build(BuildContext context) {
    final locale =
        context.select<AppCubit, Locale>((cubit) => cubit.state.locale!);
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: SizedBox(
        height: 50,
        child: Card(
          child: Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios, size: 20),
                  onPressed: backEnabled ? onBack : null,
                ),
              ),
              Expanded(
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
                        title: Text(l10n.homeSelectMonth),
                        content: SizedBox(
                          height: 300,
                          width: 300,
                          child: SfDateRangePicker(
                            minDate: minDate,
                            maxDate: DateTime.now(),
                            view: DateRangePickerView.year,
                            backgroundColor: Colors.transparent,
                            headerStyle: const DateRangePickerHeaderStyle(
                              backgroundColor: Colors.transparent,
                            ),
                            onViewChanged: (dateRangePickerViewChangedArgs) {
                              if (dateRangePickerViewChangedArgs.view ==
                                  DateRangePickerView.month) {
                                onChangeMonth(
                                  dateRangePickerViewChangedArgs
                                      .visibleDateRange.startDate,
                                );
                                Navigator.of(context).pop();
                              }
                            },
                            initialDisplayDate: monthSelected,
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    DateFormat('MMMM yyyy', locale.languageCode)
                        .format(monthSelected)
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.labelLarge!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              SizedBox.square(
                dimension: 40,
                child: IconButton(
                  icon: const Icon(Icons.arrow_forward_ios, size: 20),
                  onPressed: forwardEnabled ? onForward : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool get backEnabled {
    DateTime? previousMonth;
    if (monthSelected.month == 1) {
      previousMonth = DateTime(monthSelected.year - 1, 12);
    } else {
      previousMonth = DateTime(monthSelected.year, monthSelected.month - 1);
    }
    return previousMonth.isAfter(minDate) ||
        previousMonth.isAtSameMomentAs(minDate);
  }

  bool get forwardEnabled {
    DateTime? nextMonth;
    if (monthSelected.month == 12) {
      nextMonth = DateTime(monthSelected.year + 1);
    } else {
      nextMonth = DateTime(monthSelected.year, monthSelected.month + 1);
    }
    return nextMonth.isBefore(DateTime.now());
  }
}
