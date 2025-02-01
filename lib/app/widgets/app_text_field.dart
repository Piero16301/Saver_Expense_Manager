import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.isRequired = true,
    this.autovalidateMode = AutovalidateMode.onUserInteraction,
    this.onChanged,
    this.inputFormatters,
    this.prefix,
    this.initialValue,
    this.validator,
    super.key,
  });

  final String label;
  final bool isRequired;
  final AutovalidateMode autovalidateMode;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final Widget? prefix;
  final String? initialValue;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      autovalidateMode: autovalidateMode,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: prefix,
        border: const OutlineInputBorder(),
      ),
      initialValue: initialValue,
      validator: validator,
    );
  }
}
