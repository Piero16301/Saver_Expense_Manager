import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:rive/rive.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/bootstrap.dart';
import 'package:saver_expense_manager/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_api_remote/user_api_remote.dart';
import 'package:user_repository/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    providerAndroid: kDebugMode
        ? const AndroidDebugProvider()
        : const AndroidPlayIntegrityProvider(),
  );

  // Setup and initialize all services
  setupServiceLocator();
  await getIt<RemoteConfigService>().initialize();
  await getIt<AuthenticationService>().initialize();

  // Get SharedPreferences instance
  final preferences = await SharedPreferences.getInstance();

  // Configure User API and User Repository
  final userApi = UserApiRemote(preferences: preferences);
  final userRepository = UserRepository(userApi: userApi);

  // Initialize Rive
  await RiveNative.init();

  // Bootstrap the app
  await bootstrap(
    () => AppPage(
      userRepository: userRepository,
    ),
  );
}
