import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/movement/movement.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class MovementView extends StatelessWidget {
  const MovementView({
    required this.type,
    required this.screenType,
    super.key,
  });

  final CategoryType type;
  final MovementScreenType screenType;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser!;
    final l10n = context.l10n;

    return BlocBuilder<MovementCubit, MovementState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle(l10n)),
          centerTitle: true,
          notificationPredicate: (notification) => false,
        ),
        body: Padding(
          padding: const EdgeInsets.only(
            left: 30,
            right: 30,
            bottom: 50,
          ),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              children: [
                const SizedBox(height: 10),
                AppTextField(
                  label: l10n.movementTitle,
                  hintText: l10n.movementTitleHint,
                  errorText: l10n.movementTitleError,
                  onChanged: context.read<MovementCubit>().titleChanged,
                  prefix: const Icon(Icons.title),
                  initialValue: state.title,
                  maxLength: 50,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: l10n.movementDescription,
                  hintText: l10n.movementDescriptionHint,
                  errorText: l10n.movementDescriptionError,
                  onChanged: context.read<MovementCubit>().descriptionChanged,
                  prefix: const Icon(Icons.description),
                  initialValue: state.description,
                  maxLines: 6,
                  maxLength: 250,
                ),
                const SizedBox(height: 20),
                AppDateField(
                  label: l10n.movementDate,
                  initialDate: state.date!,
                  onDateChanged: context.read<MovementCubit>().dateChanged,
                ),
                const SizedBox(height: 20),
                AppDropdownField<Category>(
                  label: l10n.movementCategory,
                  options: state.categories
                      .map(
                        (category) => DropdownMenuEntry<Category>(
                          value: category,
                          label: getCategoryName(category.name, l10n),
                          leadingIcon: Icon(getIconData(category.icon)),
                        ),
                      )
                      .toList(),
                  selected: state.category!,
                  leadingIcon: getIconData(state.category!.icon),
                  onSelected: context.read<MovementCubit>().categoryChanged,
                ),
                const SizedBox(height: 20),
                AppTextField(
                  label: l10n.movementAmount,
                  hintText: l10n.movementAmountHint,
                  errorText: l10n.movementAmountError,
                  onChanged: context.read<MovementCubit>().priceChanged,
                  prefix: const Icon(Icons.attach_money),
                  initialValue:
                      state.price == 0 ? '' : state.price.toStringAsFixed(2),
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
                  isRequired: false,
                  onChanged: context.read<MovementCubit>().companyChanged,
                  prefix: const Icon(Icons.business),
                  initialValue: state.company,
                  maxLength: 50,
                ),
                const SizedBox(height: 20),
                AppFileField(
                  label: l10n.movementAttachments,
                  labelAdd: l10n.movementAddAttachment,
                  onAdd: context.read<MovementCubit>().attachAdd,
                  onRemove: context.read<MovementCubit>().attachRemove,
                  attachments: state.attachments,
                ),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            if (context.read<MovementCubit>().saveMovement(user.uid)) {
              Navigator.of(context).pop();
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(l10n.movementSaveError),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
          child: const Icon(Icons.save),
        ),
      ),
    );
  }

  String appBarTitle(AppLocalizations l10n) {
    switch (screenType) {
      case MovementScreenType.add:
        return l10n.movementNewAppbarTitle;
      case MovementScreenType.edit:
        return l10n.movementEditAppbarTitle;
    }
  }
}
