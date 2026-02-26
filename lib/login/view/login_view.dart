import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/login/login.dart';
import 'package:saver_expense_manager/register/register.dart';

class LoginView extends StatelessWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status.isFailure) {
          AppFunctions.showSnackBar(
            context,
            message: state.errorMessage,
            type: SnackBarType.error,
          );
        }
        if (state.status.isSuccess) {
          AppFunctions.showSnackBar(
            context,
            message: l10n.loginSuccess,
            type: SnackBarType.success,
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
                  child: BlocBuilder<LoginCubit, LoginState>(
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
                              l10n.loginTitle,
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
                                  .read<LoginCubit>()
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
                                    .read<LoginCubit>()
                                    .togglePasswordVisibility(),
                                icon: Icon(
                                  state.isPasswordVisible
                                      ? Icons.visibility
                                      : Icons.visibility_off,
                                ),
                              ),
                              onChanged: (value) => context
                                  .read<LoginCubit>()
                                  .passwordChanged(value),
                              errorText: l10n.passwordRequired,
                              overrideErrorText: !state.isPasswordValid
                                  ? l10n.invalidPasswordFormat
                                  : null,
                            ),
                            const SizedBox(height: 48),

                            // Login Button
                            AppFilledButton(
                              onPressed: state.status.isLoading
                                  ? null
                                  : () => context
                                      .read<LoginCubit>()
                                      .loginWithEmail(l10n),
                              icon: const HugeIcon(
                                icon: HugeIcons.strokeRoundedLogin01,
                                strokeWidth: 2,
                              ),
                              label: state.status.isLoading
                                  ? l10n.loginLoading
                                  : l10n.loginButton,
                            ),
                            const SizedBox(height: 24),

                            // Google Login Button
                            AppOutlinedButton(
                              onPressed: state.status.isLoading
                                  ? null
                                  : () => context
                                      .read<LoginCubit>()
                                      .loginWithGoogle(l10n),
                              icon: HugeIcons.strokeRoundedGoogle,
                              label: l10n.googleLoginButton,
                            ),
                            const SizedBox(height: 24),

                            // Register Button
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  l10n.noAccount,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                TextButton(
                                  onPressed: state.status.isLoading
                                      ? null
                                      : () =>
                                          context.push(RegisterPage.pagePath),
                                  child: Text(
                                    l10n.registerButton,
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
