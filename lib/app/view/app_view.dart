import 'package:firebase_ui_localizations/firebase_ui_localizations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/routes/routes.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = goRouter();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routeInformationProvider: _router.routeInformationProvider,
      routerDelegate: _router.routerDelegate,
      routeInformationParser: _router.routeInformationParser,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es'),
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        snackBarTheme: SnackBarThemeData(
          contentTextStyle: const TextStyle(fontFamily: 'Ubuntu-Regular'),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          titleTextStyle: TextStyle(
            fontFamily: 'Ubuntu-Medium',
            color: Colors.black,
          ),
          subtitleTextStyle: TextStyle(
            fontFamily: 'Ubuntu-Regular',
            color: Colors.black,
          ),
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(
          color: Color.fromRGBO(0, 67, 101, 1),
        ),
        primaryColor: const Color.fromRGBO(0, 67, 101, 1),
        secondaryHeaderColor: const Color.fromRGBO(66, 176, 213, 1),
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
          ),
          labelStyle: TextStyle(
            fontSize: 14,
            fontFamily: 'Ubuntu-Regular',
          ),
        ),
        textTheme: const TextTheme(
          displaySmall: TextStyle(
            fontSize: 12,
            fontFamily: 'Ubuntu-Medium',
          ),
          displayMedium: TextStyle(
            fontSize: 14,
            fontFamily: 'Ubuntu-Medium',
          ),
          displayLarge: TextStyle(
            fontSize: 16,
            fontFamily: 'Ubuntu-Medium',
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            fontFamily: 'Ubuntu-Regular',
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            fontFamily: 'Ubuntu-Regular',
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            fontFamily: 'Ubuntu-Regular',
          ),
          labelSmall: TextStyle(
            fontSize: 12,
            fontFamily: 'Ubuntu-Regular',
          ),
          labelMedium: TextStyle(
            fontSize: 14,
            fontFamily: 'Ubuntu-Regular',
          ),
          labelLarge: TextStyle(
            fontSize: 16,
            fontFamily: 'Ubuntu-Regular',
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ButtonStyle(
            backgroundColor: WidgetStateProperty.all(
              const Color.fromRGBO(0, 67, 101, 1),
            ),
            shape: WidgetStateProperty.all(
              const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(10),
                ),
              ),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color.fromRGBO(0, 67, 101, 1),
          elevation: 2,
        ),
      ),
      localizationsDelegates: const [
        FirebaseUILocalizationDelegate(),
        ...AppLocalizations.localizationsDelegates,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
