// ignore_for_file: use_build_context_synchronously // To dismiss bottom sheet

import 'dart:async';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mime/mime.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:uuid/uuid.dart';

class HomeView extends StatelessWidget {
  const HomeView({
    required this.categories,
    super.key,
  });

  final List<Category> categories;

  @override
  Widget build(BuildContext context) {
    final auth = getIt<AuthService>();
    final darkTheme = Theme.of(context).brightness == Brightness.dark;

    return StreamBuilder<AppUser?>(
      stream: auth.authStateChanges,
      initialData: auth.currentUser,
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
                onPressed: () => context.pushNamed(AppRoute.settings.name),
              ),
              actions: [
                IconButton(
                  padding: EdgeInsets.zero,
                  icon: snapshot.data?.photoURL == null
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
                              AppFunctions.highResPicture(
                                url: snapshot.data!.photoURL,
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                  onPressed: () => context.pushNamed(AppRoute.profile.name),
                ),
              ],
              actionsPadding: const EdgeInsets.only(right: 8),
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: AnimatedSwitcher(
                  duration: AppVariables.animationDuration,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                  child: _getSelectedBody(
                    state.selectedIndex,
                  ),
                ),
              ),
            ),
            bottomNavigationBar: const BottomNavigationBarHome(),
            floatingActionButton:
                _getFloatingActionButton(context, state.selectedIndex),
          ),
        );
      },
    );
  }

  Widget? _getFloatingActionButton(
    BuildContext context,
    int selectedIndex,
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
      case 3:
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
  ) {
    switch (selectedIndex) {
      case 0:
        return const ExpensesHomePage();
      case 1:
        return const MovementsHomePage();
      case 2:
        return const SummaryHomePage();
      case 3:
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
              icon: HugeIcons.strokeRoundedChart02,
              strokeWidth: 2,
            ),
            label: l10n.homeSummaryTitle,
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

  Future<void> handleFilePick(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final language = context.read<AppCubit>().state.language;
    final selectedCategories =
        categories.where((c) => c.type == movementType).toList();
    final loader = AppLoader(context);

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: AppVariables.allowedExtensions,
    );

    if (result == null) {
      return;
    }

    unawaited(loader.showLoading(message: l10n.checkInternetConnection));

    final hasInternet = await AppFunctions.hasInternetConnection();
    final modelType = hasInternet ? ModelType.cloud : ModelType.local;

    if (loader.isLoading) {
      loader.hideLoading();
    }

    unawaited(
      loader.showLoading(
        message:
            modelType.isCloud ? l10n.usingModelCloud : l10n.usingModelLocal,
      ),
    );

    getIt<CrashService>().setCustomKey('file_pick_model_type', modelType.name);
    getIt<CrashService>().setCustomKey('movement_type', movementType.name);

    try {
      if (modelType.isLocal &&
          !AppVariables.imageExtensions
              .contains(result.files.first.extension)) {
        throw Exception(AppVariables.unsupportedLocalModelFile);
      }

      final file = result.files.single;
      final ext = file.path!.split('.').last;
      final path = '${const Uuid().v4()}.$ext';
      final bytes = file.bytes ?? await File(file.path!).readAsBytes();

      final performance = getIt<PerformanceService>();
      final trace = performance.startTrace('receipt_processing_file');
      // Upload file to Firebase Storage and build movement from file in
      // parallel
      final uploadTask = getIt<RemoteStorageService>().uploadFile(
        File(file.path!),
        path,
      );
      final movementFuture = AppFunctions.buildMovementFromFile(
        movementType: movementType,
        categories: selectedCategories,
        language: language.toString(),
        mimeType: lookupMimeType(file.name) ?? 'application/pdf',
        bytes: bytes,
        modelType: modelType,
      );

      final results = await Future.wait<dynamic>([uploadTask, movementFuture]);
      performance.stopTrace(trace);
      final uploadName = results[0] as String?;
      final movement = results[1] as Movement;

      if (loader.isLoading) {
        loader.hideLoading();
      }
      Navigator.of(context).pop();
      unawaited(
        context.pushNamed(
          AppRoute.movement.name,
          pathParameters: {
            'type': movementType.value,
            'screenType': MovementScreenType.add.name.toUpperCase(),
          },
          extra: movement.copyWith(
            attachments: uploadName != null ? [uploadName] : [],
          ),
        ),
      );
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AddMovementBottomSheet handleFilePick error',
      );
      if (loader.isLoading) {
        loader.hideLoading();
      }
      Navigator.of(context).pop();
      if (e.toString().contains(AppVariables.unsupportedLocalModelFile)) {
        AppFunctions.showSnackBar(
          context,
          message: l10n.invalidLocalModelFileInput,
          type: SnackBarType.error,
        );
      } else {
        AppFunctions.showSnackBar(
          context,
          message: l10n.genericError,
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> handleDocumentScan(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final language = context.read<AppCubit>().state.language;
    final selectedCategories =
        categories.where((c) => c.type == movementType).toList();
    final loader = AppLoader(context);

    final files = await CunningDocumentScanner.getPictures(noOfPages: 1) ?? [];

    if (files.isEmpty) {
      return;
    }

    unawaited(loader.showLoading(message: l10n.checkInternetConnection));

    final hasInternet = await AppFunctions.hasInternetConnection();
    final modelType = hasInternet ? ModelType.cloud : ModelType.local;

    if (loader.isLoading) {
      loader.hideLoading();
    }

    unawaited(
      loader.showLoading(
        message:
            modelType.isCloud ? l10n.usingModelCloud : l10n.usingModelLocal,
      ),
    );

    getIt<CrashService>()
        .setCustomKey('document_scan_model_type', modelType.name);
    getIt<CrashService>().setCustomKey('movement_type', movementType.name);

    try {
      if (modelType.isLocal &&
          !AppVariables.imageExtensions.contains(files.first.split('.').last)) {
        throw Exception(AppVariables.unsupportedLocalModelFile);
      }

      final ext = files.first.split('.').last;
      final path = '${const Uuid().v4()}.$ext';
      final bytes = await File(files.first).readAsBytes();

      final performance = getIt<PerformanceService>();
      final trace = performance.startTrace('receipt_processing_scan');
      // Upload file to Firebase Storage and build movement from file in
      // parallel
      final uploadTask = getIt<RemoteStorageService>().uploadFile(
        File(files.first),
        path,
      );
      final movementFuture = AppFunctions.buildMovementFromFile(
        movementType: movementType,
        categories: selectedCategories,
        language: language.toString(),
        mimeType: lookupMimeType(files.first) ?? 'application/pdf',
        bytes: bytes,
        modelType: modelType,
      );

      final results = await Future.wait<dynamic>([uploadTask, movementFuture]);
      performance.stopTrace(trace);
      final uploadName = results[0] as String?;
      final movement = results[1] as Movement;

      if (loader.isLoading) {
        loader.hideLoading();
      }
      Navigator.of(context).pop();
      unawaited(
        context.pushNamed(
          AppRoute.movement.name,
          pathParameters: {
            'type': movementType.value,
            'screenType': MovementScreenType.add.name.toUpperCase(),
          },
          extra: movement.copyWith(
            attachments: uploadName != null ? [uploadName] : [],
          ),
        ),
      );
    } on Exception catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AddMovementBottomSheet handleDocumentScan error',
      );
      if (loader.isLoading) {
        loader.hideLoading();
      }
      Navigator.of(context).pop();
      if (e.toString().contains(AppVariables.unsupportedLocalModelFile)) {
        AppFunctions.showSnackBar(
          context,
          message: l10n.invalidLocalModelFileInput,
          type: SnackBarType.error,
        );
      } else {
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
                onPressed: () => handleFilePick(context),
              ),
              TonalButtonActionHome(
                title: l10n.homeScan,
                icon: HugeIcons.strokeRoundedCamera01,
                onPressed: () => handleDocumentScan(context),
              ),
              TonalButtonActionHome(
                title: l10n.homeEnter,
                icon: HugeIcons.strokeRoundedEdit02,
                onPressed: () {
                  Navigator.of(context).pop();
                  unawaited(
                    context.pushNamed(
                      AppRoute.movement.name,
                      pathParameters: {
                        'type': movementType.value,
                        'screenType': MovementScreenType.add.name.toUpperCase(),
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
