import 'dart:async';
import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:expressive_kit/expressive_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart'
    show TargetPlatform, Uint8List, defaultTargetPlatform, kIsWeb;
import 'package:flutter/services.dart'
    show MethodChannel, MissingPluginException;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mime/mime.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:uuid/uuid.dart';

class HomeView extends StatelessWidget {
  const new({required this.categories, super.key});

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

        return MultiBlocProvider(
          providers: [
            BlocProvider(create: (_) => ExpensesHomeCubit()..init()),
            BlocProvider(create: (_) => SummaryHomeCubit()),
            BlocProvider(create: (_) => IncomeHomeCubit()..init()),
          ],
          child: _ShareIntentListener(
            categories: categories,
            child: BlocBuilder<HomeCubit, HomeState>(
              builder: (context, state) => Scaffold(
                appBar: ExpressiveTopAppBar(
                  showBackButton: false,
                  title: _getAppBarTitle(
                    context,
                    selectedIndex: state.selectedIndex,
                    darkTheme: darkTheme,
                  ),
                  leading: Center(
                    child: ExpressiveIconButton.circle(
                      icon: const HugeIcon(
                        icon: HugeIcons.strokeRoundedSettings02,
                        strokeWidth: 2,
                      ),
                      onPressed: () =>
                          context.pushNamed(AppRoute.settings.name),
                    ),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        icon: snapshot.data?.photoURL == null
                            ? Container(
                                width: 34,
                                height: 34,
                                foregroundDecoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
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
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary,
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
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            HugeIcon(
                                              icon: HugeIcons.strokeRoundedUser,
                                              strokeWidth: 2,
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .primary,
                                            ),
                                  ),
                                ),
                              ),
                        onPressed: () =>
                            context.pushNamed(AppRoute.profile.name),
                      ),
                    ),
                  ],
                ),
                body: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: AnimatedSwitcher(
                      duration: AppVariables.animationDuration,
                      transitionBuilder: (child, animation) =>
                          FadeTransition(opacity: animation, child: child),
                      child: _getSelectedBody(state.selectedIndex),
                    ),
                  ),
                ),
                bottomNavigationBar: const BottomNavigationBarHome(),
                floatingActionButton: _getFloatingActionButton(
                  context,
                  state.selectedIndex,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _getAppBarTitle(
    BuildContext context, {
    required int selectedIndex,
    required bool darkTheme,
  }) {
    switch (selectedIndex) {
      case 0:
        return BlocBuilder<ExpensesHomeCubit, ExpensesHomeState>(
          builder: (context, expensesState) {
            if (expensesState.monthSelected == null) {
              return const SizedBox.shrink();
            }
            return _buildMonthSelectorPill(
              context,
              monthSelected: expensesState.monthSelected!,
              onBack: () => context.read<ExpensesHomeCubit>().previousMonth(),
              onForward: () => context.read<ExpensesHomeCubit>().nextMonth(),
              onChangeMonth: context.read<ExpensesHomeCubit>().changeMonth,
            );
          },
        );
      case 2:
        return BlocBuilder<SummaryHomeCubit, SummaryHomeState>(
          builder: (context, summaryState) {
            final isYear = summaryState.periodType.isYear;
            final startDate = isYear
                ? summaryState.startYear
                : summaryState.startMonth;
            final endDate = isYear
                ? summaryState.endYear
                : summaryState.endMonth;
            if (startDate == null || endDate == null) {
              return const SizedBox.shrink();
            }
            return _buildMonthRangePill(
              context,
              startMonth: startDate,
              endMonth: endDate,
              isYear: isYear,
              onChangeStartMonth: (date) => isYear
                  ? context.read<SummaryHomeCubit>().changeStartYear(date)
                  : context.read<SummaryHomeCubit>().changeStartMonth(date),
              onChangeEndMonth: (date) => isYear
                  ? context.read<SummaryHomeCubit>().changeEndYear(date)
                  : context.read<SummaryHomeCubit>().changeEndMonth(date),
            );
          },
        );
      case 3:
        return BlocBuilder<IncomeHomeCubit, IncomeHomeState>(
          builder: (context, incomeState) {
            if (incomeState.monthSelected == null) {
              return const SizedBox.shrink();
            }
            return _buildMonthSelectorPill(
              context,
              monthSelected: incomeState.monthSelected!,
              onBack: () => context.read<IncomeHomeCubit>().previousMonth(),
              onForward: () => context.read<IncomeHomeCubit>().nextMonth(),
              onChangeMonth: context.read<IncomeHomeCubit>().changeMonth,
            );
          },
        );
      default:
        return Image.asset(
          darkTheme
              ? 'assets/images/logo-no-bg-dark.png'
              : 'assets/images/logo-no-bg-light.png',
          height: 35,
        );
    }
  }

  Widget _buildMonthSelectorPill(
    BuildContext context, {
    required DateTime monthSelected,
    required VoidCallback onBack,
    required VoidCallback onForward,
    required void Function(DateTime?) onChangeMonth,
  }) {
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );
    final previousMonth = monthSelected.month == 1
        ? DateTime(monthSelected.year - 1, 12)
        : DateTime(monthSelected.year, monthSelected.month - 1);
    final backEnabled =
        previousMonth.isAfter(AppVariables.minDate) ||
        previousMonth.isAtSameMomentAs(AppVariables.minDate);
    final nextMonth = monthSelected.month == 12
        ? DateTime(monthSelected.year + 1)
        : DateTime(monthSelected.year, monthSelected.month + 1);
    final forwardEnabled = nextMonth.isBefore(DateTime.now());

    return ExpressiveCard(
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      borderRadius: BorderRadius.circular(25),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ExpressiveIconButton.circle(
            size: ExpressiveIconButtonSize.small,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowLeft01,
              size: 20,
            ),
            onPressed: backEnabled ? onBack : null,
          ),
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () async {
              final picked = await ExpressiveDatePicker.showMonthPicker(
                context: context,
                initialDate: monthSelected,
                firstDate: AppVariables.minDate,
                lastDate: DateTime.now(),
                locale: language,
              );
              if (picked != null) {
                onChangeMonth(picked);
              }
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  DateFormat(
                    'MMM yyyy',
                    language.toString(),
                  ).format(monthSelected).capitalize(),
                  style: Theme.of(context).textTheme.titleMedium,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          ExpressiveIconButton.circle(
            size: ExpressiveIconButtonSize.small,
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedArrowRight01,
              size: 20,
            ),
            onPressed: forwardEnabled ? onForward : null,
          ),
        ],
      ),
    );
  }

  Widget _buildMonthRangePill(
    BuildContext context, {
    required DateTime startMonth,
    required DateTime endMonth,
    required bool isYear,
    required void Function(DateTime?) onChangeStartMonth,
    required void Function(DateTime?) onChangeEndMonth,
  }) {
    final language = context.select<AppCubit, Locale>(
      (cubit) => cubit.state.language,
    );

    return FittedBox(
      fit: BoxFit.scaleDown,
      child: ExpressiveCard(
        margin: EdgeInsets.zero,
        borderRadius: BorderRadius.circular(25),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        onTap: () async {
          final value = isYear
              ? await ExpressiveDatePicker.showYearRangePicker(
                  context: context,
                  initialStartDate: startMonth,
                  initialEndDate: endMonth,
                  firstDate: AppVariables.minDate,
                  lastDate: DateTime.now(),
                  locale: language,
                )
              : await ExpressiveDatePicker.showMonthRangePicker(
                  context: context,
                  initialStartDate: startMonth,
                  initialEndDate: endMonth,
                  firstDate: AppVariables.minDate,
                  lastDate: DateTime.now(),
                  locale: language,
                );
          if (value != null) {
            onChangeStartMonth(value.start);
            onChangeEndMonth(value.end);
          }
        },
        child: Row(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Text(
              isYear
                  ? '${startMonth.year}'
                  : DateFormat(
                      'MMM yyyy',
                      language.toString(),
                    ).format(startMonth).capitalize(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text('-', style: Theme.of(context).textTheme.titleMedium),
            Text(
              isYear
                  ? '${endMonth.year}'
                  : DateFormat(
                      'MMM yyyy',
                      language.toString(),
                    ).format(endMonth).capitalize(),
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget? _getFloatingActionButton(BuildContext context, int selectedIndex) {
    final l10n = AppLocalizations.of(context);
    switch (selectedIndex) {
      case 0:
        return ExpressiveFab(
          onPressed: () => showExpressiveModalBottomSheet<void>(
            context: context,
            title: l10n.homeAddExpense,
            builder: (modalContext) => AddMovementBottomSheet(
              categories: categories,
              movementType: CategoryType.expense,
            ),
          ),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedAdd01,
            strokeWidth: 2,
          ),
        );
      case 3:
        return ExpressiveFab(
          onPressed: () => showExpressiveModalBottomSheet<void>(
            context: context,
            title: l10n.homeAddIncome,
            builder: (modalContext) => AddMovementBottomSheet(
              categories: categories,
              movementType: CategoryType.income,
            ),
          ),
          icon: const HugeIcon(
            icon: HugeIcons.strokeRoundedAdd01,
            strokeWidth: 2,
          ),
        );
      default:
        return null;
    }
  }

  Widget _getSelectedBody(int selectedIndex) {
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
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) => ExpressiveNavigationBar(
        selectedIndex: state.selectedIndex,
        onDestinationSelected: (index) =>
            context.read<HomeCubit>().toggleSelectedIndex(index),
        destinations: [
          ExpressiveNavigationDestination(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedMoneyRemove01,
              strokeWidth: 2,
            ),
            label: l10n.homeExpensesTitle,
          ),
          ExpressiveNavigationDestination(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedTaskDaily01,
              strokeWidth: 2,
            ),
            label: l10n.homeMovementsTitle,
          ),
          ExpressiveNavigationDestination(
            icon: const HugeIcon(
              icon: HugeIcons.strokeRoundedChart02,
              strokeWidth: 2,
            ),
            label: l10n.homeSummaryTitle,
          ),
          ExpressiveNavigationDestination(
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

class _ShareIntentListener extends StatefulWidget {
  const new({required this.categories, required this.child});

  final List<Category> categories;
  final Widget child;

  @override
  State<_ShareIntentListener> createState() => _ShareIntentListenerState();
}

class _ShareIntentListenerState extends State<_ShareIntentListener> {
  StreamSubscription<SharedFile>? _shareSubscription;
  bool _isProcessingShare = false;

  @override
  void initState() {
    super.initState();
    if (kIsWeb || !getIt.isRegistered<ShareIntentService>()) return;

    final shareService = getIt<ShareIntentService>();
    _shareSubscription = shareService.sharedFileStream.listen(
      (sharedFile) => unawaited(_handleSharedFile(sharedFile)),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final pending = shareService.consumePendingSharedFile();
      if (pending != null) {
        unawaited(_handleSharedFile(pending));
      }
    });
  }

  @override
  void dispose() {
    unawaited(_shareSubscription?.cancel());
    super.dispose();
  }

  Future<void> _handleSharedFile(SharedFile sharedFile) async {
    if (_isProcessingShare || !mounted || !sharedFile.isSupported) return;
    _isProcessingShare = true;

    try {
      final router = GoRouter.maybeOf(context);
      if (router != null && router.canPop()) {
        while (router.canPop()) {
          router.pop();
        }
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
      }

      final targetIndex = sharedFile.movementType.isExpense ? 0 : 3;
      final homeCubit = context.read<HomeCubit>();
      if (homeCubit.state.selectedIndex != targetIndex) {
        homeCubit.toggleSelectedIndex(targetIndex);
      }

      await AddMovementBottomSheet(
        categories: widget.categories,
        movementType: sharedFile.movementType,
      ).handleFilePick(context, sharedFile: sharedFile, closeSheet: false);
    } finally {
      _isProcessingShare = false;
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class AddMovementBottomSheet extends StatelessWidget {
  const new({required this.categories, required this.movementType, super.key});

  static const _documentScannerChannel = MethodChannel(
    'com.pmorales.saver.expense.manager/document_scanner',
  );

  final List<Category> categories;
  final CategoryType movementType;

  Future<bool> _isGmsDocumentScannerAvailable() async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return true;
    }
    try {
      return await _documentScannerChannel.invokeMethod<bool>(
            'isGmsScannerAvailable',
          ) ??
          true;
    } on MissingPluginException {
      return true;
    }
  }

  Future<void> handleFilePick(
    BuildContext context, {
    SharedFile? sharedFile,
    bool closeSheet = true,
  }) async {
    final l10n = AppLocalizations.of(context);
    final language = context.read<AppCubit>().state.language;
    final selectedCategories = categories
        .where((c) => c.type == movementType)
        .toList();
    final loader = AppLoader(context);

    try {
      final String fileName;
      final Future<Uint8List> Function() readBytes;

      if (sharedFile != null) {
        fileName = sharedFile.name.isNotEmpty
            ? sharedFile.name
            : sharedFile.path.split('/').last;
        readBytes = sharedFile.bytes != null
            ? () async => sharedFile.bytes!
            : () => File(sharedFile.path).readAsBytes();
      } else {
        final file = await FilePicker.pickFile(
          type: FileType.custom,
          allowedExtensions: AppVariables.allowedExtensions,
        );

        if (file == null) return;
        fileName = file.name;
        readBytes = file.readAsBytes;
      }

      unawaited(loader.showLoading(message: l10n.checkInternetConnection));

      final hasInternet = await AppFunctions.hasInternetConnection();
      final modelType = hasInternet ? ModelType.cloud : ModelType.local;

      if (loader.isLoading) {
        loader.hideLoading();
      }

      unawaited(
        loader.showLoading(
          message: modelType.isCloud
              ? l10n.usingModelCloud
              : l10n.usingModelLocal,
        ),
      );

      getIt<CrashService>().setCustomKey(
        'file_pick_model_type',
        modelType.name,
      );
      getIt<CrashService>().setCustomKey('movement_type', movementType.name);
      getIt<AnalyticsService>().logEvent(
        name: 'receipt_ai_extraction',
        parameters: {
          'source': sharedFile != null ? 'share' : 'file',
          'model_type': modelType.name,
          'movement_type': movementType.value,
        },
      );

      final ext = fileName.split('.').last.toLowerCase();
      if (sharedFile != null && !AppVariables.allowedExtensions.contains(ext)) {
        throw Exception('UNSUPPORTED_FILE_EXTENSION');
      }
      if (modelType.isLocal && !AppVariables.imageExtensions.contains(ext)) {
        throw Exception(AppVariables.unsupportedLocalModelFile);
      }

      final userId = getIt<AuthService>().currentUser?.uid ?? 'anonymous';
      final path = 'users/$userId/attachments/${const Uuid().v4()}.$ext';
      final bytes = await readBytes();
      if (sharedFile != null &&
          sharedFile.bytes == null &&
          sharedFile.path.contains('shared_files')) {
        try {
          File(sharedFile.path).deleteSync();
        } on Object catch (_) {}
      }
      final mimeType =
          lookupMimeType(fileName, headerBytes: bytes) ??
          (AppVariables.imageExtensions.contains(ext)
              ? 'image/$ext'
              : 'application/pdf');

      final performance = getIt<PerformanceService>();
      final trace = performance.startTrace('receipt_processing_file');

      String? uploadName;
      Movement? movement;
      try {
        final uploadFuture = () async {
          final uploadTrace = performance.startTrace('receipt_upload_file');
          try {
            return await getIt<RemoteStorageService>().uploadFile(bytes, path);
          } finally {
            performance.stopTrace(uploadTrace);
          }
        }();

        final aiFuture = () async {
          final aiTrace = performance.startTrace('receipt_ai_processing_file');
          try {
            return await AppFunctions.buildMovementFromFile(
              movementType: movementType,
              categories: selectedCategories,
              language: language.toString(),
              mimeType: mimeType,
              bytes: bytes,
              modelType: modelType,
            );
          } finally {
            performance.stopTrace(aiTrace);
          }
        }();

        try {
          final result = await (uploadFuture, aiFuture).wait;
          uploadName = result.$1;
          movement = result.$2;
          if (uploadName == null) {
            throw Exception(AppVariables.attachmentUploadError);
          }
        } on Object catch (_) {
          unawaited(
            uploadFuture
                .timeout(
                  AppVariables.storageTimeoutDuration,
                  onTimeout: () => null,
                )
                .then((uploaded) {
                  if (uploaded != null) {
                    unawaited(getIt<RemoteStorageService>().deleteFile(path));
                  }
                })
                .catchError((Object _) {}),
          );
          rethrow;
        }
      } finally {
        performance.stopTrace(trace);
      }

      if (loader.isLoading) {
        loader.hideLoading();
      }
      if (!context.mounted) return;
      if (closeSheet) {
        Navigator.of(context).pop();
      }
      unawaited(
        context.pushNamed(
          AppRoute.movement.name,
          pathParameters: {
            'type': movementType.value,
            'screenType': MovementScreenType.add.name.toUpperCase(),
          },
          extra: movement.copyWith(attachments: [uploadName]),
        ),
      );
    } on Object catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AddMovementBottomSheet handleFilePick error',
      );
      if (loader.isLoading) {
        loader.hideLoading();
      }
      if (!context.mounted) return;
      if (closeSheet) {
        Navigator.of(context).pop();
      }
      if (e.toString().contains(AppVariables.unsupportedLocalModelFile)) {
        AppFunctions.showSnackBar(
          context,
          message: l10n.invalidLocalModelFileInput,
          type: SnackBarType.error,
        );
      } else if (e.toString().contains(AppVariables.attachmentUploadError) ||
          (e is ParallelWaitError &&
              e.errors is (Object?, Object?) &&
              (e.errors! as (Object?, Object?)).$1 != null)) {
        AppFunctions.showSnackBar(
          context,
          message: l10n.documentUploadError,
          type: SnackBarType.error,
        );
      } else {
        AppFunctions.showSnackBar(
          context,
          message: l10n.documentAiError,
          type: SnackBarType.error,
        );
      }
    }
  }

  Future<void> handleDocumentScan(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final language = context.read<AppCubit>().state.language;
    final selectedCategories = categories
        .where((c) => c.type == movementType)
        .toList();
    final loader = AppLoader(context);

    try {
      final isGmsAvailable = await _isGmsDocumentScannerAvailable();
      final scanResult = await CunningDocumentScanner.scanDocuments(
        noOfPages: 1,
        scannerSource: isGmsAvailable
            ? ScannerSource.camera
            : ScannerSource.gallery,
      );
      final files = scanResult?.images ?? [];

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
          message: modelType.isCloud
              ? l10n.usingModelCloud
              : l10n.usingModelLocal,
        ),
      );

      getIt<CrashService>().setCustomKey(
        'document_scan_model_type',
        modelType.name,
      );
      getIt<CrashService>().setCustomKey('movement_type', movementType.name);
      getIt<AnalyticsService>().logEvent(
        name: 'receipt_ai_extraction',
        parameters: {
          'source': 'scan',
          'model_type': modelType.name,
          'movement_type': movementType.value,
        },
      );

      final ext = files.first.split('.').last.toLowerCase();
      if (modelType.isLocal && !AppVariables.imageExtensions.contains(ext)) {
        throw Exception(AppVariables.unsupportedLocalModelFile);
      }

      final userId = getIt<AuthService>().currentUser?.uid ?? 'anonymous';
      final path = 'users/$userId/attachments/${const Uuid().v4()}.$ext';
      final bytes = await File(files.first).readAsBytes();
      final mimeType =
          lookupMimeType(files.first, headerBytes: bytes) ??
          (AppVariables.imageExtensions.contains(ext)
              ? 'image/$ext'
              : 'application/pdf');

      final performance = getIt<PerformanceService>();
      final trace = performance.startTrace('receipt_processing_scan');

      String? uploadName;
      Movement? movement;
      try {
        final uploadFuture = () async {
          final uploadTrace = performance.startTrace('receipt_upload_scan');
          try {
            return await getIt<RemoteStorageService>().uploadFile(bytes, path);
          } finally {
            performance.stopTrace(uploadTrace);
          }
        }();

        final aiFuture = () async {
          final aiTrace = performance.startTrace('receipt_ai_processing_scan');
          try {
            return await AppFunctions.buildMovementFromFile(
              movementType: movementType,
              categories: selectedCategories,
              language: language.toString(),
              mimeType: mimeType,
              bytes: bytes,
              modelType: modelType,
            );
          } finally {
            performance.stopTrace(aiTrace);
          }
        }();

        try {
          final result = await (uploadFuture, aiFuture).wait;
          uploadName = result.$1;
          movement = result.$2;
          if (uploadName == null) {
            throw Exception(AppVariables.attachmentUploadError);
          }
        } on Object catch (_) {
          unawaited(
            uploadFuture
                .timeout(
                  AppVariables.storageTimeoutDuration,
                  onTimeout: () => null,
                )
                .then((uploaded) {
                  if (uploaded != null) {
                    unawaited(getIt<RemoteStorageService>().deleteFile(path));
                  }
                })
                .catchError((Object _) {}),
          );
          rethrow;
        }
      } finally {
        performance.stopTrace(trace);
      }

      if (loader.isLoading) {
        loader.hideLoading();
      }
      if (!context.mounted) return;
      Navigator.of(context).pop();
      unawaited(
        context.pushNamed(
          AppRoute.movement.name,
          pathParameters: {
            'type': movementType.value,
            'screenType': MovementScreenType.add.name.toUpperCase(),
          },
          extra: movement.copyWith(attachments: [uploadName]),
        ),
      );
    } on Object catch (e, stackTrace) {
      getIt<CrashService>().recordError(
        e,
        stackTrace,
        reason: 'AddMovementBottomSheet handleDocumentScan error',
      );
      if (loader.isLoading) {
        loader.hideLoading();
      }
      if (!context.mounted) return;
      Navigator.of(context).pop();
      if (e.toString().contains(AppVariables.unsupportedLocalModelFile)) {
        AppFunctions.showSnackBar(
          context,
          message: l10n.invalidLocalModelFileInput,
          type: SnackBarType.error,
        );
      } else if (e.toString().contains(AppVariables.attachmentUploadError) ||
          (e is ParallelWaitError &&
              e.errors is (Object?, Object?) &&
              (e.errors! as (Object?, Object?)).$1 != null)) {
        AppFunctions.showSnackBar(
          context,
          message: l10n.documentUploadError,
          type: SnackBarType.error,
        );
      } else {
        AppFunctions.showSnackBar(
          context,
          message: l10n.documentAiError,
          type: SnackBarType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        spacing: 10,
        children: [
          TonalButtonActionHome(
            title: l10n.homeFile,
            icon: HugeIcons.strokeRoundedUpload04,
            onPressed: () => handleFilePick(context),
          ),
          if (!kIsWeb)
            TonalButtonActionHome(
              title: l10n.homeScan,
              icon: HugeIcons.strokeRoundedCamera01,
              onPressed: () => handleDocumentScan(context),
            ),
          TonalButtonActionHome(
            title: l10n.homeEnter,
            icon: HugeIcons.strokeRoundedEdit02,
            onPressed: () {
              getIt<AnalyticsService>().logEvent(
                name: 'add_movement_method',
                parameters: {
                  'method': 'manual',
                  'movement_type': movementType.value,
                },
              );
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
    );
  }
}

class TonalButtonActionHome extends StatelessWidget {
  const new({
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
