import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:expressive_kit/expressive_kit.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

import '../../helpers/helpers.dart';

class MockAuthService extends Mock implements AuthService;

class MockAppCubit extends MockCubit<AppState> implements AppCubit;

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit;

class MockAppUser extends Mock implements AppUser;

class MockDatabaseService extends Mock implements DatabaseService;

class MockRemoteConfigService extends Mock implements RemoteConfigService;

class MockLocalStorageService extends Mock implements LocalStorageService;

class MockTrace extends Mock implements Trace;

class MockRemoteStorageService extends Mock implements RemoteStorageService;

class MockPerformanceService extends Mock implements PerformanceService;

class MockCrashService extends Mock implements CrashService;

class MockAiService extends Mock implements AiService;

class MockAnalyticsService extends Mock implements AnalyticsService;

class MockShareIntentService extends Mock implements ShareIntentService;

void main() {
  late MockAuthService mockAuthService;
  late MockAppCubit mockAppCubit;
  late MockHomeCubit mockHomeCubit;
  late MockAppUser mockAppUser;
  late MockDatabaseService mockDatabaseService;
  late MockRemoteConfigService mockRemoteConfigService;
  late MockLocalStorageService mockLocalStorageService;
  late MockRemoteStorageService mockRemoteStorageService;
  late MockPerformanceService mockPerformanceService;
  late MockCrashService mockCrashService;
  late MockAiService mockAiService;
  late MockAnalyticsService mockAnalyticsService;
  late MockTrace mockTrace;

  setUpAll(() {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('flutter.baseflow.com/permissions/methods'),
      (message) async {
        if (message.method == 'requestPermissions') {
          final result = <int, int>{};
          for (var i = 0; i < 40; i++) {
            result[i] = 1;
          }
          return result;
        }
        if (message.method == 'checkPermissionStatus') {
          return 1;
        }
        return null;
      },
    );
    registerFallbackValue(DateTime.now());
    registerFallbackValue(CategoryType.expense);
    registerFallbackValue(
      const PromptPart(type: PromptPartType.text, text: ''),
    );
    registerFallbackValue(<PromptPart>[]);
    registerFallbackValue(MockTrace());
    registerFallbackValue(FileType.custom);
    registerFallbackValue(ModelType.cloud);
    registerFallbackValue(File(''));
    registerFallbackValue(Uint8List(0));
    AppVariables.useTestFonts = true;
    Intl.defaultLocale = 'en_US';
    unawaited(initializeDateFormatting('en_US'));
  });

  setUp(() {
    mockAuthService = MockAuthService();
    mockAppCubit = MockAppCubit();
    mockHomeCubit = MockHomeCubit();
    mockAppUser = MockAppUser();
    mockDatabaseService = MockDatabaseService();
    mockRemoteConfigService = MockRemoteConfigService();
    mockLocalStorageService = MockLocalStorageService();
    mockRemoteStorageService = MockRemoteStorageService();
    mockPerformanceService = MockPerformanceService();
    mockCrashService = MockCrashService();
    mockAiService = MockAiService();
    mockAnalyticsService = MockAnalyticsService();
    mockTrace = MockTrace();

    getIt
      ..registerSingleton<AuthService>(mockAuthService)
      ..registerSingleton<DatabaseService>(mockDatabaseService)
      ..registerSingleton<RemoteConfigService>(mockRemoteConfigService)
      ..registerSingleton<LocalStorageService>(mockLocalStorageService)
      ..registerSingleton<RemoteStorageService>(mockRemoteStorageService)
      ..registerSingleton<PerformanceService>(mockPerformanceService)
      ..registerSingleton<CrashService>(mockCrashService)
      ..registerSingleton<AiService>(mockAiService)
      ..registerSingleton<AnalyticsService>(mockAnalyticsService);

    when(
      () => mockAnalyticsService.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) {});

    when(() => mockAppCubit.state).thenReturn(const AppState());
    when(() => mockHomeCubit.state)
        .thenReturn(const HomeState(selectedIndex: 0));

    when(() => mockAppUser.photoURL).thenReturn(null);
    when(() => mockAppUser.uid).thenReturn('user123');
    when(() => mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(mockAppUser));
    when(() => mockAuthService.currentUser).thenReturn(mockAppUser);

    when(() => mockDatabaseService.getCategoriesStream())
        .thenAnswer((_) => Stream.value([]));
    when(
      () => mockDatabaseService.getMovementsStream(
        userId: any<String>(named: 'userId'),
        startDate: any<DateTime?>(named: 'startDate'),
        endDate: any<DateTime?>(named: 'endDate'),
        type: any<CategoryType?>(named: 'type'),
        categoryId: any<String?>(named: 'categoryId'),
        limit: any<int>(named: 'limit'),
        orderByDate: any<bool>(named: 'orderByDate'),
      ),
    ).thenAnswer((_) => Stream.value([]));

    when(() => mockRemoteConfigService.geminiPromptExtractReceiptData)
        .thenReturn('prompt');
    when(() => mockRemoteConfigService.summaryLastMonths).thenReturn(4);
    when(() => mockRemoteConfigService.summaryLastYears).thenReturn(2);
    when(() => mockRemoteConfigService.paginationLimit).thenReturn(10);
    when(() => mockAiService.isLocalModelAvailable).thenReturn(true);
    when(
      () => mockAiService.generateContentRemote(
        prompt: any<List<PromptPart>>(named: 'prompt'),
        responseMimeType: any<String>(named: 'responseMimeType'),
      ),
    ).thenAnswer(
      (_) async =>
          '{"date": "01/01/2024", "title": "Test", "price": 10.0, '
          '"category": "Test"}',
    );
    when(() => mockPerformanceService.startTrace(any<String>()))
        .thenReturn(mockTrace);
    when(() => mockPerformanceService.stopTrace(any<Trace>())).thenReturn(null);
    when(() => mockCrashService.setCustomKey(any<String>(), any()))
        .thenReturn(null);
    when(
      () => mockCrashService.recordError(
        any<Object>(),
        any<StackTrace?>(),
        reason: any<String?>(named: 'reason'),
      ),
    ).thenAnswer((_) async {});
  });

  tearDown(() async {
    AppFunctions.internetConnectionTestValue = null;
    await getIt.reset();
  });

  Future<void> pumpRouterSubject(
    WidgetTester tester, {
    List<Category>? categories,
  }) async {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => HomeView(categories: categories ?? []),
        ),
        GoRoute(
          path: '/settings',
          name: AppRoute.settings.name,
          builder: (context, state) =>
              const Scaffold(body: Text('Settings Page')),
        ),
        GoRoute(
          path: '/profile',
          name: AppRoute.profile.name,
          builder: (context, state) =>
              const Scaffold(body: Text('Profile Page')),
        ),
        GoRoute(
          path: '/movement/:type/:screenType',
          name: AppRoute.movement.name,
          builder: (context, state) =>
              const Scaffold(body: Text('Movement Page')),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp.router(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routerConfig: router,
        builder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider<AppCubit>.value(value: mockAppCubit),
            BlocProvider<HomeCubit>.value(value: mockHomeCubit),
          ],
          child: child!,
        ),
      ),
    );
  }

  Future<void> pumpSubject(
    WidgetTester tester, {
    List<Category>? categories,
    ThemeData? theme,
  }) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        builder: (context, child) => MultiBlocProvider(
          providers: [
            BlocProvider<AppCubit>.value(value: mockAppCubit),
            BlocProvider<HomeCubit>.value(value: mockHomeCubit),
          ],
          child: child!,
        ),
        home: HomeView(categories: categories ?? []),
      ),
    );
  }

  group('HomeView', () {
    testWidgets('renders properly with initial state', (tester) async {
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();
        expect(find.byType(BottomNavigationBarHome), findsOneWidget);
        expect(find.byType(ExpressiveFab), findsOneWidget);
      });
    });

    testWidgets('renders SizedBox.shrink when user is null', (tester) async {
      when(() => mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(null));
      when(() => mockAuthService.currentUser).thenReturn(null);
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();
        expect(find.byType(SizedBox), findsWidgets);
        expect(find.byType(Scaffold), findsNothing);
      });
    });

    testWidgets('renders network image for user with photoURL', (tester) async {
      when(() => mockAppUser.photoURL)
          .thenReturn('https://example.com/photo.png');
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();
        expect(find.byType(Image), findsWidgets);
      });
    });

    testWidgets('navigates to settings on settings icon tap', (tester) async {
      await mockNetworkImagesFor(() async {
        await pumpRouterSubject(tester);
        await tester.pumpAndSettle();
        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is HugeIcon &&
                widget.icon == HugeIcons.strokeRoundedSettings02,
          ),
        );
        await tester.pumpAndSettle();
        expect(find.text('Settings Page'), findsOneWidget);
      });
    });

    testWidgets('navigates to profile on profile icon tap', (tester) async {
      when(() => mockAppUser.photoURL)
          .thenReturn('https://example.com/photo.png');
      await mockNetworkImagesFor(() async {
        await pumpRouterSubject(tester);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(IconButton).last);
        await tester.pumpAndSettle();
        expect(find.text('Profile Page'), findsOneWidget);
      });
    });

    testWidgets('toggles selected index on bottom navigation bar tap', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        await tester.tap(
          find.byWidgetPredicate(
            (widget) =>
                widget is HugeIcon &&
                widget.icon == HugeIcons.strokeRoundedTaskDaily01,
          ),
        );
        await tester.pumpAndSettle();
        verify(() => mockHomeCubit.toggleSelectedIndex(1)).called(1);
      });
    });

    testWidgets('renders body pages depending on selectedIndex', (
      tester,
    ) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 0));
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();
        expect(find.byType(ExpensesHomePage), findsOneWidget);
        expect(find.byType(ExpressiveFab), findsOneWidget);
      });
    });

    testWidgets(
      'AddMovementBottomSheet uses correct movement type for Income',
      (tester) async {
        when(() => mockHomeCubit.state)
            .thenReturn(const HomeState(selectedIndex: 3));
        await mockNetworkImagesFor(() async {
          await pumpSubject(tester);
          await tester.pumpAndSettle();
          await tester.tap(find.byType(ExpressiveFab));
          await tester.pumpAndSettle();
          final bottomSheet = tester.widget<AddMovementBottomSheet>(
            find.byType(AddMovementBottomSheet),
          );
          expect(bottomSheet.movementType, equals(CategoryType.income));
        });
      },
    );

    testWidgets('handleFilePick handles successful pick', (tester) async {
      await tester.runAsync(() async {
        final tempFile = File('/tmp/test.png');
        if (!tempFile.existsSync()) {
          tempFile
            ..createSync(recursive: true)
            ..writeAsBytesSync([1, 2, 3]);
        }

        final mockFilePicker = MockFilePicker();
        FilePickerPlatform.instance = mockFilePicker;

        final mockFile = FakePlatformFile(
          name: 'test.png',
          path: '/tmp/test.png',
          bytes: Uint8List.fromList([1, 2, 3]),
        );

        whenPickFile(mockFilePicker).thenAnswer((_) async => mockFile);

        when(
          () => mockRemoteStorageService.uploadFile(
            any<Uint8List>(),
            any<String>(),
          ),
        ).thenAnswer((_) async => 'upload_name');

        AppFunctions.internetConnectionTestValue = true;
        when(() => mockAppCubit.state).thenReturn(const AppState());

        const testCategories = [
          Category(
            id: '1',
            name: 'Test',
            type: CategoryType.expense,
            icon: '',
            color: '',
          ),
        ];

        await mockNetworkImagesFor(() async {
          await pumpRouterSubject(tester, categories: testCategories);
          await tester.pumpAndSettle();

          await tester.tap(find.byType(ExpressiveFab));
          await tester.pumpAndSettle();

          await tester.tap(find.text('File'));

          for (var i = 0; i < 15; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            await tester.pump(const Duration(milliseconds: 500));
          }

          expect(find.byType(AddMovementBottomSheet), findsNothing);
        });
      });
    });

    testWidgets(
      'navigates to explicit given route on manually entering AddMovement',
      (tester) async {
        await mockNetworkImagesFor(() async {
          await pumpRouterSubject(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.byType(ExpressiveFab));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Enter'));
          await tester.pumpAndSettle();

          expect(find.byType(AddMovementBottomSheet), findsNothing);
          expect(find.text('Movement Page'), findsOneWidget);
          verify(
            () => mockAnalyticsService.logEvent(
              name: 'add_movement_method',
              parameters: {'method': 'manual', 'movement_type': 'EXPENSE'},
            ),
          ).called(1);
        });
      },
    );

    testWidgets('handleFilePick handles null result', (tester) async {
      final mockFilePicker = MockFilePicker();
      FilePickerPlatform.instance = mockFilePicker;

      whenPickFile(mockFilePicker).thenAnswer((_) async => null);

      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ExpressiveFab));
        await tester.pumpAndSettle();

        await tester.tap(find.text('File'));
        await tester.pumpAndSettle();

        expect(find.byType(AddMovementBottomSheet), findsOneWidget);
      });
    });

    testWidgets('handleFilePick handles generic exception', (tester) async {
      final mockFilePicker = MockFilePicker();
      FilePickerPlatform.instance = mockFilePicker;

      whenPickFile(mockFilePicker).thenThrow(Exception('Test error'));

      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ExpressiveFab));
        await tester.pumpAndSettle();

        await tester.tap(find.text('File'));

        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }

        expect(find.byType(SnackBar, skipOffstage: false), findsOneWidget);
        verify(
          () => mockCrashService.recordError(
            any<Object>(),
            any<StackTrace?>(),
            reason: any<String?>(named: 'reason'),
          ),
        ).called(1);
      });
    });

    testWidgets('handleFilePick handles unsupported file exception', (
      tester,
    ) async {
      final mockFilePicker = MockFilePicker();
      FilePickerPlatform.instance = mockFilePicker;

      whenPickFile(mockFilePicker)
          .thenThrow(Exception(AppVariables.unsupportedLocalModelFile));

      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ExpressiveFab));
        await tester.pumpAndSettle();

        await tester.tap(find.text('File'));

        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }

        expect(find.byType(SnackBar), findsOneWidget);
      });
    });

    testWidgets('handleDocumentScan handles successful scan', (tester) async {
      await tester.runAsync(() async {
        final tempFile = File('/tmp/test_scan.png');
        if (!tempFile.existsSync()) {
          tempFile
            ..createSync(recursive: true)
            ..writeAsBytesSync([1, 2, 3]);
        }

        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('cunning_document_scanner'),
          (message) async {
            if (message.method == 'scanDocuments' ||
                message.method == 'getPictures') {
              return {
                'images': ['/tmp/test_scan.png'],
              };
            }
            return null;
          },
        );

        when(
          () => mockRemoteStorageService.uploadFile(
            any<Uint8List>(),
            any<String>(),
          ),
        ).thenAnswer((_) async => 'upload_name');

        AppFunctions.internetConnectionTestValue = true;

        await mockNetworkImagesFor(() async {
          await pumpRouterSubject(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.byType(ExpressiveFab));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Scan'));

          await Future<void>.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          expect(find.byType(AddMovementBottomSheet), findsNothing);
          expect(find.text('Movement Page'), findsOneWidget);
          verify(
            () => mockAnalyticsService.logEvent(
              name: 'receipt_ai_extraction',
              parameters: {
                'source': 'scan',
                'model_type': 'CLOUD',
                'movement_type': 'EXPENSE',
              },
            ),
          ).called(1);
        });
      });
    });

    testWidgets('handleDocumentScan does nothing when list is empty', (
      tester,
    ) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('cunning_document_scanner'),
        (message) async {
          if (message.method == 'scanDocuments' ||
              message.method == 'getPictures') {
            return {'images': <String>[]};
          }
          return null;
        },
      );

      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ExpressiveFab));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Scan'));
        await tester.pumpAndSettle();

        expect(find.byType(AddMovementBottomSheet), findsOneWidget);
      });
    });

    testWidgets('handleDocumentScan handles generic exception', (tester) async {
      await tester.runAsync(() async {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('cunning_document_scanner'),
          (message) async {
            if (message.method == 'scanDocuments' ||
                message.method == 'getPictures') {
              throw PlatformException(code: 'error', message: 'Test error');
            }
            return null;
          },
        );

        await mockNetworkImagesFor(() async {
          await pumpSubject(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.byType(ExpressiveFab));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Scan'));

          for (var i = 0; i < 5; i++) {
            await Future<void>.delayed(const Duration(milliseconds: 100));
            await tester.pump(const Duration(milliseconds: 500));
          }

          expect(find.byType(SnackBar), findsOneWidget);
        });
      });
    });

    testWidgets(
      'handleFilePick catches ParallelWaitError and cleans up uploaded file',
      (tester) async {
        await tester.runAsync(() async {
          final tempFile = File('/tmp/test_err.png');
          if (!tempFile.existsSync()) {
            tempFile
              ..createSync(recursive: true)
              ..writeAsBytesSync([1, 2, 3]);
          }

          final mockFilePicker = MockFilePicker();
          FilePickerPlatform.instance = mockFilePicker;

          final mockFile = FakePlatformFile(
            name: 'test_err.png',
            path: '/tmp/test_err.png',
            bytes: Uint8List.fromList([1, 2, 3]),
          );

          whenPickFile(mockFilePicker).thenAnswer((_) async => mockFile);

          when(
            () => mockRemoteStorageService.uploadFile(
              any<Uint8List>(),
              any<String>(),
            ),
          ).thenAnswer((_) async => 'upload_name');
          when(() => mockRemoteStorageService.deleteFile(any<String>()))
              .thenAnswer((_) async => true);
          when(
            () => mockAiService.generateContentRemote(
              prompt: any<List<PromptPart>>(named: 'prompt'),
              responseMimeType: any<String>(named: 'responseMimeType'),
            ),
          ).thenThrow(Exception('AI failed'));

          AppFunctions.internetConnectionTestValue = true;

          await mockNetworkImagesFor(() async {
            await pumpSubject(tester);
            await tester.pumpAndSettle();

            await tester.tap(find.byType(ExpressiveFab));
            await tester.pumpAndSettle();

            await tester.tap(find.text('File'));

            for (var i = 0; i < 10; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 100));
              await tester.pump(const Duration(milliseconds: 500));
            }

            expect(find.byType(SnackBar, skipOffstage: false), findsOneWidget);
            verify(() => mockRemoteStorageService.deleteFile(any<String>()))
                .called(1);
            verify(() => mockPerformanceService.stopTrace(mockTrace)).called(3);
          });
        });
      },
    );

    testWidgets(
      'handleDocumentScan handles unsupported file exception locally',
      (tester) async {
        await tester.runAsync(() async {
          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            const MethodChannel('cunning_document_scanner'),
            (message) async {
              if (message.method == 'scanDocuments' ||
                  message.method == 'getPictures') {
                return {
                  'images': ['/tmp/test.pdf'],
                };
              }
              return null;
            },
          );

          AppFunctions.internetConnectionTestValue = false;

          await mockNetworkImagesFor(() async {
            await pumpSubject(tester);
            await tester.pumpAndSettle();

            await tester.tap(find.byType(ExpressiveFab));
            await tester.pumpAndSettle();

            await tester.tap(find.text('Scan'));

            for (var i = 0; i < 5; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 100));
              await tester.pump(const Duration(milliseconds: 500));
            }

            expect(find.byType(SnackBar), findsOneWidget);
          });
        });
      },
    );

    testWidgets(
      'handleFilePick shows error snackbar and does not navigate when '
      'uploadFile fails',
      (tester) async {
        await tester.runAsync(() async {
          final tempFile = File('/tmp/test_fail.png');
          if (!tempFile.existsSync()) {
            tempFile
              ..createSync(recursive: true)
              ..writeAsBytesSync([1, 2, 3]);
          }

          final mockFilePicker = MockFilePicker();
          FilePickerPlatform.instance = mockFilePicker;

          final mockFile = FakePlatformFile(
            name: 'test_fail.PNG',
            path: '/tmp/test_fail.png',
            bytes: Uint8List.fromList([1, 2, 3]),
          );

          whenPickFile(mockFilePicker).thenAnswer((_) async => mockFile);

          when(
            () => mockRemoteStorageService.uploadFile(
              any<Uint8List>(),
              any<String>(),
            ),
          ).thenAnswer((_) async => null);

          AppFunctions.internetConnectionTestValue = true;
          when(() => mockAppCubit.state).thenReturn(const AppState());

          await mockNetworkImagesFor(() async {
            await pumpRouterSubject(tester);
            await tester.pumpAndSettle();

            await tester.tap(find.byType(ExpressiveFab));
            await tester.pumpAndSettle();

            await tester.tap(find.text('File'));

            for (var i = 0; i < 15; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 100));
              await tester.pump(const Duration(milliseconds: 500));
            }

            expect(find.byType(AddMovementBottomSheet), findsNothing);
            expect(find.text('Movement Page'), findsNothing);
            expect(find.byType(SnackBar, skipOffstage: false), findsOneWidget);
            verify(
              () => mockRemoteStorageService.uploadFile(
                any<Uint8List>(),
                any<String>(),
              ),
            ).called(1);
          });
        });
      },
    );

    testWidgets(
      'handleDocumentScan shows error snackbar and does not navigate when '
      'uploadFile fails',
      (tester) async {
        await tester.runAsync(() async {
          final tempFile = File('/tmp/test_scan_fail.png');
          if (!tempFile.existsSync()) {
            tempFile
              ..createSync(recursive: true)
              ..writeAsBytesSync([1, 2, 3]);
          }

          tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
            const MethodChannel('cunning_document_scanner'),
            (message) async {
              if (message.method == 'scanDocuments' ||
                  message.method == 'getPictures') {
                return {
                  'images': ['/tmp/test_scan_fail.png'],
                };
              }
              return null;
            },
          );

          when(
            () => mockRemoteStorageService.uploadFile(
              any<Uint8List>(),
              any<String>(),
            ),
          ).thenAnswer((_) async => null);

          AppFunctions.internetConnectionTestValue = true;

          await mockNetworkImagesFor(() async {
            await pumpRouterSubject(tester);
            await tester.pumpAndSettle();

            await tester.tap(find.byType(ExpressiveFab));
            await tester.pumpAndSettle();

            await tester.tap(find.text('Scan'));

            await Future<void>.delayed(const Duration(seconds: 1));
            await tester.pumpAndSettle();

            expect(find.byType(AddMovementBottomSheet), findsNothing);
            expect(find.text('Movement Page'), findsNothing);
            expect(find.byType(SnackBar, skipOffstage: false), findsOneWidget);
            verify(
              () => mockRemoteStorageService.uploadFile(
                any<Uint8List>(),
                any<String>(),
              ),
            ).called(1);
          });
        });
      },
    );

    testWidgets('profile image errorBuilder renders fallback user icon', (
      tester,
    ) async {
      when(() => mockAppUser.photoURL)
          .thenReturn('https://example.com/photo.png');
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        final imageFinder = find.byType(Image).first;
        final image = tester.widget<Image>(imageFinder);
        final element = tester.element(imageFinder);
        final fallback = image.errorBuilder!(
          element,
          Exception('Load failed'),
          StackTrace.empty,
        );
        expect(fallback, isA<HugeIcon>());
      });
    });

    testWidgets('AppBar MonthSelector callbacks update month on Expenses tab', (
      tester,
    ) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 0));
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        final backArrow = find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon &&
              widget.icon == HugeIcons.strokeRoundedArrowLeft01,
        );
        final forwardArrow = find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon &&
              widget.icon == HugeIcons.strokeRoundedArrowRight01,
        );
        await tester.tap(backArrow);
        await tester.pump();
        await tester.tap(forwardArrow);
        await tester.pump();

        expect(find.byType(ExpensesHomePage), findsOneWidget);
      });
    });

    testWidgets('AppBar MonthSelector callbacks update month on Income tab', (
      tester,
    ) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 3));
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        expect(find.byType(IncomeHomePage), findsOneWidget);
        final backArrow = find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon &&
              widget.icon == HugeIcons.strokeRoundedArrowLeft01,
        );
        final forwardArrow = find.byWidgetPredicate(
          (widget) =>
              widget is HugeIcon &&
              widget.icon == HugeIcons.strokeRoundedArrowRight01,
        );
        await tester.tap(backArrow);
        await tester.pump();
        await tester.tap(forwardArrow);
        await tester.pump();
      });
    });

    testWidgets('renders Movements tab in light and dark theme with logo', (
      tester,
    ) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 1));
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        expect(find.byType(MovementsHomePage), findsOneWidget);
        final lightImage = tester.widget<Image>(find.byType(Image).first);
        expect(
          (lightImage.image as AssetImage).assetName,
          equals('assets/images/logo-no-bg-light.png'),
        );

        await pumpSubject(tester, theme: ThemeData.dark());
        await tester.pumpAndSettle();

        final darkImage = tester.widget<Image>(find.byType(Image).first);
        expect(
          (darkImage.image as AssetImage).assetName,
          equals('assets/images/logo-no-bg-dark.png'),
        );
      });
    });

    testWidgets('renders empty body for unknown selectedIndex', (tester) async {
      var stateReads = 0;
      when(() => mockHomeCubit.state).thenAnswer(
        (_) => stateReads++ == 0
            ? const HomeState(selectedIndex: 99)
            : const HomeState(selectedIndex: 0),
      );
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        expect(find.byType(ExpensesHomePage), findsNothing);
        expect(find.byType(MovementsHomePage), findsNothing);
        expect(find.byType(SummaryHomePage), findsNothing);
        expect(find.byType(IncomeHomePage), findsNothing);
        expect(find.byType(ExpressiveFab), findsNothing);
      });
    });

    testWidgets('Summary tab MonthRangeSelector handles month and year modes', (
      tester,
    ) async {
      const testCategories = [
        Category(
          id: '1',
          name: 'Food',
          type: CategoryType.expense,
          icon: '',
          color: '#FF0000',
        ),
      ];
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 2));
      when(() => mockDatabaseService.getCategoriesStream())
          .thenAnswer((_) => Stream.value(testCategories));

      await mockNetworkImagesFor(() async {
        await pumpSubject(tester, categories: testCategories);
        await tester.pumpAndSettle();

        expect(find.byType(SummaryHomePage), findsOneWidget);
        await tester.tap(find.text('-').first);
        await tester.pumpAndSettle();
        expect(find.byType(ExpressiveDatePickerDialog), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();

        tester
            .element(find.byType(SummaryHomePage))
            .read<SummaryHomeCubit>()
            .changePeriodType(SummaryPeriodType.year);
        await tester.pump();

        await tester.tap(find.text('-').first);
        await tester.pumpAndSettle();
        expect(find.byType(ExpressiveDatePickerDialog), findsOneWidget);
        await tester.tap(find.text('OK'));
        await tester.pumpAndSettle();
      });
    });

    testWidgets('tapping drag handle dismisses AddMovementBottomSheet', (
      tester,
    ) async {
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ExpressiveFab));
        await tester.pumpAndSettle();
        expect(find.byType(AddMovementBottomSheet), findsOneWidget);

        final handle = find
            .descendant(
              of: find.byType(AddMovementBottomSheet),
              matching: find.byType(GestureDetector),
            )
            .first;
        await tester.tap(handle);
        await tester.pumpAndSettle();

        expect(find.byType(AddMovementBottomSheet), findsNothing);
      });
    });

    testWidgets(
      'handleFilePick uses local model and rejects non-image locally',
      (tester) async {
        final mockFilePicker = MockFilePicker();
        FilePickerPlatform.instance = mockFilePicker;

        final mockFile = FakePlatformFile(
          name: 'test.pdf',
          path: '/tmp/test.pdf',
          bytes: Uint8List.fromList([1, 2, 3]),
        );

        whenPickFile(mockFilePicker).thenAnswer((_) async => mockFile);
        AppFunctions.internetConnectionTestValue = false;

        await mockNetworkImagesFor(() async {
          await pumpSubject(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.byType(ExpressiveFab));
          await tester.pumpAndSettle();

          await tester.tap(find.text('File'));
          for (var i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 500));
          }

          verify(
            () =>
                mockCrashService.setCustomKey('file_pick_model_type', 'LOCAL'),
          ).called(1);
          expect(
            find.text('Invalid file type for Gemini Nano'),
            findsOneWidget,
          );
        });
      },
    );

    testWidgets(
      'handleFilePick uses fallback mimeType for unknown file extension',
      (tester) async {
        await tester.runAsync(() async {
          final mockFilePicker = MockFilePicker();
          FilePickerPlatform.instance = mockFilePicker;

          final mockFile = FakePlatformFile(
            name: 'test.unknown',
            path: '/tmp/test.unknown',
            bytes: Uint8List.fromList([1, 2, 3]),
          );

          whenPickFile(mockFilePicker).thenAnswer((_) async => mockFile);
          when(
            () => mockRemoteStorageService.uploadFile(
              any<Uint8List>(),
              any<String>(),
            ),
          ).thenAnswer((_) async => 'upload_name');

          AppFunctions.internetConnectionTestValue = true;

          await mockNetworkImagesFor(() async {
            await pumpRouterSubject(tester);
            await tester.pumpAndSettle();

            await tester.tap(find.byType(ExpressiveFab));
            await tester.pumpAndSettle();

            await tester.tap(find.text('File'));

            for (var i = 0; i < 15; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 100));
              await tester.pump(const Duration(milliseconds: 500));
            }

            expect(find.byType(AddMovementBottomSheet), findsNothing);
            expect(find.text('Movement Page'), findsOneWidget);
          });
        });
      },
    );

    Future<void> triggerDocumentScan(
      WidgetTester tester, {
      required String filePath,
      bool useRouter = false,
    }) async {
      final tempFile = File(filePath);
      if (!tempFile.existsSync()) {
        tempFile
          ..createSync(recursive: true)
          ..writeAsBytesSync([1, 2, 3]);
      }

      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('cunning_document_scanner'),
        (message) async {
          if (message.method == 'scanDocuments' ||
              message.method == 'getPictures') {
            return {
              'images': [filePath],
            };
          }
          return null;
        },
      );

      await mockNetworkImagesFor(() async {
        if (useRouter) {
          await pumpRouterSubject(tester);
        } else {
          await pumpSubject(tester);
        }
        await tester.pumpAndSettle();

        await tester.tap(find.byType(ExpressiveFab));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Scan'));

        for (var i = 0; i < 10; i++) {
          await Future<void>.delayed(const Duration(milliseconds: 100));
          await tester.pump(const Duration(milliseconds: 500));
        }
      });
    }

    testWidgets(
      'handleDocumentScan uses fallback mimeType for unknown extension',
      (tester) async {
        await tester.runAsync(() async {
          when(
            () => mockRemoteStorageService.uploadFile(
              any<Uint8List>(),
              any<String>(),
            ),
          ).thenAnswer((_) async => 'upload_name');

          AppFunctions.internetConnectionTestValue = true;

          await triggerDocumentScan(
            tester,
            filePath: '/tmp/test_scan.unknown',
            useRouter: true,
          );

          expect(find.byType(AddMovementBottomSheet), findsNothing);
          expect(find.text('Movement Page'), findsOneWidget);
        });
      },
    );

    testWidgets(
      'handleDocumentScan catches ParallelWaitError and deletes uploaded file',
      (tester) async {
        await tester.runAsync(() async {
          when(
            () => mockRemoteStorageService.uploadFile(
              any<Uint8List>(),
              any<String>(),
            ),
          ).thenAnswer((_) async => 'upload_name');
          when(() => mockRemoteStorageService.deleteFile(any<String>()))
              .thenAnswer((_) async => true);
          when(
            () => mockAiService.generateContentRemote(
              prompt: any<List<PromptPart>>(named: 'prompt'),
              responseMimeType: any<String>(named: 'responseMimeType'),
            ),
          ).thenThrow(Exception('AI failed'));

          AppFunctions.internetConnectionTestValue = true;

          await triggerDocumentScan(tester, filePath: '/tmp/test_scan_err.png');

          expect(find.byType(SnackBar, skipOffstage: false), findsOneWidget);
          verify(() => mockRemoteStorageService.deleteFile(any<String>()))
              .called(1);
          verify(() => mockPerformanceService.stopTrace(mockTrace)).called(3);
        });
      },
    );

    testWidgets(
      'handleDocumentScan shows upload error snackbar when uploadFile throws',
      (tester) async {
        await tester.runAsync(() async {
          when(
            () => mockRemoteStorageService.uploadFile(
              any<Uint8List>(),
              any<String>(),
            ),
          ).thenThrow(Exception('Upload failed'));

          AppFunctions.internetConnectionTestValue = true;

          await triggerDocumentScan(
            tester,
            filePath: '/tmp/test_scan_upload_throw.png',
            useRouter: true,
          );

          expect(find.byType(AddMovementBottomSheet), findsNothing);
          expect(find.text('Movement Page'), findsNothing);
          expect(find.text('Error uploading attachment file'), findsOneWidget);
        });
      },
    );
  });

  group('HomeView ShareIntent handling', () {
    late MockShareIntentService mockShareIntentService;

    setUp(() {
      mockShareIntentService = MockShareIntentService();
      getIt.registerSingleton<ShareIntentService>(mockShareIntentService);
      when(() => mockShareIntentService.consumePendingSharedFile())
          .thenReturn(null);
      when(() => mockShareIntentService.sharedFileStream)
          .thenAnswer((_) => const Stream.empty());
    });

    Future<GoRouter> pumpShareRouterSubject(
      WidgetTester tester, {
      required HomeCubit homeCubit,
      List<Category>? categories,
    }) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            name: AppRoute.home.name,
            builder: (context, state) =>
                HomeView(categories: categories ?? const []),
            routes: [
              GoRoute(
                path: 'settings',
                name: AppRoute.settings.name,
                builder: (context, state) =>
                    const Scaffold(body: Text('Settings Page')),
              ),
              GoRoute(
                path: 'movement/:type/:screenType',
                name: AppRoute.movement.name,
                builder: (context, state) => Scaffold(
                  body: Column(
                    children: [
                      Text('Movement:${state.pathParameters['type']}'),
                      ElevatedButton(
                        onPressed: () => context.pop(),
                        child: const Text('Back'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
          builder: (context, child) => MultiBlocProvider(
            providers: [
              BlocProvider<AppCubit>.value(value: mockAppCubit),
              BlocProvider<HomeCubit>.value(value: homeCubit),
            ],
            child: child!,
          ),
        ),
      );
      return router;
    }

    testWidgets(
      'handles cold-start shared expense PDF, switches to expenses tab, '
      'navigates to Movement, and back returns to expenses home',
      (tester) async {
        await tester.runAsync(() async {
          when(() => mockRemoteConfigService.homeInitialTab)
              .thenReturn(AppVariables.summaryTab);
          final realHomeCubit = HomeCubit();

          final sharedFile = SharedFile(
            path: '/tmp/receipt.pdf',
            name: 'receipt.pdf',
            movementType: CategoryType.expense,
            bytes: Uint8List.fromList([0x25, 0x50, 0x44, 0x46]),
          );
          when(() => mockShareIntentService.consumePendingSharedFile())
              .thenReturn(sharedFile);
          when(
            () => mockRemoteStorageService.uploadFile(
              any<Uint8List>(),
              any<String>(),
            ),
          ).thenAnswer((_) async => 'uploaded.pdf');
          AppFunctions.internetConnectionTestValue = true;

          const testCategories = [
            Category(
              id: '1',
              name: 'Test',
              type: CategoryType.expense,
              icon: '',
              color: '',
            ),
          ];

          await mockNetworkImagesFor(() async {
            await pumpShareRouterSubject(
              tester,
              homeCubit: realHomeCubit,
              categories: testCategories,
            );

            for (var i = 0; i < 15; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 50));
              await tester.pump(const Duration(milliseconds: 200));
            }

            expect(find.text('Movement:EXPENSE'), findsOneWidget);
            expect(realHomeCubit.state.selectedIndex, equals(0));
            verify(
              () => mockAnalyticsService.logEvent(
                name: 'receipt_ai_extraction',
                parameters: {
                  'source': 'share',
                  'model_type': 'CLOUD',
                  'movement_type': 'EXPENSE',
                },
              ),
            ).called(1);

            await tester.tap(find.text('Back'));
            await tester.pumpAndSettle();

            expect(find.byType(ExpensesHomePage), findsOneWidget);
            expect(realHomeCubit.state.selectedIndex, equals(0));
          });

          await realHomeCubit.close();
        });
      },
    );

    testWidgets(
      'handles warm-start shared income image from sub-route, switches to '
      'incomes tab, and back returns to incomes home',
      (tester) async {
        await tester.runAsync(() async {
          when(() => mockRemoteConfigService.homeInitialTab)
              .thenReturn(AppVariables.expensesTab);
          final realHomeCubit = HomeCubit();
          final shareController = StreamController<SharedFile>.broadcast();

          when(() => mockShareIntentService.sharedFileStream)
              .thenAnswer((_) => shareController.stream);
          when(
            () => mockRemoteStorageService.uploadFile(
              any<Uint8List>(),
              any<String>(),
            ),
          ).thenAnswer((_) async => 'uploaded.png');
          AppFunctions.internetConnectionTestValue = true;

          const testCategories = [
            Category(
              id: '2',
              name: 'Salary',
              type: CategoryType.income,
              icon: '',
              color: '',
            ),
          ];

          await mockNetworkImagesFor(() async {
            final router = await pumpShareRouterSubject(
              tester,
              homeCubit: realHomeCubit,
              categories: testCategories,
            );
            await tester.pumpAndSettle();

            unawaited(router.pushNamed(AppRoute.settings.name));
            await tester.pumpAndSettle();
            expect(find.text('Settings Page'), findsOneWidget);

            shareController.add(
              SharedFile(
                path: '/tmp/voucher.png',
                name: 'voucher.png',
                movementType: CategoryType.income,
                bytes: Uint8List.fromList([137, 80, 78, 71]),
              ),
            );

            for (var i = 0; i < 15; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 50));
              await tester.pump(const Duration(milliseconds: 200));
            }

            expect(find.text('Movement:INCOME'), findsOneWidget);
            expect(realHomeCubit.state.selectedIndex, equals(3));

            await tester.tap(find.text('Back'));
            await tester.pumpAndSettle();

            expect(find.text('Settings Page'), findsNothing);
            expect(find.byType(IncomeHomePage), findsOneWidget);
            expect(realHomeCubit.state.selectedIndex, equals(3));
          });

          await shareController.close();
          await realHomeCubit.close();
        });
      },
    );

    testWidgets(
      'shows error snackbar and keeps HomeView mounted when shared file fails',
      (tester) async {
        await tester.runAsync(() async {
          when(() => mockRemoteConfigService.homeInitialTab)
              .thenReturn(AppVariables.expensesTab);
          final realHomeCubit = HomeCubit();

          final sharedFile = SharedFile(
            path: '/tmp/receipt.pdf',
            name: 'receipt.pdf',
            movementType: CategoryType.expense,
            bytes: Uint8List.fromList([1, 2, 3]),
          );
          when(() => mockShareIntentService.consumePendingSharedFile())
              .thenReturn(sharedFile);
          AppFunctions.internetConnectionTestValue = false;

          await mockNetworkImagesFor(() async {
            await pumpShareRouterSubject(tester, homeCubit: realHomeCubit);

            for (var i = 0; i < 10; i++) {
              await Future<void>.delayed(const Duration(milliseconds: 50));
              await tester.pump(const Duration(milliseconds: 200));
            }

            expect(find.byType(HomeView), findsOneWidget);
            expect(find.byType(SnackBar, skipOffstage: false), findsOneWidget);
          });

          await realHomeCubit.close();
        });
      },
    );
  });
}
