import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/login/login.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const String pageName = 'login';
  static const String pagePath = '/login';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginCubit(),
      child: const LoginView(),
    );
  }
}
