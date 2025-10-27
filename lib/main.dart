import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:firebase_ui_storage/firebase_ui_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:rive/rive.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/bootstrap.dart';
import 'package:saver_expense_manager/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:user_api_remote/user_api_remote.dart';
import 'package:user_repository/user_repository.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env file
  await dotenv.load(fileName: './.env');

  // Initialize Firebase with the default options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Firebase App Check
  await FirebaseAppCheck.instance.activate(
    androidProvider: kDebugMode
        ? AndroidProvider.debug
        : AndroidProvider.playIntegrity,
  );

  // Configure Firebase Auth providers
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(
      clientId: DefaultFirebaseOptions.googleClientId,
      redirectUri: DefaultFirebaseOptions.googleRedirectUri,
    ),
  ]);

  // Configure Firebase Storage
  final storage = FirebaseStorage.instance;
  final config = FirebaseUIStorageConfiguration(
    storage: storage,
    uploadRoot: storage.ref(),
    namingPolicy: const UuidFileUploadNamingPolicy(),
  );
  await FirebaseUIStorage.configure(config);

  // Get SharedPreferences instance
  final preferences = await SharedPreferences.getInstance();

  // Configure User API and User Repository
  final userApi = UserApiRemote(preferences: preferences);
  final userRepository = UserRepository(userApi: userApi);

  // Initialize Rive
  await RiveNative.init();

  // Bootstrap the app
  await bootstrap(() => AppPage(userRepository: userRepository));
}
