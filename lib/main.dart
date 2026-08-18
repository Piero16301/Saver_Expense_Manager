import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
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

  if (kDebugMode) {
    await dotenv.load();
  }

  // Initialize services and plugins in parallel
  final performance = getIt<PerformanceService>();
  final trace = performance.startTrace('app_initialization');
  await Future.wait([
    FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? AndroidDebugProvider(
              debugToken: dotenv.env['APP_CHECK_DEBUG_TOKEN'],
            )
          : const AndroidPlayIntegrityProvider(),
      providerApple: kDebugMode
          ? AppleDebugProvider(debugToken: dotenv.env['APP_CHECK_DEBUG_TOKEN'])
          : const AppleDeviceCheckProvider(),
    ),
    getIt<AuthService>().initialize(),
    getIt<LocalStorageService>().initialize(),
    getIt<RemoteConfigService>().initialize(),
    getIt<AiService>().initialize(),
  ]);
  performance.stopTrace(trace);

  // Bootstrap the app
  await bootstrap(() => const AppPage());
}
