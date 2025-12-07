// ignore_for_file: use_build_context_synchronously // To dismiss bottom sheet

import 'dart:async';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mime/mime.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:user_api/user_api.dart';
import 'package:uuid/uuid.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    required this.categories,
    super.key,
  });

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final darkTheme = context.select<AppCubit, bool>(
      (cubit) => cubit.state.darkTheme!,
    );

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => Scaffold(
        appBar: AppBar(
          title: Image.asset(
            darkTheme
                ? 'assets/images/logo-no-bg-dark.png'
                : 'assets/images/logo-no-bg-light.png',
            height: 35,
          ),
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
                    categories: categories,
                    movementType: _getMovementType(state.selectedIndex),
                  ),
                ),
                child: const Icon(Icons.add),
              )
            : null,
      ),
    );
  }

  CategoryType _getMovementType(int selectedIndex) {
    switch (selectedIndex) {
      case 0:
        return CategoryType.expense;
      case 2:
        return CategoryType.income;
      default:
        return CategoryType.expense;
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
  const AddMovementBottomSheet({
    required this.categories,
    required this.movementType,
    super.key,
  });

  final List<Category> categories;
  final CategoryType movementType;

  Future<void> _handleFilePick(BuildContext context) async {
    final locale = context.read<AppCubit>().state.locale!;
    final model = context.read<AppCubit>().model;
    final selectedCategories =
        categories.where((c) => c.type == movementType).toList();
    final loader = AppLoader(context);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'png', 'jpg', 'jpeg'],
    );

    if (result != null) {
      unawaited(loader.showLoading());

      try {
        final file = result.files.single;
        final ext = file.path!.split('.').last;
        final ref = FirebaseStorage.instance.ref().child(
              '${const Uuid().v4()}.$ext',
            );
        final bytes = await file.xFile.readAsBytes();

        // Upload file to Firebase Storage and build movement from file in
        // parallel
        final uploadTask = ref.putFile(File(file.path!));
        final movementFuture = buildMovementFromFile(
          model: model,
          movementType: movementType,
          categories: selectedCategories,
          languageCode: locale.languageCode,
          mimeType: lookupMimeType(file.name) ?? 'application/pdf',
          bytes: bytes,
        );

        final results =
            await Future.wait<dynamic>([uploadTask, movementFuture]);
        final uploadSnapshot = results[0] as TaskSnapshot;
        final movement = results[1] as Movement;

        if (loader.isLoading) {
          loader.hideLoading();
        }
        Navigator.of(context).pop();
        unawaited(
          context.pushNamed(
            'movement',
            pathParameters: {
              'type': movementType.value,
              'screenType': 'ADD',
            },
            extra: movement.copyWith(
              attachments: [uploadSnapshot.ref.name],
            ),
          ),
        );
      } on Exception catch (e) {
        if (loader.isLoading) {
          loader.hideLoading();
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            closeIconColor: Theme.of(context).colorScheme.onError,
          ),
        );
      }
    }
  }

  Future<void> _handleDocumentScan(BuildContext context) async {
    final locale = context.read<AppCubit>().state.locale!;
    final model = context.read<AppCubit>().model;
    final selectedCategories =
        categories.where((c) => c.type == movementType).toList();
    final loader = AppLoader(context);

    final files = await CunningDocumentScanner.getPictures(noOfPages: 1) ?? [];

    if (files.isNotEmpty) {
      unawaited(loader.showLoading());

      try {
        final ext = files.first.split('.').last;
        final ref = FirebaseStorage.instance.ref().child(
              '${const Uuid().v4()}.$ext',
            );
        final bytes = await File(files.first).readAsBytes();

        // Upload file to Firebase Storage and build movement from file in
        // parallel
        final uploadTask = ref.putFile(File(files.first));
        final movementFuture = buildMovementFromFile(
          model: model,
          movementType: movementType,
          categories: selectedCategories,
          languageCode: locale.languageCode,
          mimeType: lookupMimeType(files.first) ?? 'application/pdf',
          bytes: bytes,
        );

        final results =
            await Future.wait<dynamic>([uploadTask, movementFuture]);
        final uploadSnapshot = results[0] as TaskSnapshot;
        final movement = results[1] as Movement;

        if (loader.isLoading) {
          loader.hideLoading();
        }
        Navigator.of(context).pop();
        await context.pushNamed(
          'movement',
          pathParameters: {
            'type': movementType.value,
            'screenType': 'ADD',
          },
          extra: movement.copyWith(
            attachments: [uploadSnapshot.ref.name],
          ),
        );
      } on Exception catch (e) {
        if (loader.isLoading) {
          loader.hideLoading();
        }
        ScaffoldMessenger.of(context).clearSnackBars();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              e.toString(),
              style: TextStyle(color: Theme.of(context).colorScheme.onError),
            ),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
            closeIconColor: Theme.of(context).colorScheme.onError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

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
            movementType == CategoryType.expense
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
                onPressed: () => _handleFilePick(context),
              ),
              TonalButtonActionHome(
                title: l10n.homeScan,
                icon: Icons.document_scanner,
                onPressed: () => _handleDocumentScan(context),
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
                        'type': movementType.value,
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
