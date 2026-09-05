import 'package:material_ui/material_ui.dart';

class AppFilledButton extends StatelessWidget {
  const AppFilledButton({
    this.onPressed,
    this.icon,
    this.label,
    this.innerPadding,
    this.color,
    this.isOnlyIcon = false,
    this.visualDensity,
    super.key,
  });

  final void Function()? onPressed;
  final Widget? icon;
  final String? label;
  final EdgeInsetsGeometry? innerPadding;
  final Color? color;
  final bool isOnlyIcon;
  final VisualDensity? visualDensity;

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        visualDensity: visualDensity ?? VisualDensity.standard,
        backgroundColor: color,
        padding: innerPadding ?? const EdgeInsets.all(12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      icon: icon != null && !isOnlyIcon ? icon : null,
      label: label != null
          ? Text(
              label ?? '',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: onPressed == null
                    ? Theme.of(
                        context,
                      ).colorScheme.onSurface.withValues(alpha: 0.38)
                    : Theme.of(context).colorScheme.onPrimary,
                fontVariations: <FontVariation>[
                  ...(Theme.of(context).textTheme.titleMedium?.fontVariations ??
                          const <FontVariation>[])
                      .where((v) => v.axis != 'wght'),
                  const FontVariation('wght', 700),
                ],
              ),
            )
          : icon!,
    );
  }
}
