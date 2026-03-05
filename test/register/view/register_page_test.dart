import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/register/register.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  late AuthenticationService mockAuthService;
  late MockAppCubit mockAppCubit;

  setUp(() async {
    mockAuthService = MockAuthenticationService();
    mockAppCubit = MockAppCubit();

    if (getIt.isRegistered<AuthenticationService>()) {
      await getIt.unregister<AuthenticationService>();
    }
    getIt.registerSingleton<AuthenticationService>(mockAuthService);

    when(() => mockAppCubit.state).thenReturn(const AppState());
    when(() => mockAppCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  testWidgets('RegisterPage builds RegisterView', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: BlocProvider<AppCubit>.value(
          value: mockAppCubit,
          child: const RegisterPage(),
        ),
      ),
    );

    expect(find.byType(RegisterView), findsOneWidget);
  });
}
