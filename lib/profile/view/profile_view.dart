import 'dart:async';

import 'package:expressive_kit/expressive_kit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/profile/profile.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocListener<ProfileCubit, ProfileState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || previous.user != current.user,
      listener: (context, state) {
        if (state.status.isFailure) {
          AppFunctions.showSnackBar(
            context,
            message: state.errorMessage,
            type: SnackBarType.error,
          );
          context.read<ProfileCubit>().reset();
        }
      },
      child: Scaffold(
        appBar: ExpressiveTopAppBar(
          centerTitle: false,
          leading: Padding(
            padding: const EdgeInsets.all(8),
            child: ExpressiveIconButton.circle(
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                strokeWidth: 2,
              ),
              onPressed: () => context.pop(),
            ),
          ),
          title: Text(
            l10n.profileTitle,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        body: BlocBuilder<ProfileCubit, ProfileState>(
          builder: (context, state) {
            final user = state.user;
            if (user == null) {
              return const Center(
                child: ExpressiveCircularProgressIndicator(
                  size: 40,
                  strokeWidth: 4,
                ),
              );
            }

            final providers = user.providerData;
            final isGoogleLinked = providers.any(
              (p) => p.providerId == AppVariables.googleProvider,
            );
            final isEmailLinked = providers.any(
              (p) => p.providerId == AppVariables.emailProvider,
            );

            return Align(
              alignment: Alignment.topCenter,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppVariables.tabletMaxWidth,
                  ),
                  child: Column(
                    children: [
                      ExpressiveCard(
                        margin: EdgeInsets.zero,
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            // User Avatar
                            CircleAvatar(
                              radius: 80,
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withValues(alpha: 0.1),
                              child: user.photoURL == null
                                  ? Container(
                                      width: 160,
                                      height: 160,
                                      foregroundDecoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          width: 5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(18),
                                      child: HugeIcon(
                                        icon: HugeIcons.strokeRoundedUser,
                                        strokeWidth: 2,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    )
                                  : Container(
                                      width: 160,
                                      height: 160,
                                      foregroundDecoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).colorScheme.primary,
                                          width: 5,
                                        ),
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(80),
                                        child: Image.network(
                                          AppFunctions.highResPicture(
                                            url: user.photoURL,
                                            resolution:
                                                ImageResolutionType.high,
                                          ),
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) =>
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                          14,
                                                        ),
                                                    child: HugeIcon(
                                                      icon: HugeIcons
                                                          .strokeRoundedUser,
                                                      strokeWidth: 2,
                                                      color: Theme.of(
                                                        context,
                                                      ).colorScheme.primary,
                                                    ),
                                                  ),
                                        ),
                                      ),
                                    ),
                            ),
                            const SizedBox(height: 20),

                            // Name Section
                            Row(
                              spacing: 10,
                              children: [
                                if (state.isEditingName)
                                  Expanded(
                                    child: AppTextField(
                                      key: ValueKey(state.isEditingName),
                                      label: l10n.nameLabel,
                                      initialValue: state.userName.isEmpty
                                          ? user.displayName
                                          : state.userName,
                                      hintText: l10n.enterNameHint,
                                      onChanged: (value) => context
                                          .read<ProfileCubit>()
                                          .nameChanged(value),
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: Text(
                                      user.displayName ?? l10n.noName,
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleLarge,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                if (state.isEditingName) ...[
                                  ExpressiveIconButton.circle(
                                    size: ExpressiveIconButtonSize.small,
                                    onPressed: () => context
                                        .read<ProfileCubit>()
                                        .saveName(l10n),
                                    icon: HugeIcon(
                                      icon: HugeIcons
                                          .strokeRoundedCheckmarkCircle01,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                                  ExpressiveIconButton.circle(
                                    size: ExpressiveIconButtonSize.small,
                                    onPressed: () => context
                                        .read<ProfileCubit>()
                                        .toggleEditingName(),
                                    icon: HugeIcon(
                                      icon: HugeIcons.strokeRoundedCancelCircle,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.error,
                                      size: 20,
                                    ),
                                  ),
                                ] else
                                  ExpressiveIconButton.circle(
                                    size: ExpressiveIconButtonSize.small,
                                    onPressed: () => context
                                        .read<ProfileCubit>()
                                        .toggleEditingName(),
                                    icon: HugeIcon(
                                      icon: HugeIcons.strokeRoundedEdit01,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      size: 20,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Linked Accounts Section
                      ExpressiveCardGroup(
                        title: l10n.linkedAccountsTitle,
                        titlePadding: const EdgeInsets.only(
                          left: 8,
                          top: 8,
                          bottom: 8,
                        ),
                        margin: EdgeInsets.zero,
                        children: [
                          // Google Provider
                          _ProviderListTile(
                            icon: HugeIcons.strokeRoundedGoogle,
                            title: l10n.googleProvider,
                            isConnected: isGoogleLinked,
                            subtitle: isGoogleLinked
                                ? providers
                                      .firstWhere(
                                        (p) =>
                                            p.providerId ==
                                            AppVariables.googleProvider,
                                      )
                                      .email!
                                : null,
                            onLink: () =>
                                context.read<ProfileCubit>().linkGoogle(l10n),
                            onUnlink: () => _unlinkProvider(
                              context,
                              AppVariables.googleProvider,
                              providers,
                            ),
                          ),
                          // Email Provider
                          _ProviderListTile(
                            icon: HugeIcons.strokeRoundedMail01,
                            title: l10n.emailProvider,
                            isConnected: isEmailLinked,
                            subtitle: isEmailLinked
                                ? providers
                                      .firstWhere(
                                        (p) =>
                                            p.providerId ==
                                            AppVariables.emailProvider,
                                      )
                                      .email!
                                : null,
                            onLink: () => _showLinkEmailDialog(context),
                            onUnlink: () => _unlinkProvider(
                              context,
                              AppVariables.emailProvider,
                              providers,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ExpressiveButton.filled(
                          isExpanded: true,
                          onPressed: () => _logout(context),
                          icon: const HugeIcon(
                            icon: HugeIcons.strokeRoundedLogout01,
                            size: 20,
                          ),
                          label: l10n.logoutConfirm,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AppAlertDialog(
        title: l10n.confirmLogoutTitle,
        content: l10n.confirmLogoutMessage,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        confirmLabel: l10n.logoutConfirm,
        cancelLabel: l10n.logoutCancel,
      ),
    );

    if ((shouldLogout ?? false) && context.mounted) {
      await context.read<ProfileCubit>().logout(l10n);
    }
  }

  Future<void> _unlinkProvider(
    BuildContext context,
    String providerId,
    List<AppUserInfo> providers,
  ) async {
    final l10n = AppLocalizations.of(context);

    if (providers.length == 1) {
      AppFunctions.showSnackBar(
        context,
        message: l10n.unlinkProviderError,
        type: SnackBarType.error,
      );
      return;
    }

    final shouldUnlink = await showDialog<bool>(
      context: context,
      builder: (context) => AppAlertDialog(
        title: l10n.confirmUnlinkProviderTitle,
        content: l10n.confirmUnlinkProviderMessage,
        onConfirm: () => Navigator.of(context).pop(true),
        onCancel: () => Navigator.of(context).pop(false),
        confirmLabel: l10n.unlinkProviderConfirm,
        cancelLabel: l10n.unlinkProviderCancel,
      ),
    );

    if ((shouldUnlink ?? false) && context.mounted) {
      await context.read<ProfileCubit>().unlinkProvider(l10n, providerId);
    }
  }

  Future<void> _showLinkEmailDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    var isPasswordVisible = false;
    var isConfirmPasswordVisible = false;

    await showDialog<void>(
      context: context,
      builder: (childContext) => StatefulBuilder(
        builder: (stfulContext, setState) => AppAlertDialog(
          isForm: true,
          title: l10n.linkEmailTitle,
          onCancel: () => Navigator.of(context).pop(),
          onConfirm: () {
            if (formKey.currentState?.validate() ?? false) {
              unawaited(
                context.read<ProfileCubit>().linkEmail(
                  l10n,
                  email: emailController.text,
                  password: passwordController.text,
                ),
              );
              Navigator.of(context).pop();
            }
          },
          confirmLabel: l10n.linkEmailButton,
          cancelLabel: l10n.cancel,
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: emailController,
                  label: l10n.emailLabel,
                  hintText: l10n.emailHint,
                  keyboardType: TextInputType.emailAddress,
                  prefix: const HugeIcon(icon: HugeIcons.strokeRoundedMail01),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.emailRequired;
                    }
                    final emailRegex = RegExp(AppVariables.emailRegExp);
                    if (!emailRegex.hasMatch(value)) {
                      return l10n.invalidEmailFormat;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: passwordController,
                  label: l10n.passwordLabel,
                  hintText: l10n.passwordHint,
                  obscureText: !isPasswordVisible,
                  prefix: const HugeIcon(
                    icon: HugeIcons.strokeRoundedLockPassword,
                  ),
                  suffix: ExpressiveIconButton.circle(
                    size: ExpressiveIconButtonSize.small,
                    onPressed: () => setState(() {
                      isPasswordVisible = !isPasswordVisible;
                    }),
                    icon: HugeIcon(
                      icon: isPasswordVisible
                          ? HugeIcons.strokeRoundedView
                          : HugeIcons.strokeRoundedViewOff,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return l10n.passwordRequired;
                    }
                    final passwordRegex = RegExp(AppVariables.passwordRegExp);
                    if (!passwordRegex.hasMatch(value)) {
                      return l10n.invalidPasswordFormat;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: confirmPasswordController,
                  label: l10n.confirmPasswordLabel,
                  hintText: l10n.passwordHint,
                  obscureText: !isConfirmPasswordVisible,
                  prefix: const HugeIcon(
                    icon: HugeIcons.strokeRoundedLockPassword,
                  ),
                  suffix: ExpressiveIconButton.circle(
                    size: ExpressiveIconButtonSize.small,
                    onPressed: () => setState(() {
                      isConfirmPasswordVisible = !isConfirmPasswordVisible;
                    }),
                    icon: HugeIcon(
                      icon: isConfirmPasswordVisible
                          ? HugeIcons.strokeRoundedView
                          : HugeIcons.strokeRoundedViewOff,
                      size: 20,
                    ),
                  ),
                  validator: (value) {
                    if (value != passwordController.text) {
                      return l10n.passwordMismatchError;
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProviderListTile extends StatelessWidget {
  const _ProviderListTile({
    required this.icon,
    required this.title,
    required this.isConnected,
    this.subtitle,
    this.onLink,
    this.onUnlink,
  });

  final List<List<dynamic>> icon;
  final String title;
  final bool isConnected;
  final String? subtitle;
  final void Function()? onLink;
  final void Function()? onUnlink;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ExpressiveListTile(
      leading: ExpressiveBadge(
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        foregroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
        icon: HugeIcon(
          icon: icon,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          strokeWidth: 2,
        ),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontVariations: <FontVariation>[
            ...(Theme.of(context).textTheme.titleMedium?.fontVariations ??
                    const <FontVariation>[])
                .where((v) => v.axis != 'wght'),
            const FontVariation('wght', 700),
          ],
        ),
      ),
      subtitle: isConnected && subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodyMedium)
          : null,
      trailing: isConnected
          ? ExpressiveIconButton.circle(
              size: ExpressiveIconButtonSize.small,
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete01,
                color: Theme.of(context).colorScheme.error,
                strokeWidth: 2,
              ),
              onPressed: onUnlink,
            )
          : ExpressiveButton.outlined(
              size: ExpressiveButtonSize.small,
              onPressed: onLink,
              label: l10n.connectButton,
            ),
    );
  }
}
