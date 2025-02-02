import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
    final locale =
        context.select<AppCubit, Locale>((cubit) => cubit.state.locale!);

    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        prefixIcon: IconButton(
          icon: const Icon(Icons.calendar_today),
          onPressed: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: initialDate,
              firstDate: minDate,
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
        text: DateFormat.yMMMMd(
          '${locale.languageCode}_${locale.countryCode}',
        ).format(initialDate),
      ),
    );
  }
}
