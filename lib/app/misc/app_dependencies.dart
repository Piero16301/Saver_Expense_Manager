import 'package:get_it/get_it.dart';
import 'package:saver_expense_manager/app/app.dart';

final GetIt getIt = GetIt.instance;

void setupServiceLocator() {
  getIt
    ..registerLazySingleton<RemoteConfigService>(RemoteConfigService.new)
    ..registerLazySingleton<AiService>(
      () => AiService(remoteConfig: getIt<RemoteConfigService>()),
    );
}
