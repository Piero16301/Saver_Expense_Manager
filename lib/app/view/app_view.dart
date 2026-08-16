import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class AppView extends StatefulWidget {
  const AppView({super.key});

  @override
  State<AppView> createState() => _AppViewState();
}

class _AppViewState extends State<AppView> {
  late final GoRouter _router;
  StreamSubscription<AppUser?>? _authSubscription;

  @override
  void initState() {
    super.initState();
    _router = AppRoutes.getRouter();

    final authService = getIt<AuthService>();
    _authSubscription = authService.authStateChanges.listen((user) {
      getIt<AnalyticsService>().setUserId(id: user?.uid ?? '');
      getIt<CrashService>().setUserIdentifier(user?.uid ?? '');
    });
  }

  @override
  void dispose() {
    unawaited(_authSubscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppCubit, AppState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: AppVariables.appName,
          routeInformationProvider: _router.routeInformationProvider,
          routerDelegate: _router.routerDelegate,
          routeInformationParser: _router.routeInformationParser,
          debugShowCheckedModeBanner: false,
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(boldText: false),
              child: child!,
            );
          },
          localizationsDelegates: const [
            AppLocalizations.delegate,
            ...GlobalMaterialLocalizations.delegates,
          ],
          supportedLocales: AppVariables.supportedLocales,
          locale: state.language,
          theme: AppThemes.lightTheme(
            baseColor: state.baseColor,
            fontFamily: state.fontFamily,
          ),
          darkTheme: AppThemes.darkTheme(
            baseColor: state.baseColor,
            fontFamily: state.fontFamily,
          ),
          themeAnimationCurve: Curves.easeInOut,
          themeAnimationDuration: AppVariables.animationDuration,
          themeMode: state.theme,
        );
      },
    );
  }
}
