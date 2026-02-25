import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/profile/profile.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocProvider(
      create: (_) => ProfileCubit(),
      child: BlocListener<ProfileCubit, ProfileState>(
        listenWhen: (previous, current) =>
            previous.status != current.status || previous.user != current.user,
        listener: (context, state) {
          if (state.status == ProfileStatus.failure) {
            AppFunctions.showSnackBar(
              context,
              message: state.errorMessage,
              type: SnackBarType.error,
            );
          }
        },
        child: Scaffold(
          appBar: AppBar(
            title: Text(
              l10n.profileTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            centerTitle: true,
            leading: IconButton(
              onPressed: () => context.pop(),
              icon: const HugeIcon(
                icon: HugeIcons.strokeRoundedArrowLeft01,
                strokeWidth: 2,
              ),
            ),
          ),
          body: BlocBuilder<ProfileCubit, ProfileState>(
            builder: (context, state) {
              final user = state.user;
              if (user == null) {
                return const Center(child: CircularProgressIndicator());
              }

              final providers = user.providerData;
              final isGoogleLinked = providers
                  .any((p) => p.providerId == AppVariables.googleProvider);
              final isEmailLinked = providers
                  .any((p) => p.providerId == AppVariables.emailProvider);

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
                        // User Avatar
                        CircleAvatar(
                          radius: 80,
                          backgroundColor: Theme.of(context)
                              .primaryColor
                              .withValues(alpha: 0.1),
                          child: user.photoURL == null
                              ? Container(
                                  width: 160,
                                  height: 160,
                                  foregroundDecoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(18),
                                  child: HugeIcon(
                                    icon: HugeIcons.strokeRoundedUser,
                                    strokeWidth: 2,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                )
                              : Container(
                                  width: 160,
                                  height: 160,
                                  foregroundDecoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                      width: 5,
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(80),
                                    child: Image.network(
                                      AppFunctions.highResPicture(
                                        url: user.photoURL,
                                        resolution: ImageResolutionType.high,
                                      ),
                                      fit: BoxFit.cover,
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
                                  key: ValueKey(
                                    state.isEditingName,
                                  ),
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
                                  style: Theme.of(context).textTheme.titleLarge,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            if (state.isEditingName) ...[
                              IconButton(
                                onPressed: () =>
                                    context.read<ProfileCubit>().saveName(l10n),
                                icon: HugeIcon(
                                  icon:
                                      HugeIcons.strokeRoundedCheckmarkCircle01,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                              IconButton(
                                onPressed: () => context
                                    .read<ProfileCubit>()
                                    .toggleEditingName(),
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedCancelCircle,
                                  color: Theme.of(context).colorScheme.error,
                                  size: 28,
                                ),
                              ),
                            ] else
                              IconButton(
                                onPressed: () => context
                                    .read<ProfileCubit>()
                                    .toggleEditingName(),
                                icon: HugeIcon(
                                  icon: HugeIcons.strokeRoundedEdit01,
                                  color: Theme.of(context).colorScheme.primary,
                                  size: 28,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Linked Accounts Section
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            l10n.linkedAccountsTitle,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Card(
                          child: Column(
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
                                onLink: () => context
                                    .read<ProfileCubit>()
                                    .linkGoogle(l10n),
                                onUnlink: () => _unlinkProvider(
                                  context,
                                  AppVariables.googleProvider,
                                ),
                              ),
                              const Divider(height: 1),
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
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: AppFilledButton(
                            onPressed: () => _logout(context),
                            icon: const HugeIcon(
                              icon: HugeIcons.strokeRoundedLogout01,
                              strokeWidth: 2,
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

  Future<void> _unlinkProvider(BuildContext context, String providerId) async {
    final l10n = AppLocalizations.of(context);
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

    await showDialog<void>(
      context: context,
      builder: (childContext) => AppAlertDialog(
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
                obscureText: true,
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
                obscureText: true,
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

    return ListTile(
      minTileHeight: 70,
      leading: HugeIcon(
        icon: icon,
        color: Theme.of(context).colorScheme.primary,
        size: 28,
        strokeWidth: 2,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      subtitle: isConnected && subtitle != null
          ? Text(
              subtitle!,
              style: Theme.of(context).textTheme.bodyMedium,
            )
          : null,
      trailing: isConnected
          ? IconButton(
              icon: HugeIcon(
                icon: HugeIcons.strokeRoundedDelete01,
                color: Theme.of(context).colorScheme.error,
                strokeWidth: 2,
              ),
              onPressed: onUnlink,
            )
          : AppOutlinedButton(
              onPressed: onLink,
              label: l10n.connectButton,
              innerPadding: const EdgeInsets.all(8),
            ),
    );
  }
}
