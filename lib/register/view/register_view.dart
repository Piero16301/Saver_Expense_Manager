import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/login/login.dart';
import 'package:saver_expense_manager/register/register.dart';

class RegisterView extends StatelessWidget {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isFailure) {
          AppFunctions.showSnackBar(
            context,
            message: state.errorMessage,
            type: SnackBarType.error,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  AppChangeLanguage(
                    padding: EdgeInsets.only(top: 16, right: 8),
                  ),
                  AppChangeTheme(
                    padding: EdgeInsets.only(top: 16, right: 16),
                  ),
                ],
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: BlocBuilder<RegisterCubit, RegisterState>(
                    builder: (context, state) {
                      return ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxWidth: AppVariables.tabletMaxWidth,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Logo
                            const AppLogo(),
                            const SizedBox(height: 48),

                            // Title
                            Text(
                              l10n.registerTitle,
                              style: Theme.of(context).textTheme.headlineMedium,
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            // Email Field
                            AppTextField(
                              label: l10n.emailLabel,
                              hintText: l10n.emailHint,
                              keyboardType: TextInputType.emailAddress,
                              prefix: const HugeIcon(
                                icon: HugeIcons.strokeRoundedMail01,
                              ),
                              onChanged: (value) => context
                                  .read<RegisterCubit>()
                                  .emailChanged(value),
                              errorText: l10n.emailRequired,
                              overrideErrorText: !state.isEmailValid
                                  ? l10n.invalidEmailFormat
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            // Password Field
                            AppTextField(
                              label: l10n.passwordLabel,
                              hintText: l10n.passwordHint,
                              obscureText: !state.isPasswordVisible,
                              prefix: const HugeIcon(
                                icon: HugeIcons.strokeRoundedLockPassword,
                              ),
                              suffix: IconButton(
                                onPressed: () => context
                                    .read<RegisterCubit>()
                                    .togglePasswordVisibility(),
                                icon: Icon(
                                  state.isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              onChanged: (value) => context
                                  .read<RegisterCubit>()
                                  .passwordChanged(value),
                              errorText: l10n.passwordRequired,
                              overrideErrorText: !state.isPasswordValid
                                  ? l10n.invalidPasswordFormat
                                  : null,
                            ),
                            const SizedBox(height: 24),

                            // Confirm Password Field
                            AppTextField(
                              label: l10n.confirmPasswordLabel,
                              hintText: l10n.passwordHint,
                              obscureText: !state.isConfirmPasswordVisible,
                              prefix: const HugeIcon(
                                icon: HugeIcons.strokeRoundedLockPassword,
                              ),
                              suffix: IconButton(
                                onPressed: () => context
                                    .read<RegisterCubit>()
                                    .toggleConfirmPasswordVisibility(),
                                icon: Icon(
                                  state.isConfirmPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              onChanged: (value) => context
                                  .read<RegisterCubit>()
                                  .confirmPasswordChanged(value),
                              overrideErrorText: !state.isConfirmPasswordValid
                                  ? l10n.passwordMismatchError
                                  : null,
                            ),
                            const SizedBox(height: 48),

                            // Register Button
                            AppFilledButton(
                              onPressed: state.status.isLoading
                                  ? null
                                  : () => context
                                      .read<RegisterCubit>()
                                      .register(l10n),
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedUserAdd01,
                                strokeWidth: 2,
                              ),
                              label: state.status.isLoading
                                  ? l10n.loading
                                  : l10n.registerButton,
                            ),
                            const SizedBox(height: 24),

                            // Login Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.haveAccount,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: state.status.isLoading
                                      ? null
                                      : () =>
                                          context.goNamed(LoginPage.pageName),
                                  child: Text(
                                    l10n.loginButton,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
