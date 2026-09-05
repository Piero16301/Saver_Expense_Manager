import 'package:package_info_plus/package_info_plus.dart';
import 'package:saver_expense_manager/settings/helpers/settings_app_specs_helper_io.dart'
    if (dart.library.js_interop) 'package:saver_expense_manager/settings/helpers/settings_app_specs_helper_web.dart'
    as helper;

class AppSpecsData {
  const AppSpecsData({
    required this.version,
    required this.buildNumber,
    required this.versionDisplay,
    required this.updateDate,
  });

  factory AppSpecsData.fromPackageInfo(PackageInfo packageInfo) {
    const buildDateEnv = String.fromEnvironment('BUILD_DATE');
    final envDate =
        buildDateEnv.isNotEmpty ? DateTime.tryParse(buildDateEnv) : null;

    final version = packageInfo.version;
    final buildNumber = packageInfo.buildNumber;
    final versionDisplay =
        buildNumber.isNotEmpty ? '$version ($buildNumber)' : version;

    final updateDate = envDate ??
        packageInfo.updateTime ??
        packageInfo.installTime ??
        helper.getWebLastModified() ??
        DateTime.now();

    return AppSpecsData(
      version: version,
      buildNumber: buildNumber,
      versionDisplay: versionDisplay,
      updateDate: updateDate,
    );
  }

  final String version;
  final String buildNumber;
  final String versionDisplay;
  final DateTime updateDate;
}
