import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

class MonthSelector extends StatelessWidget {
  const MonthSelector({
    required this.monthSelected,
    required this.onBack,
    required this.onForward,
    required this.onChangeMonth,
    this.padding = EdgeInsets.zero,
    super.key,
  });

  final DateTime monthSelected;
  final void Function() onBack;
  final void Function() onForward;
  final void Function(DateTime?) onChangeMonth;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );

    return Padding(
      padding: padding,
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4),
              child: ExpressiveIconButton.circle(
                size: ExpressiveIconButtonSize.small,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedArrowLeft01,
                  size: 20,
                ),
                onPressed: backEnabled ? onBack : null,
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () async {
                await MonthPicker.showSingleMonthPicker(
                  context: context,
                  initialDate: monthSelected,
                  firstDate: AppVariables.minDate,
                  lastDate: DateTime.now(),
                ).then(onChangeMonth);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    DateFormat(
                      'MMM yyyy',
                      language.toString(),
                    ).format(monthSelected).capitalize(),
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 4),
              child: ExpressiveIconButton.circle(
                size: ExpressiveIconButtonSize.small,
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
