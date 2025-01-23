import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:mat_month_picker_dialog/mat_month_picker_dialog.dart';
import 'package:saver_expense_manager/app/app.dart';

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
    final language = context.select<AppCubit, String>(
      (cubit) => cubit.state.language,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: Card(
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              padding: const EdgeInsets.only(left: 10),
              onPressed: backEnabled ? onBack : null,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () async {
                  await showMonthPicker(
                    context: context,
                    initialDate: monthSelected,
                    firstDate: minDate,
                    lastDate: DateTime.now(),
                  ).then(
                    onChangeMonth,
                  );
                },
                child: Text(
                  DateFormat('MMMM yyyy', language)
                      .format(monthSelected)
                      .toUpperCase(),
                  style: Theme.of(context).textTheme.labelLarge!.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: forwardEnabled ? onForward : null,
            ),
          ],
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
