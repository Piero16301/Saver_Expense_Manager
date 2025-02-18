import 'package:flutter/material.dart';

class AppDropdownField<T> extends StatelessWidget {
  const AppDropdownField({
    required this.label,
    required this.options,
    this.selected,
    this.leadingIcon,
    this.onSelected,
    super.key,
  });

  final String label;
  final List<DropdownMenuEntry<T>> options;
  final T? selected;
  final IconData? leadingIcon;
  final void Function(T?)? onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: DropdownMenu<T>(
            width: double.infinity,
            menuHeight: 300,
            menuStyle: const MenuStyle(
              padding: WidgetStatePropertyAll(EdgeInsets.all(10)),
            ),
            label: Text(label),
            leadingIcon: leadingIcon == null ? null : Icon(leadingIcon),
            initialSelection: selected,
            onSelected: onSelected,
            dropdownMenuEntries: options,
          ),
        ),
      ],
    );
  }
}
