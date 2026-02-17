import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
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

  // Initialize services and plugins in parallel
  await Future.wait([
    FirebaseAppCheck.instance.activate(
      providerAndroid: kDebugMode
          ? const AndroidDebugProvider()
          : const AndroidPlayIntegrityProvider(),
    ),
    getIt<RemoteConfigService>().initialize(),
    getIt<AuthenticationService>().initialize(),
    getIt<LocalStorageService>().initialize(),
    RiveNative.init(),
  ]);

  // Bootstrap the app
  await bootstrap(() => const AppPage());
}
