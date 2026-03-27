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
    TestWidgetsFlutterBinding.ensureInitialized();
    registerFallbackValue(DateTime.now());
    registerFallbackValue(CategoryType.expense);
    registerFallbackValue(
      const PromptPart(type: PromptPartType.text, text: ''),
    );
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

        final router = GoRouter(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) =>
                  const HomeView(categories: testCategories),
            ),
            GoRoute(
              path: '/movement/:type/:screenType',
              name: AppRoute.movement.name,
              builder: (context, state) =>
                  const Scaffold(body: Text('Movement Page')),
            ),
          ],
        );

        await mockNetworkImagesFor(() async {
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
  });
}
