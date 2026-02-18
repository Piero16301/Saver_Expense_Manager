import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/global/app_variables.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppVariables', () {
    test('should have correct constants', () {
      expect(AppVariables.appName, 'Saver');
      expect(AppVariables.defaultBaseColor, Colors.green);
      expect(AppVariables.defaultFontFamily, 'Poppins');
      expect(AppVariables.allowedExtensions, ['pdf', 'png', 'jpg', 'jpeg']);
      expect(AppVariables.minDate, DateTime(2020));
      expect(AppVariables.deafultMonthsTrend, 10);
      expect(AppVariables.deafultMonthsResume, 4);
      expect(AppVariables.maxDaysWarning, 7);
      expect(AppVariables.expensesTab, 'gastos');
      expect(AppVariables.movementsTab, 'movimientos');
      expect(AppVariables.summaryTab, 'resumen');
      expect(AppVariables.incomesTab, 'ingresos');
      expect(AppVariables.googleProvider, 'google.com');
      expect(AppVariables.emailProvider, 'password');
    });

    test('should have correct regex patterns', () {
      final emailRegExp = RegExp(AppVariables.emailRegExp);
      final passwordRegExp = RegExp(AppVariables.passwordRegExp);

      expect(emailRegExp.hasMatch('test@example.com'), isTrue);
      expect(emailRegExp.hasMatch('invalid-email'), isFalse);

      expect(passwordRegExp.hasMatch('Password123'), isTrue);
      expect(passwordRegExp.hasMatch('pass'), isFalse);
    });

    test('should have correct colors', () {
      expect(AppVariables.incomeColor, Colors.blueAccent);
      expect(AppVariables.balanceColor, Colors.teal);
      expect(AppVariables.expenseColor, Colors.orangeAccent);
      expect(AppVariables.growthColor, Colors.green);
      expect(AppVariables.decreaseColor, Colors.redAccent);
    });

    test('should have correct collection names', () {
      expect(AppVariables.categoriesCollection, 'categories');
      expect(AppVariables.movementsCollection, 'movements');
      expect(AppVariables.usersCollection, 'users');
    });
  });

  group('SnackBarType Enum', () {
    test('isSuccess should return correct boolean', () {
      expect(SnackBarType.success.isSuccess, isTrue);
      expect(SnackBarType.error.isSuccess, isFalse);
      expect(SnackBarType.warning.isSuccess, isFalse);
      expect(SnackBarType.info.isSuccess, isFalse);
    });

    test('isError should return correct boolean', () {
      expect(SnackBarType.success.isError, isFalse);
      expect(SnackBarType.error.isError, isTrue);
      expect(SnackBarType.warning.isError, isFalse);
      expect(SnackBarType.info.isError, isFalse);
    });

    test('isWarning should return correct boolean', () {
      expect(SnackBarType.success.isWarning, isFalse);
      expect(SnackBarType.error.isWarning, isFalse);
      expect(SnackBarType.warning.isWarning, isTrue);
      expect(SnackBarType.info.isWarning, isFalse);
    });

    test('isInfo should return correct boolean', () {
      expect(SnackBarType.success.isInfo, isFalse);
      expect(SnackBarType.error.isInfo, isFalse);
      expect(SnackBarType.warning.isInfo, isFalse);
      expect(SnackBarType.info.isInfo, isTrue);
    });
  });

  group('ModelType Enum', () {
    test('isCloud should return correct boolean', () {
      expect(ModelType.cloud.isCloud, isTrue);
      expect(ModelType.local.isCloud, isFalse);
    });

    test('isLocal should return correct boolean', () {
      expect(ModelType.cloud.isLocal, isFalse);
      expect(ModelType.local.isLocal, isTrue);
    });

    test('name should return correct string', () {
      expect(ModelType.cloud.name, 'CLOUD');
      expect(ModelType.local.name, 'LOCAL');
    });

    test('fromName should return correct enum value', () {
      expect(ModelType.fromName('CLOUD'), ModelType.cloud);
      expect(ModelType.fromName('LOCAL'), ModelType.local);
      expect(ModelType.fromName('UNKNOWN'), ModelType.cloud);
      expect(ModelType.fromName(''), ModelType.cloud);
    });
  });
}
