import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rive/rive.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/bootstrap.dart';
import 'package:saver_expense_manager/firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Setup service locator
  setupServiceLocator();

  if (kDebugMode) {
    await dotenv.load();
  }

  // Initialize services and plugins in parallel
  await Future.wait([
    FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? AndroidDebugProvider(
              debugToken: dotenv.env['APP_CHECK_DEBUG_TOKEN'],
            )
          : const AndroidPlayIntegrityProvider(),
    ),
    getIt<AuthenticationService>().initialize(),
    getIt<LocalStorageService>().initialize(),
    getIt<RemoteConfigService>().initialize(),
    getIt<AiService>().initialize(),
    RiveNative.init(),
  ]);

  // Bootstrap the app
  await bootstrap(() => const AppPage());
}
