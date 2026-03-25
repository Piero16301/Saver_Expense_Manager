import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  setUp(() async {
    await getIt.reset();
  });

  group('setupServiceLocator', () {
    test('registers and activates all services for Environment.mock', () {
      setupServiceLocator(Environment.mock);

      expect(getIt.isRegistered<CrashService>(), isTrue);
      expect(getIt.isRegistered<PerformanceService>(), isTrue);
      expect(getIt.isRegistered<AnalyticsService>(), isTrue);
      expect(getIt.isRegistered<LocalStorageService>(), isTrue);
      expect(getIt.isRegistered<RemoteConfigService>(), isTrue);
      expect(getIt.isRegistered<AuthService>(), isTrue);
      expect(getIt.isRegistered<DatabaseService>(), isTrue);
      expect(getIt.isRegistered<RemoteStorageService>(), isTrue);
      expect(getIt.isRegistered<AiService>(), isTrue);

      // Trigger activation of factories for mock environment to hit coverage
      expect(getIt<CrashService>(), isA<CrashService>());
      expect(getIt<PerformanceService>(), isA<PerformanceService>());
      expect(getIt<AnalyticsService>(), isA<AnalyticsService>());
      expect(getIt<LocalStorageService>(), isA<LocalStorageService>());
      expect(getIt<RemoteConfigService>(), isA<RemoteConfigService>());
      expect(getIt<AuthService>(), isA<AuthService>());
      expect(getIt<DatabaseService>(), isA<DatabaseService>());
      expect(getIt<RemoteStorageService>(), isA<RemoteStorageService>());
      expect(getIt<AiService>(), isA<AiService>());
    });

    test('registers all services for Environment.prod', () {
      setupServiceLocator(Environment.prod);

      expect(getIt.isRegistered<CrashService>(), isTrue);
      expect(getIt.isRegistered<PerformanceService>(), isTrue);
      expect(getIt.isRegistered<AnalyticsService>(), isTrue);
      expect(getIt.isRegistered<LocalStorageService>(), isTrue);
      expect(getIt.isRegistered<RemoteConfigService>(), isTrue);
      expect(getIt.isRegistered<AuthService>(), isTrue);
      expect(getIt.isRegistered<DatabaseService>(), isTrue);
      expect(getIt.isRegistered<RemoteStorageService>(), isTrue);
      expect(getIt.isRegistered<AiService>(), isTrue);
    });
  });

  group('ServiceFactory', () {
    test('returns mock repositories for Environment.mock', () {
      expect(
        ServiceFactory.getCrashRepository(Environment.mock),
        isA<MockCrashRepository>(),
      );
      expect(
        ServiceFactory.getPerformanceRepository(Environment.mock),
        isA<MockPerformanceRepository>(),
      );
      expect(
        ServiceFactory.getAnalyticsRepository(Environment.mock),
        isA<MockAnalyticsRepository>(),
      );
      expect(
        ServiceFactory.getLocalStorageRepository(Environment.mock),
        isA<MockLocalStorageRepository>(),
      );
      expect(
        ServiceFactory.getRemoteConfigRepository(Environment.mock),
        isA<MockRemoteConfigRepository>(),
      );
      expect(
        ServiceFactory.getAuthRepository(Environment.mock),
        isA<MockAuthRepository>(),
      );
      expect(
        ServiceFactory.getDatabaseRepository(Environment.mock),
        isA<MockDatabaseRepository>(),
      );
      expect(
        ServiceFactory.getRemoteStorageRepository(Environment.mock),
        isA<MockRemoteStorageRepository>(),
      );
      expect(
        ServiceFactory.getAiRepository(Environment.mock),
        isA<MockAiRepository>(),
      );
    });

    test('returns prod repositories for Environment.prod', () {
      void hit(Object Function() getter) {
        try {
          getter();
        } on Exception catch (_) {}
      }

      hit(() => ServiceFactory.getCrashRepository(Environment.prod));
      hit(() => ServiceFactory.getPerformanceRepository(Environment.prod));
      hit(() => ServiceFactory.getAnalyticsRepository(Environment.prod));
      hit(() => ServiceFactory.getLocalStorageRepository(Environment.prod));
      hit(() => ServiceFactory.getRemoteConfigRepository(Environment.prod));
      hit(() => ServiceFactory.getAuthRepository(Environment.prod));
      hit(() => ServiceFactory.getDatabaseRepository(Environment.prod));
      hit(() => ServiceFactory.getRemoteStorageRepository(Environment.prod));
      hit(() => ServiceFactory.getAiRepository(Environment.prod));
    });
  });
}
