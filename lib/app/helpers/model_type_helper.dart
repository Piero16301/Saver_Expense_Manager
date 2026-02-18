import 'package:saver_expense_manager/app/app.dart' show ModelType;

class ModelTypeHelper {
  static String getModelTypeName(ModelType modelType) {
    switch (modelType) {
      case ModelType.local:
        return 'LOCAL';
      case ModelType.cloud:
        return 'CLOUD';
    }
  }

  static ModelType getModelTypeFromString(String modelType) {
    switch (modelType.toUpperCase()) {
      case 'LOCAL':
        return ModelType.local;
      case 'CLOUD':
        return ModelType.cloud;
      default:
        return ModelType.local;
    }
  }
}
