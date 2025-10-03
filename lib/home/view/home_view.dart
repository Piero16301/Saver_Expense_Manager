import 'dart:async';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mime/mime.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';
import 'package:uuid/uuid.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final categories = context.select<AppCubit, List<Category>>(
      (cubit) => cubit.state.categories,
    );

    if (categories.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Image.asset('assets/images/logo_no_bg.png', height: 35),
          centerTitle: true,
          notificationPredicate: (notification) => false,
          leading: const ChangeThemeButton(),
          actions: [
            IconButton(
              icon: user?.photoURL == null
                  ? const Icon(Icons.person)
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: Image.network(highResPicture(user!.photoURL)!),
                    ),
              onPressed: () => context.pushNamed('profile'),
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: _getSelectedBody(state.selectedIndex),
            ),
          ),
        ),
        bottomNavigationBar: const BottomNavigationBarHome(),
        floatingActionButton: state.selectedIndex != 1
            ? FloatingActionButton(
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  builder: (context) => AddMovementBottomSheet(
                    expenseType: _getExpenseType(state.selectedIndex),
                  ),
                ),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  ExpenseType _getExpenseType(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return ExpenseType.expense;
      case 2:
        return ExpenseType.income;
      default:
        return ExpenseType.expense;
    }
  }

  Widget _getSelectedBody(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return const ExpensesHomePage();
      case 1:
        return const MovementsHomePage();
      case 2:
        return const IncomeHomePage();
      default:
        return const SizedBox.shrink();
    }
  }
}

class BottomNavigationBarHome extends StatelessWidget {
  const BottomNavigationBarHome({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => NavigationBar(
        selectedIndex: state.selectedIndex,
        onDestinationSelected: (index) =>
            context.read<HomeCubit>().toggleSelectedIndex(index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.money_off_outlined),
            selectedIcon: const Icon(Icons.money_off),
            label: l10n.homeExpensesTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.list_alt_outlined),
            selectedIcon: const Icon(Icons.list_alt),
            label: l10n.homeMovementsTitle,
          ),
          NavigationDestination(
            icon: const Icon(Icons.attach_money_outlined),
            selectedIcon: const Icon(Icons.attach_money),
            label: l10n.homeIncomeTitle,
          ),
        ],
      ),
    );
  }
}

class AddMovementBottomSheet extends StatelessWidget {
  const AddMovementBottomSheet({required this.expenseType, super.key});

  final ExpenseType expenseType;

  @override
  Widget build(BuildContext context) {
    final locale = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.locale!,
    );
    final model = context.select<AppCubit, GenerativeModel>(
      (cubit) => cubit.state.model!,
    );
    final categories = context
        .select<AppCubit, List<Category>>((cubit) => cubit.state.categories)
        .toList();
    final l10n = AppLocalizations.of(context);
    final loader = AppLoader(context);

    return Container(
      width: double.infinity,
      height: 250,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 20,
        children: [
          Center(
            child: GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Theme.of(context).buttonTheme.colorScheme!.primary,
                  borderRadius: const BorderRadius.all(Radius.circular(2)),
                ),
              ),
            ),
          ),
          Text(
            expenseType == ExpenseType.expense
                ? l10n.homeAddExpense
                : l10n.homeAddIncome,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          Row(
            spacing: 10,
            children: [
              TonalButtonActionHome(
                title: l10n.homeFile,
                icon: Icons.upload_file,
                onPressed: () async {
                  final result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
                  );
                  if (result != null) {
                    unawaited(loader.showLoading());

                    // Upload file to Firebase Storage
                    final ext = result.files.single.path!.split('.').last;
                    final ref = FirebaseStorage.instance.ref().child(
                      '${const Uuid().v4()}.$ext',
                    );
                    final uploadTask = await ref.putFile(
                      File(result.files.single.path!),
                    );

                    final file = result.files.single;
                    final movement = await buildMovementFromFile(
                      model: model,
                      expenseType: expenseType,
                      categories: categories
                          .where((c) => c.type == CategoryType.expense)
                          .toList(),
                      languageCode: locale.languageCode,
                      mimeType: lookupMimeType(file.name) ?? 'application/pdf',
                      bytes: await file.xFile.readAsBytes(),
                    );

                    if (loader.isLoading) {
                      loader.hideLoading();
                    }

                    // ignore: use_build_context_synchronously // To dismiss bottom sheet
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously // To go to movement page
                    await context.pushNamed(
                      'movement',
                      pathParameters: {
                        'type': expenseType.value,
                        'screenType': 'ADD',
                      },
                      extra: movement.copyWith(
                        attachments: [uploadTask.ref.name],
                      ),
                    );
                  } else {
                    // ignore: use_build_context_synchronously // To dismiss bottom sheet
                    Navigator.of(context).pop();
                  }
                },
              ),
              TonalButtonActionHome(
                title: l10n.homeScan,
                icon: Icons.document_scanner,
                onPressed: () async {
                  final files =
                      await CunningDocumentScanner.getPictures(noOfPages: 1) ??
                      [];
                  if (files.isNotEmpty) {
                    unawaited(loader.showLoading());

                    // Upload file to Firebase Storage
                    final ext = files.first.split('.').last;
                    final ref = FirebaseStorage.instance.ref().child(
                      '${const Uuid().v4()}.$ext',
                    );
                    final uploadTask = await ref.putFile(File(files.first));

                    final movement = await buildMovementFromFile(
                      model: model,
                      expenseType: expenseType,
                      categories: categories
                          .where((c) => c.type == CategoryType.expense)
                          .toList(),
                      languageCode: locale.languageCode,
                      mimeType:
                          lookupMimeType(files.first) ?? 'application/pdf',
                      bytes: await File(files.first).readAsBytes(),
                    );

                    if (loader.isLoading) {
                      loader.hideLoading();
                    }

                    // ignore: use_build_context_synchronously // To dismiss bottom sheet
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously // To go to movement page
                    await context.pushNamed(
                      'movement',
                      pathParameters: {
                        'type': expenseType.value,
                        'screenType': 'ADD',
                      },
                      extra: movement.copyWith(
                        attachments: [uploadTask.ref.name],
                      ),
                    );
                  } else {
                    // ignore: use_build_context_synchronously // To dismiss bottom sheet
                    Navigator.of(context).pop();
                  }
                },
              ),
              TonalButtonActionHome(
                title: l10n.homeEnter,
                icon: Icons.edit,
                onPressed: () {
                  Navigator.of(context).pop();
                  unawaited(
                    context.pushNamed(
                      'movement',
                      pathParameters: {
                        'type': expenseType.value,
                        'screenType': 'ADD',
                      },
                      extra: Movement.empty,
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class TonalButtonActionHome extends StatelessWidget {
  const TonalButtonActionHome({
    required this.title,
    required this.icon,
    this.onPressed,
    super.key,
  });

  final String title;
  final IconData icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 100,
        child: FilledButton.tonal(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            ),
            padding: WidgetStateProperty.all(const EdgeInsets.all(10)),
          ),
          onPressed: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              Icon(icon, size: 40),
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
