import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/settings/helpers/settings_app_specs_helper.dart';

class SettingsAppSpecs extends StatelessWidget {
  const SettingsAppSpecs({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final specs = AppSpecsData.fromPackageInfo(snapshot.data!);

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.settingsVersionTitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      specs.versionDisplay,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontVariations: <FontVariation>[
                          ...(Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.fontVariations ??
                                  const <FontVariation>[])
                              .where((v) => v.axis != 'wght'),
                          const FontVariation('wght', 700),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n.settingsUpdateDateTitle,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    Text(
                      DateFormat('dd/MM/yyyy').format(specs.updateDate),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontVariations: <FontVariation>[
                          ...(Theme.of(
                                    context,
                                  ).textTheme.bodyMedium?.fontVariations ??
                                  const <FontVariation>[])
                              .where((v) => v.axis != 'wght'),
                          const FontVariation('wght', 700),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
