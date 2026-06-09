import 'dart:async';

import 'package:flutter/foundation.dart' hide Category;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/movement/movement.dart';

class MovementView extends StatelessWidget {
  const MovementView({required this.type, required this.screenType, super.key});

  final CategoryType type;
  final MovementScreenType screenType;

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthService>();
    final user = auth.currentUser!;
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<MovementCubit, MovementState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(
            _appBarTitle(l10n),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
          ),
          notificationPredicate: (notification) => false,
          actions: _appBarActions(context, l10n),
          leading: IconButton(
            onPressed: () => context.pop(),
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              strokeWidth: 2,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: 50,
          ),
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Form(
                key: state.formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: AppVariables.tabletMaxWidth,
                  ),
                  child: Column(
                    children: [
                      const SizedBox(height: 5),
                      AppTextField(
                        label: l10n.movementTitle,
                        hintText: l10n.movementTitleHint,
                        errorText: l10n.movementTitleError,
                        onChanged: context.read<MovementCubit>().titleChanged,
                        prefix: const HugeIcon(
                          icon: HugeIcons.strokeRoundedTextFont,
                        ),
                        initialValue: state.title,
                        maxLength: 50,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: l10n.movementDescription,
                        hintText: l10n.movementDescriptionHint,
                        errorText: l10n.movementDescriptionError,
                        onChanged:
                            context.read<MovementCubit>().descriptionChanged,
                        prefix: const HugeIcon(
                          icon: HugeIcons.strokeRoundedNote,
                        ),
                        initialValue: state.description,
                        maxLines: 7,
                        maxLength: 300,
                      ),
                      const SizedBox(height: 20),
                      AppDateField(
                        label: l10n.movementDate,
                        initialDate: state.date!,
                        onDateChanged:
                            context.read<MovementCubit>().dateChanged,
                      ),
                      const SizedBox(height: 20),
                      AppDropdownField<Category>(
                        label: l10n.movementCategory,
                        options: state.categories
                            .map(
                              (category) => DropdownMenuItem<Category>(
                                value: category,
                                child: Row(
                                  spacing: 12,
                                  children: [
                                    HugeIcon(
                                      icon: AppFunctions.getCategoryIcon(
                                        category.icon,
                                      ),
                                    ),
                                    Text(
                                      AppFunctions.getCategoryName(
                                        category.name,
                                        l10n,
                                      ),
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge,
                                    ),
                                  ],
                                ),
                              ),
                            )
                            .toList(),
                        selected: state.category,
                        leadingIcon: AppFunctions.getCategoryIcon(
                          state.category!.icon,
                        ),
                        onChanged:
                            context.read<MovementCubit>().categoryChanged,
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: l10n.movementAmount,
                        hintText: l10n.movementAmountHint,
                        errorText: l10n.movementAmountError,
                        onChanged: context.read<MovementCubit>().priceChanged,
                        prefix: const HugeIcon(
                          icon: HugeIcons.strokeRoundedMoney01,
                        ),
                        initialValue: state.price == 0
                            ? ''
                            : state.price.toStringAsFixed(2),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      AppTextField(
                        label: l10n.movementCompany,
                        hintText: l10n.movementCompanyHint,
                        errorText: l10n.movementCompanyError,
                        onChanged: context.read<MovementCubit>().companyChanged,
                        prefix: const HugeIcon(
                          icon: HugeIcons.strokeRoundedBuilding01,
                        ),
                        initialValue: state.company,
                        maxLength: 50,
                      ),
                      const SizedBox(height: 20),
                      AppFileField(
                        label: l10n.movementAttachments,
                        labelAdd: l10n.movementAddAttachment,
                        onAdd: context.read<MovementCubit>().attachAdd,
                        onRemove: context.read<MovementCubit>().attachRemove,
                        openFile: context.read<MovementCubit>().attachOpen,
                        attachments: state.attachments,
                      ),
                      if (kDebugMode) MovementMetadata(id: state.id),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () =>
              _onSaveButtonPressed(context, state.date!, user.uid, l10n),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedFloppyDisk,
            strokeWidth: 2,
          ),
        ),
      ),
    );
  }

  Future<void> _onSaveButtonPressed(
    BuildContext context,
    DateTime selectedDate,
    String uid,
    AppLocalizations l10n,
  ) async {
    if (selectedDate.isBefore(
      DateTime.now().subtract(
        const Duration(days: AppVariables.maxDaysWarning),
      ),
    )) {
      unawaited(
        showDialog<void>(
          context: context,
          builder: (dialogContext) => AppAlertDialog(
            title: l10n.movementDateWarningTitle,
            content: l10n.movementDateWarningContent(
              AppVariables.maxDaysWarning,
            ),
            cancelLabel: l10n.cancel,
            confirmLabel: l10n.confirm,
            onCancel: () => context.pop(),
            onConfirm: () => _onConfirmDialog(context, uid, l10n),
          ),
        ),
      );
    } else {
      context.read<MovementCubit>().saveMovement(uid, l10n);

      if (context.mounted) {
        context.pop<bool>(true);
      } else {
        AppFunctions.showSnackBar(
          context,
          message: l10n.movementSaveError,
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _onConfirmDialog(
    BuildContext context,
    String uid,
    AppLocalizations l10n,
  ) async {
    context.pop();

    context.read<MovementCubit>().saveMovement(uid, l10n);

    if (context.mounted) {
      context.pop<bool>(true);
    } else {
      AppFunctions.showSnackBar(
        context,
        message: l10n.movementSaveError,
        type: SnackBarType.error,
      );
    }
  }

  String _appBarTitle(AppLocalizations l10n) {
    switch (screenType) {
      case MovementScreenType.add:
        return l10n.movementNewAppbarTitle;
      case MovementScreenType.edit:
        return l10n.movementEditAppbarTitle;
    }
  }

  List<Widget>? _appBarActions(BuildContext context, AppLocalizations l10n) {
    switch (screenType) {
      case MovementScreenType.add:
        return null;
      case MovementScreenType.edit:
        return [
          IconButton(
            onPressed: () => _showDeleteDialog(context, l10n),
            icon: HugeIcon(
              icon: HugeIcons.strokeRoundedDelete02,
              strokeWidth: 2,
              color: Theme.of(context).colorScheme.error,
            ),
          ),
        ];
    }
  }

  void _showDeleteDialog(BuildContext context, AppLocalizations l10n) {
    unawaited(
      showDialog<void>(
        context: context,
        builder: (dialogContext) => AppAlertDialog(
          title: l10n.confirmDeleteMovementTitle,
          content: l10n.confirmDeleteMovementMessage,
          confirmLabel: l10n.deleteMovementConfirm,
          cancelLabel: l10n.deleteMovementCancel,
          onConfirm: () {
            Navigator.of(dialogContext).pop();
            context.read<MovementCubit>().removeMovement();
            if (context.mounted) {
              AppFunctions.showSnackBar(
                context,
                message: l10n.movementDeleteSuccess,
                type: SnackBarType.success,
              );
              context.pop<bool>(true);
            } else {
              AppFunctions.showSnackBar(
                context,
                message: l10n.movementDeleteError,
                type: SnackBarType.error,
              );
            }
          },
          onCancel: () => Navigator.of(dialogContext).pop(),
        ),
      ),
    );
  }
}

class MovementMetadata extends StatelessWidget {
  const MovementMetadata({required this.id, super.key});

  final String id;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: RichText(
            text: TextSpan(
              text: 'ID: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
              children: [
                TextSpan(
                  text: id,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
