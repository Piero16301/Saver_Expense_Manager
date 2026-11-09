import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/bootstrap.dart';
import 'package:saver_expense_manager/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  const currentEnv = Environment.prod;

  // Setup service locator
  setupServiceLocator(currentEnv);

  const appCheckDebugToken = String.fromEnvironment('APP_CHECK_DEBUG_TOKEN');
  final debugToken = appCheckDebugToken.isEmpty ? null : appCheckDebugToken;

  // Initialize services and plugins in parallel
  final performance = getIt<PerformanceService>();
  final trace = performance.startTrace('app_initialization');
  await Future.wait([
    () async {
      try {
        await FirebaseAppCheck.instance
            .activate(
              providerWeb: kDebugMode
                  ? WebDebugProvider(debugToken: debugToken)
                  : ReCaptchaEnterpriseProvider(
                      DefaultFirebaseOptions.recaptchaEnterpriseSiteKey,
                    ),
              providerAndroid: kDebugMode
                  ? AndroidDebugProvider(debugToken: debugToken)
                  : const AndroidPlayIntegrityProvider(),
              providerApple: kDebugMode
                  ? AppleDebugProvider(debugToken: debugToken)
                  : const AppleDeviceCheckProvider(),
            )
            .timeout(AppVariables.timeoutDuration);
      } on Object catch (e, stackTrace) {
        getIt<CrashService>().recordError(
          e,
          stackTrace,
          reason: 'FirebaseAppCheck activate error',
        );
      }
    }(),
    getIt<AuthService>().initialize(),
    getIt<LocalStorageService>().initialize(),
    getIt<RemoteConfigService>().initialize(),
    getIt<AiService>().initialize(),
  ]);
  performance.stopTrace(trace);

  // Bootstrap the app
  await bootstrap(() => const AppPage());
}
