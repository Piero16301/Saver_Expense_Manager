import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/enter_movement/enter_movement.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';

class EnterMovementView extends StatelessWidget {
  const EnterMovementView({
    required this.type,
    required this.screenType,
    super.key,
  });

  final CategoryType type;
  final MovementScreenType screenType;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return BlocBuilder<EnterMovementCubit, EnterMovementState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Text(appBarTitle(l10n)),
          centerTitle: true,
          notificationPredicate: (notification) => false,
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              spacing: 20,
              children: [
                AppTextField(
                  label: l10n.movementTitle,
                  hintText: l10n.movementTitleHint,
                  errorText: l10n.movementTitleError,
                  onChanged: context.read<EnterMovementCubit>().titleChanged,
                  prefix: const Icon(Icons.title),
                  initialValue: state.title,
                  maxLength: 50,
                ),
                AppTextField(
                  label: l10n.movementDescription,
                  hintText: l10n.movementDescriptionHint,
                  errorText: l10n.movementDescriptionError,
                  onChanged:
                      context.read<EnterMovementCubit>().descriptionChanged,
                  prefix: const Icon(Icons.description),
                  initialValue: state.description,
                  maxLines: 6,
                  maxLength: 250,
                ),
                AppDateField(
                  label: l10n.movementDate,
                  initialDate: state.date!,
                  onDateChanged: context.read<EnterMovementCubit>().dateChanged,
                ),
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
                  onSelected:
                      context.read<EnterMovementCubit>().categoryChanged,
                ),
                AppTextField(
                  label: l10n.movementAmount,
                  hintText: l10n.movementAmountHint,
                  errorText: l10n.movementAmountError,
                  onChanged: context.read<EnterMovementCubit>().priceChanged,
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
                AppTextField(
                  label: l10n.movementCompany,
                  hintText: l10n.movementCompanyHint,
                  isRequired: false,
                  onChanged: context.read<EnterMovementCubit>().companyChanged,
                  prefix: const Icon(Icons.business),
                  initialValue: state.company,
                  maxLength: 50,
                ),
              ],
            ),
          ),
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
