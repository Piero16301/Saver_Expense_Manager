import 'package:get_it/get_it.dart';
import 'package:saver_expense_manager/app/app.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator(Environment env) {
  getIt
    // 1. Infraestructura y Telemetría (Base de todo)
    ..registerLazySingleton<CrashService>(
      () => CrashService(
        crashRepository: ServiceFactory.getCrashRepository(env),
      ),
    )
    ..registerLazySingleton<PerformanceService>(
      () => PerformanceService(
        performanceRepository: ServiceFactory.getPerformanceRepository(env),
      ),
    )
    ..registerLazySingleton<AnalyticsService>(
      () => AnalyticsService(
        analyticsRepository: ServiceFactory.getAnalyticsRepository(env),
      ),
    )

    // 2. Configuración y Almacenamiento Local
    ..registerLazySingleton<LocalStorageService>(
      () => LocalStorageService(
        localStorageRepository: ServiceFactory.getLocalStorageRepository(env),
      ),
    )
    ..registerLazySingleton<RemoteConfigService>(
      () => RemoteConfigService(
        remoteConfigRepository: ServiceFactory.getRemoteConfigRepository(env),
      ),
    )

    // 3. Autenticación (Fundamental para servicios de datos)
    ..registerLazySingleton<AuthService>(
      () => AuthService(
        authRepository: ServiceFactory.getAuthRepository(env),
      ),
    )

    // 4. Servicios de Datos y Almacenamiento Remoto
    ..registerLazySingleton<DatabaseService>(
      () => DatabaseService(
        databaseRepository: ServiceFactory.getDatabaseRepository(env),
      ),
    )
    ..registerLazySingleton<RemoteStorageService>(
      () => RemoteStorageService(
        remoteStorageRepository: ServiceFactory.getRemoteStorageRepository(env),
      ),
    )

    // 5. Servicios de Lógica de Negocio / IA
    ..registerLazySingleton<AiService>(
      () => AiService(
        aiRepository: ServiceFactory.getAiRepository(env),
      ),
    );
}

enum Environment { mock, prod }

class ServiceFactory {
  static CrashRepository getCrashRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockCrashRepository();
      case Environment.prod:
        return CrashlyticsCrashRepository();
    }
  }

  static PerformanceRepository getPerformanceRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockPerformanceRepository();
      case Environment.prod:
        return FirebasePerformanceRepository();
    }
  }

  static AnalyticsRepository getAnalyticsRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockAnalyticsRepository();
      case Environment.prod:
        return FirebaseAnalyticsRepository();
    }
  }

  static LocalStorageRepository getLocalStorageRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockLocalStorageRepository();
      case Environment.prod:
        return SharedPrefsLocalStorageRepository();
    }
  }

  static RemoteConfigRepository getRemoteConfigRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockRemoteConfigRepository();
      case Environment.prod:
        return FirebaseRemoteConfigRepository();
    }
  }

  static AuthRepository getAuthRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockAuthRepository();
      case Environment.prod:
        return FirebaseAuthRepository();
    }
  }

  static DatabaseRepository getDatabaseRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockDatabaseRepository();
      case Environment.prod:
        return FirestoreDatabaseRepository();
    }
  }

  static RemoteStorageRepository getRemoteStorageRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockRemoteStorageRepository();
      case Environment.prod:
        return FirebaseRemoteStorageRepository();
    }
  }

  static AiRepository getAiRepository(Environment env) {
    switch (env) {
      case Environment.mock:
        return MockAiRepository();
      case Environment.prod:
        return GeminiAiRepository();
    }
  }
}
