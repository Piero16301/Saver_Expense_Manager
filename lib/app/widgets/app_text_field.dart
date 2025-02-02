import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppTextField extends StatelessWidget {
  const AppTextField({
    required this.label,
    this.hintText = '',
    this.errorText = '',
    this.isRequired = true,
    this.onChanged,
    this.inputFormatters,
    this.keyboardType,
    this.prefix,
    this.initialValue,
    this.maxLines,
    this.maxLength,
    this.validator,
    super.key,
  });

  final String label;
  final String hintText;
  final String errorText;
  final bool isRequired;
  final void Function(String)? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final TextInputType? keyboardType;
  final Widget? prefix;
  final String? initialValue;
  final int? maxLines;
  final int? maxLength;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onChanged: onChanged,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      inputFormatters: inputFormatters,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        prefixIcon: prefix,
        alignLabelWithHint: true,
      ),
      maxLines: maxLines,
      maxLength: maxLength,
      initialValue: initialValue,
      validator: validator ??
          (isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return errorText;
                  }
                  return null;
                }
              : null),
    );
  }
}
