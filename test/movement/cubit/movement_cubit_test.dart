import 'dart:typed_data';

import 'package:bloc_test/bloc_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mocktail/mocktail.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/movement/cubit/movement_cubit.dart';

class MockRemoteStorageService extends Mock implements RemoteStorageService {}

class MockCrashService extends Mock implements CrashService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockFormState extends Mock implements FormState {
  @override
  String toString({DiagnosticLevel minLevel = DiagnosticLevel.info}) {
    return super.toString();
  }
}

class MockGlobalKey extends Mock implements GlobalKey<FormState> {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockPathProviderPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements PathProviderPlatform {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MovementCubit', () {
    late MovementCubit movementCubit;
    late MockRemoteStorageService mockRemoteStorageService;
    late MockAppLocalizations mockL10n;
    late DatabaseService databaseService;
    late FakeFirebaseFirestore fakeFirestore;
    late MockPathProviderPlatform mockPathProviderPlatform;
    late MockCrashService mockCrashService;
    late MockAnalyticsService mockAnalyticsService;

    final date = DateTime(2023);
    const category = Category(
      id: '1',
      name: 'test',
      icon: 'test',
      color: 'red',
      type: CategoryType.expense,
    );
    final categories = [category];
    final movement = Movement(
      id: 'm1',
      title: 'Coffee',
      description: 'Morning',
      date: date,
      category: category,
      price: 5,
      user: 'u1',
      company: 'Starbucks',
      attachments: const ['file1'],
    );

    setUpAll(() {
      registerFallbackValue(const MovementState());
      registerFallbackValue(movement);
      mockPathProviderPlatform = MockPathProviderPlatform();
      PathProviderPlatform.instance = mockPathProviderPlatform;
    });

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      databaseService = DatabaseService(
        databaseRepository: FirestoreDatabaseRepository(
          firestore: fakeFirestore,
        ),
      );
      mockRemoteStorageService = MockRemoteStorageService();
      mockCrashService = MockCrashService();
      mockL10n = MockAppLocalizations();
      mockAnalyticsService = MockAnalyticsService();

      if (getIt.isRegistered<DatabaseService>()) {
        await getIt.unregister<DatabaseService>();
      }
      if (getIt.isRegistered<RemoteStorageService>()) {
        getIt.unregister<RemoteStorageService>();
      }
      if (getIt.isRegistered<CrashService>()) {
        getIt.unregister<CrashService>();
      }
      if (getIt.isRegistered<AnalyticsService>()) {
        getIt.unregister<AnalyticsService>();
      }

      getIt
        ..registerSingleton<DatabaseService>(databaseService)
        ..registerSingleton<RemoteStorageService>(mockRemoteStorageService)
        ..registerSingleton<CrashService>(mockCrashService)
        ..registerSingleton<AnalyticsService>(mockAnalyticsService);

      when(
        () => mockAnalyticsService.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) async => true);

      when(
        () => mockCrashService.log(any<String>()),
      ).thenAnswer((_) async => true);
      when(
        () => mockCrashService.recordError(
          any<dynamic>(),
          any<StackTrace?>(),
          reason: any<dynamic>(named: 'reason'),
          fatal: any<bool?>(named: 'fatal'),
          information: any<Iterable<Object>>(named: 'information'),
        ),
      ).thenAnswer((_) async => true);

      when(
        () => mockPathProviderPlatform.getApplicationCachePath(),
      ).thenAnswer((_) async => '.');

      movementCubit = MovementCubit();
    });

    test('initial state is correct', () {
      expect(movementCubit.state, const MovementState());
    });

    group('init', () {
      blocTest<MovementCubit, MovementState>(
        'emits correct state',
        build: () => movementCubit,
        act: (cubit) => cubit.init(movement, categories),
        expect: () => [
          isA<MovementState>()
              .having((s) => s.id, 'id', 'm1')
              .having((s) => s.title, 'title', 'Coffee')
              .having((s) => s.description, 'description', 'Morning')
              .having((s) => s.date, 'date', date)
              .having((s) => s.categories, 'categories', categories)
              .having((s) => s.category, 'category', category)
              .having((s) => s.price, 'price', 5)
              .having((s) => s.company, 'company', 'Starbucks')
              .having((s) => s.attachments, 'attachments', const [
                'file1',
              ])
              .having((s) => s.formKey, 'formKey', isNotNull),
        ],
      );

      blocTest<MovementCubit, MovementState>(
        'init with Category.empty emits correct state with first category',
        build: () => movementCubit,
        act: (cubit) =>
            cubit.init(movement.copyWith(category: Category.empty), categories),
        expect: () => [
          isA<MovementState>().having((s) => s.category, 'category', category),
        ],
      );
    });

    blocTest<MovementCubit, MovementState>(
      'titleChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.titleChanged('New Title'),
      expect: () => [const MovementState(title: 'New Title')],
    );

    blocTest<MovementCubit, MovementState>(
      'descriptionChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.descriptionChanged('New Description'),
      expect: () => [const MovementState(description: 'New Description')],
    );

    blocTest<MovementCubit, MovementState>(
      'dateChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.dateChanged(date),
      expect: () => [MovementState(date: date)],
    );

    blocTest<MovementCubit, MovementState>(
      'categoryChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.categoryChanged(category),
      expect: () => [const MovementState(category: category)],
    );

    blocTest<MovementCubit, MovementState>(
      'priceChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.priceChanged('10.5'),
      expect: () => [const MovementState(price: 10.5)],
    );

    blocTest<MovementCubit, MovementState>(
      'priceChanged defaults to 0 on invalid input',
      build: () => movementCubit,
      act: (cubit) => cubit.priceChanged('invalid'),
      expect: () => [const MovementState()],
    );

    blocTest<MovementCubit, MovementState>(
      'companyChanged emits correct state',
      build: () => movementCubit,
      act: (cubit) => cubit.companyChanged('New Company'),
      expect: () => [const MovementState(company: 'New Company')],
    );

    blocTest<MovementCubit, MovementState>(
      'attachAdd adds string to list and emits',
      build: () => movementCubit,
      act: (cubit) {
        cubit
          ..attachAdd('file1')
          ..attachAdd('file2');
      },
      expect: () => [
        const MovementState(attachments: ['file1']),
        const MovementState(attachments: ['file1', 'file2']),
      ],
    );

    group('attachRemove', () {
      blocTest<MovementCubit, MovementState>(
        'removes attachment and deletes from storage',
        setUp: () {
          when(
            () => mockRemoteStorageService.deleteFile(any()),
          ).thenAnswer((_) async => true);
        },
        build: () => movementCubit,
        seed: () => const MovementState(attachments: ['file1', 'file2']),
        act: (cubit) => cubit.attachRemove('file1'),
        expect: () => [
          const MovementState(attachments: ['file2']),
        ],
        verify: (_) {
          verify(() => mockRemoteStorageService.deleteFile('file1')).called(1);
        },
      );

      blocTest<MovementCubit, MovementState>(
        'removes attachment and continues if storage service returns false',
        setUp: () {
          when(
            () => mockRemoteStorageService.deleteFile(any()),
          ).thenAnswer((_) async => false);
        },
        build: () => movementCubit,
        seed: () => const MovementState(attachments: ['file1', 'file2']),
        act: (cubit) => cubit.attachRemove('file1'),
        expect: () => [
          const MovementState(attachments: ['file2']),
        ],
        verify: (_) {
          verify(() => mockRemoteStorageService.deleteFile('file1')).called(1);
        },
      );
    });

    group('attachOpen', () {
      test('handles exception in attachOpen', () async {
        when(
          () => mockRemoteStorageService.getData(any()),
        ).thenThrow(Exception('Error'));

        await movementCubit.attachOpen('file1');

        verify(() => mockRemoteStorageService.getData('file1')).called(1);
      });

      test('opens attachment and handles null data', () async {
        when(
          () => mockRemoteStorageService.getData(any()),
        ).thenAnswer((_) async => Uint8List(0));

        try {
          await movementCubit.attachOpen('file1');
        } on Exception catch (e) {
          debugPrint(e.toString());
        }
      });
    });

    group('saveMovement', () {
      test('does nothing if validation fails', () async {
        movementCubit.saveMovement('userId', mockL10n);
        verifyNever(
          () => mockAnalyticsService.logEvent(
            name: any(named: 'name'),
            parameters: any(named: 'parameters'),
          ),
        );
      });

      test('saves movement and returns true', () async {
        final mockFormState = MockFormState();
        final mockFormKey = MockGlobalKey();
        when(() => mockFormKey.currentState).thenReturn(mockFormState);
        when(mockFormState.validate).thenReturn(true);

        movementCubit
          ..init(movement, categories)
          ..emit(movementCubit.state.copyWith(formKey: mockFormKey))
          ..saveMovement('userId', mockL10n);

        final doc = await fakeFirestore
            .collection(AppVariables.movementsCollection)
            .doc('m1')
            .get();

        expect(doc.exists, isTrue);
        expect(doc.data()?['title'], 'Coffee');
      });

      test('saves new movement and returns true', () async {
        final mockFormState = MockFormState();
        final mockFormKey = MockGlobalKey();
        when(() => mockFormKey.currentState).thenReturn(mockFormState);
        when(mockFormState.validate).thenReturn(true);

        movementCubit
          ..init(movement.copyWith(id: ''), categories)
          ..emit(movementCubit.state.copyWith(formKey: mockFormKey))
          ..saveMovement('userId', mockL10n);

        final collection = await fakeFirestore
            .collection(AppVariables.movementsCollection)
            .get();
        expect(collection.docs.length, 1);
        expect(collection.docs.first.data()['title'], 'Coffee');
      });

      test(
        'saves movement even if database service fails (fire and forget)',
        () async {
          final mockDatabaseService = MockDatabaseService();

          await getIt.unregister<DatabaseService>();
          getIt.registerSingleton<DatabaseService>(mockDatabaseService);

          when(
            () => mockDatabaseService.saveMovement(
              movement: any(named: 'movement'),
            ),
          ).thenReturn(null);

          final mockFormState = MockFormState();
          final mockFormKey = MockGlobalKey();
          when(() => mockFormKey.currentState).thenReturn(mockFormState);
          when(mockFormState.validate).thenReturn(true);

          movementCubit
            ..init(movement, categories)
            ..emit(movementCubit.state.copyWith(formKey: mockFormKey))
            ..saveMovement('userId', mockL10n);

          verify(
            () => mockDatabaseService.saveMovement(
              movement: any(named: 'movement'),
            ),
          ).called(1);
        },
      );
    });

    group('removeMovement', () {
      test('does nothing if id is empty', () async {
        movementCubit.removeMovement();
        verifyNever(() => mockCrashService.log(any<String>()));
      });

      test('removes movement and associated attachments', () async {
        when(
          () => mockRemoteStorageService.deleteFile(any()),
        ).thenAnswer((_) async => true);

        await fakeFirestore
            .collection(AppVariables.movementsCollection)
            .doc('m1')
            .set(movement.toJson());

        movementCubit
          ..init(movement, categories)
          ..removeMovement();

        final doc = await fakeFirestore
            .collection(AppVariables.movementsCollection)
            .doc('m1')
            .get();
        expect(doc.exists, isFalse);

        verify(() => mockRemoteStorageService.deleteFile('file1')).called(1);
      });
    });
  });
}
