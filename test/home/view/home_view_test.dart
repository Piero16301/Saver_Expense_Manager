import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_performance/firebase_performance.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:mocktail/mocktail.dart';
import 'package:network_image_mock/network_image_mock.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

class MockHomeCubit extends MockCubit<HomeState> implements HomeCubit {}

class MockAppUser extends Mock implements AppUser {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockTrace extends Mock implements Trace {}

class MockFilePicker extends Mock
    with MockPlatformInterfaceMixin
    implements FilePicker {}

class MockRemoteStorageService extends Mock implements RemoteStorageService {}

class MockPerformanceService extends Mock implements PerformanceService {}

class MockCrashService extends Mock implements CrashService {}

class MockAiService extends Mock implements AiService {}

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
    mockTrace = MockTrace();

    getIt
      ..registerSingleton<AuthService>(mockAuthService)
      ..registerSingleton<DatabaseService>(mockDatabaseService)
      ..registerSingleton<RemoteConfigService>(mockRemoteConfigService)
      ..registerSingleton<LocalStorageService>(mockLocalStorageService)
      ..registerSingleton<RemoteStorageService>(mockRemoteStorageService)
      ..registerSingleton<PerformanceService>(mockPerformanceService)
      ..registerSingleton<CrashService>(mockCrashService)
      ..registerSingleton<AiService>(mockAiService);

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
    when(() => mockAiService.isLocalModelAvailable).thenReturn(true);
    when(
      () => mockAiService.generateContentRemote(
        prompt: any<List<PromptPart>>(named: 'prompt'),
        responseMimeType: any<String>(named: 'responseMimeType'),
      ),
    ).thenAnswer(
      (_) async => '{"date": "01/01/2024", "title": "Test", "price": 10.0, '
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

  tearDown(getIt.reset);

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
  }) async {
    await tester.pumpWidget(
      MaterialApp(
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
        expect(find.byType(FloatingActionButton), findsOneWidget);
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

    testWidgets('toggles selected index on bottom navigation bar tap',
        (tester) async {
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

    testWidgets('renders body pages depending on selectedIndex',
        (tester) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 0));
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();
        expect(find.byType(ExpensesHomePage), findsOneWidget);
        expect(find.byType(FloatingActionButton), findsOneWidget);
      });
    });

    testWidgets('AddMovementBottomSheet uses correct movement type for Income',
        (tester) async {
      when(() => mockHomeCubit.state)
          .thenReturn(const HomeState(selectedIndex: 3));
      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();
        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();
        final bottomSheet = tester.widget<AddMovementBottomSheet>(
          find.byType(AddMovementBottomSheet),
        );
        expect(bottomSheet.movementType, equals(CategoryType.income));
      });
    });

    testWidgets('handleFilePick handles successful pick', (tester) async {
      await tester.runAsync(() async {
        final tempFile = File('/tmp/test.png');
        if (!tempFile.existsSync()) {
          tempFile
            ..createSync(recursive: true)
            ..writeAsBytesSync([1, 2, 3]);
        }

        final mockFilePicker = MockFilePicker();
        FilePicker.platform = mockFilePicker;

        when(
          () => mockFilePicker.pickFiles(
            type: any<FileType>(named: 'type'),
            allowedExtensions: any<List<String>?>(named: 'allowedExtensions'),
          ),
        ).thenAnswer(
          (_) async => FilePickerResult([
            PlatformFile(
              name: 'test.png',
              size: 100,
              path: '/tmp/test.png',
              bytes: Uint8List.fromList([1, 2, 3]),
            ),
          ]),
        );

        when(
          () => mockRemoteStorageService.uploadFile(any<File>(), any<String>()),
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

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          await tester.tap(find.text('File'));

          for (var i = 0; i < 15; i++) {
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

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Enter'));
        await tester.pumpAndSettle();

        expect(find.byType(AddMovementBottomSheet), findsNothing);
        expect(find.text('Movement Page'), findsOneWidget);
      });
    });

    testWidgets('handleFilePick handles null result', (tester) async {
      final mockFilePicker = MockFilePicker();
      FilePicker.platform = mockFilePicker;

      when(
        () => mockFilePicker.pickFiles(
          type: any<FileType>(named: 'type'),
          allowedExtensions: any<List<String>?>(named: 'allowedExtensions'),
        ),
      ).thenAnswer((_) async => null);

      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('File'));
        await tester.pumpAndSettle();

        expect(find.byType(AddMovementBottomSheet), findsOneWidget);
      });
    });

    testWidgets('handleFilePick handles generic exception', (tester) async {
      final mockFilePicker = MockFilePicker();
      FilePicker.platform = mockFilePicker;

      when(
        () => mockFilePicker.pickFiles(
          type: any<FileType>(named: 'type'),
          allowedExtensions: any<List<String>?>(named: 'allowedExtensions'),
        ),
      ).thenThrow(Exception('Test error'));

      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
        await tester.pumpAndSettle();

        await tester.tap(find.text('File'));

        for (var i = 0; i < 5; i++) {
          await tester.pump(const Duration(milliseconds: 500));
        }

        expect(find.byType(SnackBar), findsOneWidget);
        verify(
          () => mockCrashService.recordError(
            any<Object>(),
            any<StackTrace?>(),
            reason: any<String?>(named: 'reason'),
          ),
        ).called(1);
      });
    });

    testWidgets('handleFilePick handles unsupported file exception',
        (tester) async {
      final mockFilePicker = MockFilePicker();
      FilePicker.platform = mockFilePicker;

      when(
        () => mockFilePicker.pickFiles(
          type: any<FileType>(named: 'type'),
          allowedExtensions: any<List<String>?>(named: 'allowedExtensions'),
        ),
      ).thenThrow(Exception(AppVariables.unsupportedLocalModelFile));

      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
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
            if (message.method == 'getPictures') {
              return ['/tmp/test_scan.png'];
            }
            return null;
          },
        );

        when(
          () => mockRemoteStorageService.uploadFile(any<File>(), any<String>()),
        ).thenAnswer((_) async => 'upload_name');

        AppFunctions.internetConnectionTestValue = true;

        await mockNetworkImagesFor(() async {
          await pumpRouterSubject(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Scan'));

          await Future<void>.delayed(const Duration(seconds: 1));
          await tester.pumpAndSettle();

          expect(find.byType(AddMovementBottomSheet), findsNothing);
          expect(find.text('Movement Page'), findsOneWidget);
        });
      });
    });

    testWidgets('handleDocumentScan does nothing when list is empty',
        (tester) async {
      tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('cunning_document_scanner'),
        (message) async {
          if (message.method == 'getPictures') {
            return <String>[];
          }
          return null;
        },
      );

      await mockNetworkImagesFor(() async {
        await pumpSubject(tester);
        await tester.pumpAndSettle();

        await tester.tap(find.byType(FloatingActionButton));
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
            if (message.method == 'getPictures') {
              throw PlatformException(code: 'error', message: 'Test error');
            }
            return null;
          },
        );

        await mockNetworkImagesFor(() async {
          await pumpSubject(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Scan'));

          for (var i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 500));
          }

          expect(find.byType(SnackBar), findsOneWidget);
        });
      });
    });

    testWidgets('handleDocumentScan handles unsupported file exception locally',
        (tester) async {
      await tester.runAsync(() async {
        tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
          const MethodChannel('cunning_document_scanner'),
          (message) async {
            if (message.method == 'getPictures') {
              return ['/tmp/test.pdf'];
            }
            return null;
          },
        );

        AppFunctions.internetConnectionTestValue = false;

        await mockNetworkImagesFor(() async {
          await pumpSubject(tester);
          await tester.pumpAndSettle();

          await tester.tap(find.byType(FloatingActionButton));
          await tester.pumpAndSettle();

          await tester.tap(find.text('Scan'));

          for (var i = 0; i < 5; i++) {
            await tester.pump(const Duration(milliseconds: 500));
          }

          expect(find.byType(SnackBar), findsOneWidget);
        });
      });
    });
  });
}
