// ignore_for_file: use_build_context_synchronously // To dismiss bottom sheet

import 'dart:async';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mime/mime.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/expenses_home/expenses_home.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/income_home/income_home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/movement/movement.dart';
import 'package:saver_expense_manager/movements_home/movements_home.dart';
import 'package:saver_expense_manager/profile/profile.dart';
import 'package:saver_expense_manager/settings/settings.dart';
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
    final remoteConfig = getIt<RemoteConfigService>();
    final darkTheme = context.select<AppCubit, String>(
          (cubit) => cubit.state.theme,
        ) ==
        AppVariables.darkTheme;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      initialData: FirebaseAuth.instance.currentUser,
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return const SizedBox.shrink();
        }

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
              leading: IconButton(
                padding: EdgeInsets.zero,
                icon: const HugeIcon(
                  icon: HugeIcons.strokeRoundedSettings02,
                  strokeWidth: 2,
                ),
                onPressed: () => context.pushNamed(SettingsPage.pageName),
              ),
              actions: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: user?.photoURL == null
                      ? Container(
                          width: 34,
                          height: 34,
                          foregroundDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: HugeIcon(
                            icon: HugeIcons.strokeRoundedUser,
                            strokeWidth: 2,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        )
                      : Container(
                          width: 34,
                          height: 34,
                          foregroundDecoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Theme.of(context).colorScheme.primary,
                              width: 2,
                            ),
                          ),
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(17),
                            child: Image.network(
                              AppFunctions.highResPicture(url: user!.photoURL),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  onPressed: () => context.pushNamed(ProfilePage.pageName),
                ),
              ],
              actionsPadding: const EdgeInsets.only(right: 8),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 500),
                  transitionBuilder: (child, animation) =>
                      FadeTransition(opacity: animation, child: child),
                  child: _getSelectedBody(
                    state.selectedIndex,
                    state.movementsShowType,
                  ),
                ),
              ),
            ),
            bottomNavigationBar: const BottomNavigationBarHome(),
            floatingActionButton: _getFloatingActionButton(
              context,
              state.selectedIndex,
              MovementsShowType.fromString(
                remoteConfig.transactionsInitialView,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget? _getFloatingActionButton(
    BuildContext context,
    int selectedIndex,
    MovementsShowType transactionsInitialView,
  ) {
    switch (selectedIndex) {
      case 0:
        return FloatingActionButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (context) => AddMovementBottomSheet(
              categories: categories,
              movementType: CategoryType.expense,
            ),
          ),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedAdd01,
            strokeWidth: 2,
          ),
        );
      case 1:
        return FloatingActionButton(
          onPressed: () {
            context.read<HomeCubit>().toggleMovementsShow();
          },
          child: HugeIcon(
            icon: transactionsInitialView.isList
                ? HugeIcons.strokeRoundedChartAverage
                : HugeIcons.strokeRoundedLeftToRightListTriangle,
            strokeWidth: 2,
          ),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () => showModalBottomSheet<void>(
            context: context,
            builder: (context) => AddMovementBottomSheet(
              categories: categories,
              movementType: CategoryType.income,
            ),
          ),
          child: const HugeIcon(
            icon: HugeIcons.strokeRoundedAdd01,
            strokeWidth: 2,
          ),
        );
      default:
        return null;
    }
  }

  Widget _getSelectedBody(
    int selectedIndex,
    MovementsShowType movementsShowType,
  ) {
    switch (selectedIndex) {
      case 0:
        return const ExpensesHomePage();
      case 1:
        return MovementsHomePage(movementsShowType: movementsShowType);
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
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedMoneyRemove01,
              strokeWidth: 2,
            ),
            label: l10n.homeExpensesTitle,
          ),
          NavigationDestination(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedTaskDaily01,
              strokeWidth: 2,
            ),
            label: l10n.homeMovementsTitle,
          ),
          NavigationDestination(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedMoneyAdd01,
              strokeWidth: 2,
            ),
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
    final l10n = AppLocalizations.of(context);
    final language = context.read<AppCubit>().state.language;
    final selectedCategories =
        categories.where((c) => c.type == movementType).toList();
    final loader = AppLoader(context);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppVariables.allowedExtensions,
    );

    if (result != null) {
      unawaited(loader.showLoading());

      try {
        final file = result.files.single;
        final ext = file.path!.split('.').last;
        final path = '${const Uuid().v4()}.$ext';
        final bytes = await file.xFile.readAsBytes();

        // Upload file to Firebase Storage and build movement from file in
        // parallel
        final uploadTask = getIt<StorageService>().uploadFile(
          File(file.path!),
          path,
        );
        final movementFuture = AppFunctions.buildMovementFromFile(
          movementType: movementType,
          categories: selectedCategories,
          language: language,
          mimeType: lookupMimeType(file.name) ?? 'application/pdf',
          bytes: bytes,
        );

        final results =
            await Future.wait<dynamic>([uploadTask, movementFuture]);
        final uploadName = results[0] as String;
        final movement = results[1] as Movement;

        if (loader.isLoading) {
          loader.hideLoading();
        }
        Navigator.of(context).pop();
        unawaited(
          context.pushNamed(
            MovementPage.pageName,
            pathParameters: {
              'type': movementType.value,
              'screenType': 'ADD',
            },
            extra: movement.copyWith(
              attachments: [uploadName],
            ),
          ),
        );
      } on Exception catch (_) {
        if (loader.isLoading) {
          loader.hideLoading();
        }
        Navigator.of(context).pop();
        AppFunctions.showSnackBar(
          context,
          message: l10n.genericError,
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _handleDocumentScan(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final language = context.read<AppCubit>().state.language;
    final selectedCategories =
        categories.where((c) => c.type == movementType).toList();
    final loader = AppLoader(context);

    final files = await CunningDocumentScanner.getPictures(noOfPages: 1) ?? [];

    if (files.isNotEmpty) {
      unawaited(loader.showLoading());

      try {
        final ext = files.first.split('.').last;
        final path = '${const Uuid().v4()}.$ext';
        final bytes = await File(files.first).readAsBytes();

        // Upload file to Firebase Storage and build movement from file in
        // parallel
        final uploadTask = getIt<StorageService>().uploadFile(
          File(files.first),
          path,
        );
        final movementFuture = AppFunctions.buildMovementFromFile(
          movementType: movementType,
          categories: selectedCategories,
          language: language,
          mimeType: lookupMimeType(files.first) ?? 'application/pdf',
          bytes: bytes,
        );

        final results =
            await Future.wait<dynamic>([uploadTask, movementFuture]);
        final uploadName = results[0] as String;
        final movement = results[1] as Movement;

        if (loader.isLoading) {
          loader.hideLoading();
        }
        Navigator.of(context).pop();
        await context.pushNamed(
          MovementPage.pageName,
          pathParameters: {
            'type': movementType.value,
            'screenType': 'ADD',
          },
          extra: movement.copyWith(
            attachments: [uploadName],
          ),
        );
      } on Exception catch (_) {
        if (loader.isLoading) {
          loader.hideLoading();
        }
        Navigator.of(context).pop();
        AppFunctions.showSnackBar(
          context,
          message: l10n.genericError,
          type: SnackBarType.error,
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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        spacing: 16,
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
                icon: HugeIcons.strokeRoundedUpload04,
                onPressed: () => _handleFilePick(context),
              ),
              TonalButtonActionHome(
                title: l10n.homeScan,
                icon: HugeIcons.strokeRoundedCamera01,
                onPressed: () => _handleDocumentScan(context),
              ),
              TonalButtonActionHome(
                title: l10n.homeEnter,
                icon: HugeIcons.strokeRoundedEdit02,
                onPressed: () {
                  Navigator.of(context).pop();
                  unawaited(
                    context.pushNamed(
                      MovementPage.pageName,
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
  final List<List<dynamic>> icon;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: SizedBox(
        height: 100,
        child: FilledButton.tonal(
          style: ButtonStyle(
            shape: WidgetStateProperty.all(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            padding: WidgetStateProperty.all(const EdgeInsets.all(10)),
          ),
          onPressed: onPressed,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            spacing: 5,
            children: [
              HugeIcon(icon: icon, size: 40),
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
