import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:saver_expense_manager/settings/helpers/settings_app_specs_helper.dart';

void main() {
  group('AppSpecsData', () {
    test('formats versionDisplay correctly when buildNumber is provided', () {
      final now = DateTime(2026, 9, 5, 12);
      final packageInfo = PackageInfo(
        appName: 'Saver',
        packageName: 'com.saver',
        version: '1.2.3',
        buildNumber: '42',
        updateTime: now,
      );

      final specs = AppSpecsData.fromPackageInfo(packageInfo);

      expect(specs.version, '1.2.3');
      expect(specs.buildNumber, '42');
      expect(specs.versionDisplay, '1.2.3 (42)');
      expect(specs.updateDate, now);
    });

    test(
      'formats versionDisplay without parentheses when buildNumber is empty',
      () {
        final now = DateTime(2026, 9, 5, 12);
        final packageInfo = PackageInfo(
          appName: 'Saver',
          packageName: 'com.saver',
          version: '1.0.0',
          buildNumber: '',
          installTime: now,
        );

        final specs = AppSpecsData.fromPackageInfo(packageInfo);

        expect(specs.version, '1.0.0');
        expect(specs.buildNumber, '');
        expect(specs.versionDisplay, '1.0.0');
        expect(specs.updateDate, now);
      },
    );

    test('falls back to now if times are null', () {
      final before = DateTime.now();
      final packageInfo = PackageInfo(
        appName: 'Saver',
        packageName: 'com.saver',
        version: '2.0.0',
        buildNumber: '5',
      );

      final specs = AppSpecsData.fromPackageInfo(packageInfo);
      final after = DateTime.now();

      expect(specs.version, '2.0.0');
      expect(specs.buildNumber, '5');
      expect(specs.versionDisplay, '2.0.0 (5)');
      expect(
        specs.updateDate.isAfter(before.subtract(const Duration(seconds: 1))) &&
            specs.updateDate.isBefore(after.add(const Duration(seconds: 1))),
        isTrue,
      );
    });
  });
}
