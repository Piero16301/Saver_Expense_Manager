import 'package:get_it/get_it.dart';
import 'package:saver_expense_manager/app/app.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt
    ..registerLazySingleton<StorageService>(StorageService.new)
    ..registerLazySingleton<AuthenticationService>(AuthenticationService.new)
    ..registerLazySingleton<RemoteConfigService>(RemoteConfigService.new)
    ..registerLazySingleton<AiService>(
      () => AiService(remoteConfig: getIt<RemoteConfigService>()),
    );
}
