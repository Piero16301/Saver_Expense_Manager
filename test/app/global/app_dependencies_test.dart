import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockAuthenticationService extends Mock implements AuthenticationService {
  @override
  FirebaseAuth get auth => MockFirebaseAuth();
}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  setUp(getIt.reset);

  group('setupServiceLocator', () {
    test('registers expected services', () {
      getIt.allowReassignment = true;
      getIt
        ..registerLazySingleton<AuthenticationService>(
          MockAuthenticationService.new,
        )
        ..registerLazySingleton<RemoteConfigService>(
          MockRemoteConfigService.new,
        );

      setupServiceLocator();

      expect(getIt.isRegistered<AuthenticationService>(), isTrue);
      expect(getIt.isRegistered<DatabaseService>(), isTrue);
      expect(getIt.isRegistered<LocalStorageService>(), isTrue);
      expect(getIt.isRegistered<RemoteStorageService>(), isTrue);
      expect(getIt.isRegistered<RemoteConfigService>(), isTrue);
      expect(getIt.isRegistered<AiService>(), isTrue);
    });
  });
}
