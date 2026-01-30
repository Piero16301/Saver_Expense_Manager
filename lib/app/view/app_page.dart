import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:user_repository/user_repository.dart';

class AppPage extends StatelessWidget {
  const AppPage({
    required UserRepository userRepository,
    super.key,
  }) : _userRepository = userRepository;

  final UserRepository _userRepository;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<UserRepository>.value(value: _userRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AppCubit>(
            /// Initialize the AppCubit and load the initial data.
            // ignore: discarded_futures
            create: (_) => AppCubit(_userRepository)..initialLoad(),
          ),
        ],
        child: const AppView(),
      ),
    );
  }
}
