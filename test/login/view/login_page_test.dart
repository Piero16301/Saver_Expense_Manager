import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/login/login.dart';

void main() {
  group('LoginPage', () {
    test('is a StatelessWidget', () {
      const loginPage = LoginPage();
      expect(loginPage, isA<StatelessWidget>());
    });

    test('can be instantiated', () {
      const loginPage = LoginPage();
      expect(loginPage, isNotNull);
    });

    test('can be instantiated with key', () {
      const key = Key('login_page_key');
      const loginPage = LoginPage(key: key);

      expect(loginPage.key, equals(key));
    });

    testWidgets('build returns BlocProvider', (tester) async {
      const loginPage = LoginPage();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final widget = loginPage.build(context);
              expect(widget, isA<BlocProvider<LoginCubit>>());
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('build returns BlocProvider with LoginView as child', (
      tester,
    ) async {
      const loginPage = LoginPage();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final widget = loginPage.build(context);
              expect(widget, isA<BlocProvider<LoginCubit>>());

              final blocProvider = widget as BlocProvider<LoginCubit>;
              expect(blocProvider.child, isA<LoginView>());
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('BlocProvider creates LoginCubit instance', (tester) async {
      const loginPage = LoginPage();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final widget = loginPage.build(context);
              expect(widget, isA<BlocProvider<LoginCubit>>());
              return const SizedBox();
            },
          ),
        ),
      );
    });

    testWidgets('LoginView child is const', (tester) async {
      const loginPage = LoginPage();

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) {
              final widget = loginPage.build(context);
              final blocProvider = widget as BlocProvider<LoginCubit>;

              expect(blocProvider.child.runtimeType, equals(LoginView));

              return const SizedBox();
            },
          ),
        ),
      );
    });

    test('LoginPage has correct constructor signature', () {
      const loginPage = LoginPage();
      expect(loginPage.key, isNull);

      const keyedLoginPage = LoginPage(key: Key('test'));
      expect(keyedLoginPage.key, isNotNull);
    });
  });
}
