import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
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

  // Configure Firebase Auth providers
  FirebaseUIAuth.configureProviders([
    EmailAuthProvider(),
    GoogleProvider(
      clientId: DefaultFirebaseOptions.googleClientId,
      redirectUri: DefaultFirebaseOptions.googleRedirectUri,
    ),
  ]);

  // Get SharedPreferences instance
  final preferences = await SharedPreferences.getInstance();

  // Initialize User API
  final userApi = UserApiRemote(preferences: preferences);

  // Initialize User Repository
  final userRepository = UserRepository(userApi: userApi);

  // Bootstrap the app
  await bootstrap(() => AppPage(userRepository: userRepository));
}
