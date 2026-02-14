import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/register/register.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  static const String pageName = 'register';
  static const String pagePath = '/register';

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => RegisterCubit(),
      child: const RegisterView(),
    );
  }
}
