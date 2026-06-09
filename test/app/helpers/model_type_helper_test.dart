import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart' show ModelType;
import 'package:saver_expense_manager/app/helpers/model_type_helper.dart';

void main() {
  group('ModelTypeHelper', () {
    test('getModelTypeName returns correct string', () {
      expect(
        ModelTypeHelper.getModelTypeName(ModelType.local),
        equals('LOCAL'),
      );
      expect(
        ModelTypeHelper.getModelTypeName(ModelType.cloud),
        equals('CLOUD'),
      );
    });

    test(
      'getModelTypeFromString returns correct ModelType for valid string',
      () {
        expect(
          ModelTypeHelper.getModelTypeFromString('LOCAL'),
          equals(ModelType.local),
        );
        expect(
          ModelTypeHelper.getModelTypeFromString('local'),
          equals(ModelType.local),
        );
        expect(
          ModelTypeHelper.getModelTypeFromString('CLOUD'),
          equals(ModelType.cloud),
        );
      },
    );

    test('getModelTypeFromString returns default local for invalid string', () {
      expect(
        ModelTypeHelper.getModelTypeFromString('INVALID'),
        equals(ModelType.local),
      );
    });
  });
}
