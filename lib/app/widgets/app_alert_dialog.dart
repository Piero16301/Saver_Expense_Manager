import 'package:expressive_kit/expressive_kit.dart';
import 'package:material_ui/material_ui.dart';

class AppAlertDialog extends StatelessWidget {
  const AppAlertDialog({
    required this.title,
    required this.onConfirm,
    required this.onCancel,
    required this.confirmLabel,
    required this.cancelLabel,
    this.content,
    this.child,
    this.isForm = false,
    super.key,
  });

  final String title;
  final String? content;
  final Widget? child;
  final void Function()? onConfirm;
  final void Function()? onCancel;
  final String confirmLabel;
  final String cancelLabel;
  final bool isForm;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(title, style: Theme.of(context).textTheme.titleLarge),
      content: SizedBox(
        width: isForm ? double.maxFinite : null,
        child:
            child ??
            (content != null
                ? Text(content!, style: Theme.of(context).textTheme.bodyMedium)
                : null),
      ),
      actions: [
        Row(
          spacing: 10,
          children: [
            Expanded(
              child: ExpressiveButton.outlined(
                onPressed: onCancel,
                label: cancelLabel,
              ),
            ),
            Expanded(
              child: ExpressiveButton.filled(
                onPressed: onConfirm,
                label: confirmLabel,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
