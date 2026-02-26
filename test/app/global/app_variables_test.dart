import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/global/app_variables.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  AppVariables.useTestFonts = true;

  group('AppVariables', () {
    test('minDate is correct', () {
      expect(AppVariables.minDate, equals(DateTime(2020)));
    });

    test('formatDate formats correctly', () {
      final date = DateTime(2023, 10, 5);
      expect(AppVariables.formatDate.format(date), equals('05/10/2023'));
    });

    test('getAvailableFonts returns a non-empty string map', () {
      final fonts = AppVariables.getAvailableFonts();
      expect(fonts.isNotEmpty, isTrue);
      expect(fonts.containsKey('Roboto'), isTrue);
    });
  });

  group('SnackBarType', () {
    test('isSuccess true only for success', () {
      expect(SnackBarType.success.isSuccess, isTrue);
      expect(SnackBarType.error.isSuccess, isFalse);
    });
    test('isError true only for error', () {
      expect(SnackBarType.error.isError, isTrue);
      expect(SnackBarType.info.isError, isFalse);
    });
    test('isWarning true only for warning', () {
      expect(SnackBarType.warning.isWarning, isTrue);
      expect(SnackBarType.success.isWarning, isFalse);
    });
    test('isInfo true only for info', () {
      expect(SnackBarType.info.isInfo, isTrue);
      expect(SnackBarType.success.isInfo, isFalse);
    });
  });

  group('ModelType', () {
    test('isCloud returns true only for cloud', () {
      expect(ModelType.cloud.isCloud, isTrue);
      expect(ModelType.local.isCloud, isFalse);
    });

    test('isLocal returns true only for local', () {
      expect(ModelType.local.isLocal, isTrue);
      expect(ModelType.cloud.isLocal, isFalse);
    });

    test('name getter returns correct string', () {
      expect(ModelType.cloud.name, equals('CLOUD'));
      expect(ModelType.local.name, equals('LOCAL'));
    });

    test('fromName returns correct ModelType', () {
      expect(ModelType.fromName('CLOUD'), equals(ModelType.cloud));
      expect(ModelType.fromName('LOCAL'), equals(ModelType.local));
      expect(ModelType.fromName('UNKNOWN'), equals(ModelType.cloud));
    });
  });
}
