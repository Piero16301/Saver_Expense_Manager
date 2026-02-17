import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  setUp(() async {
    await GetIt.I.reset();
  });

  tearDown(() async {
    await GetIt.I.reset();
  });

  group('setupServiceLocator', () {
    test('registers all expected services', () {
      setupServiceLocator();

      expect(GetIt.I.isRegistered<RemoteStorageService>(), isTrue);
      expect(GetIt.I.isRegistered<AuthenticationService>(), isTrue);
      expect(GetIt.I.isRegistered<RemoteConfigService>(), isTrue);
      expect(GetIt.I.isRegistered<LocalStorageService>(), isTrue);
      expect(GetIt.I.isRegistered<AiService>(), isTrue);
    });

    test('AiService can be resolved (throws due to Firebase dependency)', () {
      setupServiceLocator();
      expect(() => GetIt.I<AiService>(), throwsA(anything));
    });
  });
}
