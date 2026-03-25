import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late AuthService service;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    service = AuthService(authRepository: mockRepository);
  });

  group('AuthService', () {
    test('can be instantiated', () {
      expect(service, isNotNull);
    });
  });
}
