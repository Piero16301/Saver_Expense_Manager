import 'package:flutter_test/flutter_test.dart';
import 'package:user_api/user_api.dart';

class _MockUserApi extends IUserApi {
  @override
  String? getBaseColor() => null;

  @override
  String? getTheme() => null;

  @override
  String? getLanguage() => null;

  @override
  String? getFontFamily() => null;

  @override
  Future<void> saveBaseColor({String baseColor = 'INDIGO'}) async {}

  @override
  Future<void> saveTheme({String theme = 'DARK'}) async {}

  @override
  Future<void> saveLanguage({String language = 'es_ES'}) async {}

  @override
  Future<void> saveFontFamily({String fontFamily = 'Roboto_regular'}) async {}
}

void main() {
  group('UserApi', () {
    test('can be implemented', () {
      expect(_MockUserApi(), isNotNull);
    });
  });
}
