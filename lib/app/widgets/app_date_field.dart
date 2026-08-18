import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

class AppDateField extends StatelessWidget {
  const AppDateField({
    required this.label,
    required this.initialDate,
    this.onDateChanged,
    super.key,
  });

  final String label;
  final DateTime initialDate;
  final void Function(DateTime)? onDateChanged;

  @override
  Widget build(BuildContext context) {
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );

    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
        prefixIcon: IconButton(
          icon: const HugeIcon(icon: HugeIcons.strokeRoundedCalendar01),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: AppVariables.minDate,
              lastDate: DateTime.now(),
            );
            if (date != null) {
              onDateChanged?.call(date);
            }
          },
        ),
      ),
      readOnly: true,
      controller: TextEditingController(
        text: DateFormat.yMMMMd(language.toString()).format(initialDate),
      ),
    );
  }
}
