import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
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
          context.read<RegisterCubit>().reset();
        }
        if (state.status.isSuccess) {
          AppFunctions.showSnackBar(
            context,
            message: l10n.registerSuccess,
            type: SnackBarType.success,
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  AppChangeTheme(padding: EdgeInsets.only(top: 16, left: 16)),
                  AppChangeLanguage(
                    padding: EdgeInsets.only(top: 16, right: 16),
                  ),
                ],
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: BlocBuilder<RegisterCubit, RegisterState>(
                    builder: (context, state) {
                      final c = context.read<RegisterCubit>();
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
                            const SizedBox(height: 32),

                            // Title
                            Text(
                              l10n.registerTitle,
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(fontWeight: FontWeight.w800),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),

                            ExpressiveCard(
                              margin: EdgeInsets.zero,
                              padding: const EdgeInsets.all(24),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Name Field
                                  AppTextField(
                                    enabled: !state.status.isLoading,
                                    label: l10n.nameLabel,
                                    hintText: l10n.nameHint,
                                    keyboardType: TextInputType.name,
                                    prefix: const HugeIcon(
                                      icon: HugeIcons.strokeRoundedUser,
                                    ),
                                    onChanged: c.nameChanged,
                                    errorText: l10n.nameRequired,
                                    overrideErrorText: !state.isNameValid
                                        ? l10n.invalidNameFormat
                                        : null,
                                  ),
                                  const SizedBox(height: 20),

                                  // Email Field
                                  AppTextField(
                                    enabled: !state.status.isLoading,
                                    label: l10n.emailLabel,
                                    hintText: l10n.emailHint,
                                    keyboardType: TextInputType.emailAddress,
                                    prefix: const HugeIcon(
                                      icon: HugeIcons.strokeRoundedMail01,
                                    ),
                                    onChanged: c.emailChanged,
                                    errorText: l10n.emailRequired,
                                    overrideErrorText: !state.isEmailValid
                                        ? l10n.invalidEmailFormat
                                        : null,
                                  ),
                                  const SizedBox(height: 20),

                                  // Password Field
                                  AppTextField(
                                    enabled: !state.status.isLoading,
                                    label: l10n.passwordLabel,
                                    hintText: l10n.passwordHint,
                                    obscureText: !state.isPasswordVisible,
                                    prefix: const HugeIcon(
                                      icon: HugeIcons.strokeRoundedLockPassword,
                                    ),
                                    suffix: ExpressiveIconButton.circle(
                                      size: ExpressiveIconButtonSize.small,
                                      onPressed: state.status.isLoading
                                          ? null
                                          : c.togglePasswordVisibility,
                                      icon: HugeIcon(
                                        icon: state.isPasswordVisible
                                            ? HugeIcons.strokeRoundedView
                                            : HugeIcons.strokeRoundedViewOff,
                                        size: 20,
                                      ),
                                    ),
                                    onChanged: c.passwordChanged,
                                    errorText: l10n.passwordRequired,
                                    overrideErrorText: !state.isPasswordValid
                                        ? l10n.invalidPasswordFormat
                                        : null,
                                  ),
                                  const SizedBox(height: 20),

                                  // Confirm Password Field
                                  AppTextField(
                                    enabled: !state.status.isLoading,
                                    label: l10n.confirmPasswordLabel,
                                    hintText: l10n.passwordHint,
                                    obscureText:
                                        !state.isConfirmPasswordVisible,
                                    prefix: const HugeIcon(
                                      icon: HugeIcons.strokeRoundedLockPassword,
                                    ),
                                    suffix: ExpressiveIconButton.circle(
                                      size: ExpressiveIconButtonSize.small,
                                      onPressed: state.status.isLoading
                                          ? null
                                          : c.toggleConfirmPasswordVisibility,
                                      icon: HugeIcon(
                                        icon: state.isConfirmPasswordVisible
                                            ? HugeIcons.strokeRoundedView
                                            : HugeIcons.strokeRoundedViewOff,
                                        size: 20,
                                      ),
                                    ),
                                    onChanged: c.confirmPasswordChanged,
                                    overrideErrorText:
                                        !state.isConfirmPasswordValid
                                        ? l10n.passwordMismatchError
                                        : null,
                                  ),
                                  const SizedBox(height: 32),

                                  // Register Button
                                  ExpressiveButton.filled(
                                    isExpanded: true,
                                    isLoading: state.status.isLoading,
                                    onPressed: state.status.isLoading
                                        ? null
                                        : () => c.register(l10n),
                                    icon: const HugeIcon(
                                      icon: HugeIcons.strokeRoundedUserAdd01,
                                      size: 20,
                                    ),
                                    label: state.status.isLoading
                                        ? l10n.loading
                                        : l10n.registerButton,
                                  ),
                                ],
                              ),
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
                                const SizedBox(width: 4),
                                ExpressiveButton.text(
                                  size: ExpressiveButtonSize.small,
                                  onPressed: state.status.isLoading
                                      ? null
                                      : () => context.goNamed(
                                          AppRoute.login.name,
                                        ),
                                  label: l10n.loginButton,
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
