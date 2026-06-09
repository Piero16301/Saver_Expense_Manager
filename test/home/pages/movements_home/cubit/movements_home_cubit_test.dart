import 'dart:async';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/home.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockLocalStorageService extends Mock implements LocalStorageService {}

class MockAuthService extends Mock implements AuthService {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockFirebaseUser extends Mock implements User {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockDatabaseService extends Mock implements DatabaseService {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockAiService extends Mock implements AiService {}

DateTime get _todayDate {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

void main() {
  late MockLocalStorageService mockLocalStorage;
  late MockAuthService mockAuth;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockFirebaseUser mockFirebaseUser;
  late MockDatabaseService mockDatabase;
  late MockRemoteConfigService mockRemoteConfig;
  late MockAiService mockAiService;

  setUpAll(() {
    registerFallbackValue(CategoryType.expense);
    registerFallbackValue(Category.empty);
    registerFallbackValue(
      const PromptPart(type: PromptPartType.text, text: ''),
    );
  });

  setUp(() async {
    mockLocalStorage = MockLocalStorageService();
    mockAuth = MockAuthService();
    mockFirebaseAuth = MockFirebaseAuth();
    mockFirebaseUser = MockFirebaseUser();
    mockDatabase = MockDatabaseService();
    mockRemoteConfig = MockRemoteConfigService();
    mockAiService = MockAiService();

    when(() => mockFirebaseUser.uid).thenReturn('user123');
    when(() => mockFirebaseAuth.currentUser).thenReturn(mockFirebaseUser);
    when(() => mockAuth.currentUser).thenReturn(const AppUser(uid: 'user123'));

    when(() => mockLocalStorage.getLanguage()).thenReturn(null);
    when(
      () => mockLocalStorage.getRecommendationsDate(),
    ).thenReturn(_todayDate);
    when(() => mockLocalStorage.getRecommendations()).thenReturn(['Tip A']);
    when(
      () => mockLocalStorage.saveRecommendations(
        recommendations: any(named: 'recommendations'),
      ),
    ).thenReturn(null);
    when(
      () => mockLocalStorage.saveRecommendationsDate(date: any(named: 'date')),
    ).thenReturn(null);

    if (getIt.isRegistered<LocalStorageService>()) {
      getIt.unregister<LocalStorageService>();
    }
    if (getIt.isRegistered<AuthService>()) {
      getIt.unregister<AuthService>();
    }
    if (getIt.isRegistered<DatabaseService>()) {
      getIt.unregister<DatabaseService>();
    }
    if (getIt.isRegistered<RemoteConfigService>()) {
      getIt.unregister<RemoteConfigService>();
    }
    if (getIt.isRegistered<AiService>()) {
      getIt.unregister<AiService>();
    }

    getIt
      ..registerSingleton<LocalStorageService>(mockLocalStorage)
      ..registerSingleton<AuthService>(mockAuth)
      ..registerSingleton<DatabaseService>(mockDatabase)
      ..registerSingleton<RemoteConfigService>(mockRemoteConfig)
      ..registerSingleton<AiService>(mockAiService);

    AppFunctions.internetConnectionTestValue = true;
  });

  tearDown(() {
    unawaited(getIt.reset());
    AppFunctions.internetConnectionTestValue = null;
  });

  Future<MovementsHomeCubit> buildCubit() async {
    final mockL10n = MockAppLocalizations();
    final cubit = MovementsHomeCubit(l10n: mockL10n);
    await Future<void>.delayed(Duration.zero);
    return cubit;
  }

  group('MovementsHomeCubit', () {
    test(
      'updateFilterType sets type and clears category when type changes',
      () async {
        final cubit = await buildCubit();
        cubit.updateFilterType(CategoryType.expense);
        expect(cubit.state.filterType, CategoryType.expense);
        expect(cubit.state.filterCategory, isNull);
        await cubit.close();
      },
    );

    test(
      'updateFilterType with null clears both filterType and filterCategory',
      () async {
        final cubit = await buildCubit();
        cubit
          ..updateFilterType(CategoryType.expense)
          ..updateFilterType(null);
        expect(cubit.state.filterType, isNull);
        expect(cubit.state.filterCategory, isNull);
        await cubit.close();
      },
    );

    test('updateFilterType with same type preserves filterCategory', () async {
      final cubit = await buildCubit();
      const cat = Category(
        id: '1',
        name: 'FEEDING',
        icon: 'i',
        color: 'c',
        type: CategoryType.expense,
      );
      cubit
        ..updateFilterType(CategoryType.expense)
        ..updateFilterCategory(cat)
        ..updateFilterType(CategoryType.expense);
      expect(cubit.state.filterType, CategoryType.expense);
      expect(cubit.state.filterCategory?.id, '1');
      await cubit.close();
    });

    test('updateFilterCategory emits new filterCategory', () async {
      final cubit = await buildCubit();
      cubit
        ..updateFilterType(CategoryType.expense)
        ..updateFilterCategory(
          const Category(
            id: '5',
            name: 'FEEDING',
            icon: 'i',
            color: 'c',
            type: CategoryType.expense,
          ),
        );
      expect(cubit.state.filterCategory?.id, '5');
      await cubit.close();
    });

    test('changeShowRecommendations toggles showRecommendations', () async {
      final cubit = await buildCubit();
      final before = cubit.state.showRecommendations;
      cubit.changeShowRecommendations();
      expect(cubit.state.showRecommendations, !before);
      await cubit.close();
    });

    test('resetRecommendationsStatus resets to initial', () async {
      final cubit = await buildCubit();
      cubit.resetRecommendationsStatus();
      expect(cubit.state.recommendationsStatus, RecommendationsStatus.initial);
      await cubit.close();
    });

    test(
      'constructor uses cached recommendations when date matches today',
      () async {
        when(
          () => mockLocalStorage.getRecommendations(),
        ).thenReturn(['Tip 1', 'Tip 2']);
        final cubit = await buildCubit();
        expect(
          cubit.state.recommendationsStatus,
          RecommendationsStatus.success,
        );
        expect(cubit.state.recommendations, ['Tip 1', 'Tip 2']);
        await cubit.close();
      },
    );

    test('getRecommendations fetches from remote if date is old', () async {
      when(
        () => mockLocalStorage.getRecommendationsDate(),
      ).thenReturn(DateTime(2020));
      when(
        () => mockRemoteConfig.geminiPromptDetectAntExpense,
      ).thenReturn('prompt');
      when(() => mockRemoteConfig.geminiAntLookbackDays).thenReturn(30);
      when(
        () => mockDatabase.getMovements(
          userId: any(named: 'userId'),
          from: any(named: 'from'),
          to: any(named: 'to'),
        ),
      ).thenAnswer((_) async => []);

      when(
        () => mockAiService.generateContentRemote(prompt: any(named: 'prompt')),
      ).thenAnswer((_) async => 'Tip 3 ||| Tip 4');
      when(() => mockAiService.isLocalModelAvailable).thenReturn(true);
      when(
        () => mockAiService.generateContentLocal(
          textPrompt: any(named: 'textPrompt'),
        ),
      ).thenAnswer((_) async => 'Tip 3 ||| Tip 4');

      final cubit = await buildCubit();

      expect(cubit.state.recommendationsStatus, RecommendationsStatus.success);
      expect(cubit.state.recommendations, ['Tip 3', 'Tip 4']);
      verify(
        () => mockLocalStorage.saveRecommendations(
          recommendations: ['Tip 3', 'Tip 4'],
        ),
      ).called(1);
      await cubit.close();
    });

    test('getRecommendations sets failure state on Exception', () async {
      when(
        () => mockLocalStorage.getRecommendationsDate(),
      ).thenReturn(DateTime(2020));
      when(
        () => mockRemoteConfig.geminiPromptDetectAntExpense,
      ).thenThrow(Exception('Fail'));

      final cubit = await buildCubit();

      expect(cubit.state.recommendationsStatus, RecommendationsStatus.failure);
      await cubit.close();
    });

    test('MovementsHomeState copyWith preserves unchanged fields', () {
      const state = MovementsHomeState(
        filterType: CategoryType.expense,
        recommendationsStatus: RecommendationsStatus.success,
        recommendations: ['A', 'B'],
        showRecommendations: false,
      );
      final copy = state.copyWith(
        recommendationsStatus: RecommendationsStatus.loading,
      );
      expect(copy.filterType, null);
      expect(copy.recommendationsStatus, RecommendationsStatus.loading);
      expect(copy.recommendations, ['A', 'B']);
      expect(copy.showRecommendations, false);
    });
  });

  group('RecommendationsStatus', () {
    test('isInitial is correct', () {
      expect(RecommendationsStatus.initial.isInitial, isTrue);
      expect(RecommendationsStatus.loading.isInitial, isFalse);
    });

    test('isLoading is correct', () {
      expect(RecommendationsStatus.loading.isLoading, isTrue);
      expect(RecommendationsStatus.success.isLoading, isFalse);
    });

    test('isSuccess is correct', () {
      expect(RecommendationsStatus.success.isSuccess, isTrue);
      expect(RecommendationsStatus.failure.isSuccess, isFalse);
    });

    test('isFailure is correct', () {
      expect(RecommendationsStatus.failure.isFailure, isTrue);
      expect(RecommendationsStatus.initial.isFailure, isFalse);
    });
  });

  group('MovementsHomePage', () {
    late MockDatabaseService mockDatabase;

    setUp(() async {
      mockDatabase = MockDatabaseService();
      when(
        () => mockDatabase.getCategoriesStream(),
      ).thenAnswer((_) => Stream.value([]));
      when(
        () => mockDatabase.getMovementsStream(
          userId: any(named: 'userId'),
          startDate: any<DateTime?>(named: 'startDate'),
          endDate: any<DateTime?>(named: 'endDate'),
          type: any<CategoryType?>(named: 'type'),
          categoryId: any<String?>(named: 'categoryId'),
          limit: any<int>(named: 'limit'),
          orderByDate: any<bool>(named: 'orderByDate'),
        ),
      ).thenAnswer((_) => Stream.value([]));

      if (getIt.isRegistered<DatabaseService>()) {
        getIt.unregister<DatabaseService>();
      }
      getIt.registerSingleton<DatabaseService>(mockDatabase);
    });

    test('getCategoriesStream returns a stream of categories', () async {
      final fakeFirestore = FakeFirebaseFirestore();
      final db = DatabaseService(
        databaseRepository: FirestoreDatabaseRepository(
          firestore: fakeFirestore,
        ),
      );
      expect(db.getCategoriesStream(), isA<Stream<List<Category>>>());
    });
  });
}
