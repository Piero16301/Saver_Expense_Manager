import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
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
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50),
      child: SizedBox(
        child: Card(
          margin: EdgeInsets.zero,
          child: Row(
            children: [
              SizedBox.square(
                dimension: 40,
                child: IconButton(
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowLeft01,
                    size: 20,
                  ),
                  onPressed: backEnabled ? onBack : null,
                ),
              ),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () async {
                    await MonthPicker.showSingleMonthPicker(
                      context: context,
                      initialDate: monthSelected,
                      firstDate: AppVariables.minDate,
                      lastDate: DateTime.now(),
                    ).then(onChangeMonth);
                  },
                  child: Text(
                    DateFormat(
                      'MMMM yyyy',
                      language.toString(),
                    ).format(monthSelected).toUpperCase(),
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
                  icon: const HugeIcon(
                    icon: HugeIcons.strokeRoundedArrowRight01,
                    size: 20,
                  ),
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
    return previousMonth.isAfter(AppVariables.minDate) ||
        previousMonth.isAtSameMomentAs(AppVariables.minDate);
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
