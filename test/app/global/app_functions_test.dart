import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockAiService extends Mock implements AiService {}

class MockDatabaseService extends Mock implements DatabaseService {}

class FakePromptPart extends Fake implements PromptPart {}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('en');
    registerFallbackValue(FakePromptPart());
  });

  setUp(getIt.reset);

  group('AppFunctions', () {
    group('highResPicture', () {
      test('returns empty string if url is null', () {
        expect(AppFunctions.highResPicture(), equals(''));
      });

      test('returns correctly replaced url for low res', () {
        expect(
          AppFunctions.highResPicture(
            url: 'https://example.com/s96-c/image.jpg',
          ),
          equals('https://example.com/s200-c/image.jpg'),
        );
      });

      test('returns correctly replaced url for medium res', () {
        expect(
          AppFunctions.highResPicture(
            url: 'https://example.com/s96-c/image.jpg',
            resolution: ImageResolutionType.medium,
          ),
          equals('https://example.com/s400-c/image.jpg'),
        );
      });

      test('returns correctly replaced url for high res', () {
        expect(
          AppFunctions.highResPicture(
            url: 'https://example.com/s96-c/image.jpg',
            resolution: ImageResolutionType.high,
          ),
          equals('https://example.com/s600-c/image.jpg'),
        );
      });
    });

    group('hasInternetConnection', () {
      test('does not throw', () async {
        await expectLater(AppFunctions.hasInternetConnection, returnsNormally);
      });
    });

    group('getInitialTabIndex', () {
      test('returns 0 for expensesTab', () {
        expect(
          AppFunctions.getInitialTabIndex(AppVariables.expensesTab),
          equals(0),
        );
      });
      test('returns 1 for movementsTab', () {
        expect(
          AppFunctions.getInitialTabIndex(AppVariables.movementsTab),
          equals(1),
        );
      });
      test('returns 2 for summaryTab', () {
        expect(
          AppFunctions.getInitialTabIndex(AppVariables.summaryTab),
          equals(2),
        );
      });
      test('returns 3 for incomesTab', () {
        expect(
          AppFunctions.getInitialTabIndex(AppVariables.incomesTab),
          equals(3),
        );
      });
      test('returns 0 for unknown', () {
        expect(AppFunctions.getInitialTabIndex('unknown'), equals(0));
      });
    });

    group('substracMonth', () {
      test('returns correct date', () {
        final now = DateTime.now();
        final expected = DateTime(now.year, now.month - 2);
        final result = AppFunctions.substracMonth(3);
        expect(result.year, equals(expected.year));
        expect(result.month, equals(expected.month));
      });
    });

    group('showSnackBar', () {
      testWidgets('shows success snackbar', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      AppFunctions.showSnackBar(
                        context,
                        message: 'Success',
                        type: SnackBarType.success,
                      );
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        expect(find.byType(SnackBar), findsOneWidget);
        expect(find.text('Success'), findsOneWidget);
        expect(find.byType(HugeIcon), findsOneWidget);
      });

      testWidgets('shows error snackbar', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      AppFunctions.showSnackBar(
                        context,
                        message: 'Error',
                        type: SnackBarType.error,
                      );
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        expect(find.text('Error'), findsOneWidget);
      });

      testWidgets('shows warning snackbar', (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Builder(
                builder: (context) {
                  return ElevatedButton(
                    onPressed: () {
                      AppFunctions.showSnackBar(
                        context,
                        message: 'Warning',
                        type: SnackBarType.warning,
                      );
                    },
                    child: const Text('Show'),
                  );
                },
              ),
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pumpAndSettle();

        expect(find.text('Warning'), findsOneWidget);
      });
    });

    group('calculateIncomesAndExpenses', () {
      const categoryIncome = Category(
        id: '1',
        name: 'Income Category',
        type: CategoryType.income,
        color: '#FFFFFF',
        icon: 'TEST',
      );
      const categoryExpense = Category(
        id: '2',
        name: 'Expense Category',
        type: CategoryType.expense,
        color: '#000000',
        icon: 'TEST',
      );
      final testDate = DateTime.now();

      test('calculates correct totals', () {
        final movements = <Movement>[
          Movement(
            id: '1',
            title: 'desc',
            description: 'desc',
            price: 100,
            date: DateTime(testDate.year, testDate.month - 1, 15),
            category: categoryIncome,
            user: 'user_1',
          ),
          Movement(
            id: '2',
            title: 'desc',
            description: 'desc',
            price: 50,
            date: DateTime(testDate.year, testDate.month - 1, 15),
            category: categoryExpense,
            user: 'user_1',
          ),
          Movement(
            id: '3',
            title: 'desc',
            description: 'desc',
            price: 200,
            date: DateTime(testDate.year, testDate.month, 15),
            category: categoryIncome,
            user: 'user_1',
          ),
          Movement(
            id: '4',
            title: 'desc',
            description: 'desc',
            price: 75,
            date: DateTime(testDate.year, testDate.month, 15),
            category: categoryExpense,
            user: 'user_1',
          ),
        ];

        final results = AppFunctions.calculateIncomesAndExpenses(
          movements: movements,
          endMonth: testDate,
        );

        expect(results.$1, equals(100));
        expect(results.$2, equals(50));
        expect(results.$3, equals(200));
        expect(results.$4, equals(75));
      });
    });

    group('calculateCategoryAmounts', () {
      const category2 = Category(
        id: 'cat2',
        name: 'Expense 1',
        type: CategoryType.expense,
        color: '#000000',
        icon: 'TEST',
      );
      test('calculates correct amounts by category', () {
        final movements = [
          Movement(
            id: '1',
            title: 'desc',
            description: 'desc',
            price: 100,
            date: DateTime.now(),
            category: category2,
            user: 'user_1',
          ),
          Movement(
            id: '2',
            title: 'desc',
            description: 'desc',
            price: 50,
            date: DateTime.now(),
            category: category2,
            user: 'user_1',
          ),
        ];

        final result = AppFunctions.calculateCategoryAmounts(
          movements: movements,
          filterType: CategoryType.expense,
        );

        expect(result.length, equals(1));
        expect(result['cat2']!.totalExpense, equals(150));
      });
    });

    group('getCategoryName', () {
      test('returns correct mapped name for all categories', () {
        final mockL10n = MockAppLocalizations();
        when(() => mockL10n.categoryTransport).thenReturn('Transporte');
        when(() => mockL10n.categoryFeeding).thenReturn('Alimentación');
        when(() => mockL10n.categoryHealth).thenReturn('Salud');
        when(
          () => mockL10n.categoryEntertainment,
        ).thenReturn('Entretenimiento');
        when(() => mockL10n.categoryTrips).thenReturn('Viajes');
        when(() => mockL10n.categoryTechnology).thenReturn('Tecnología');
        when(() => mockL10n.categoryEducation).thenReturn('Educación');
        when(() => mockL10n.categoryFashion).thenReturn('Moda');
        when(() => mockL10n.categoryTaxes).thenReturn('Impuestos');
        when(() => mockL10n.categoryInsurance).thenReturn('Seguros');
        when(() => mockL10n.categoryDwelling).thenReturn('Vivienda');
        when(() => mockL10n.categoryGifts).thenReturn('Regalos');
        when(() => mockL10n.categoryOthersExpense).thenReturn('Otros Gastos');
        when(() => mockL10n.categorySalary).thenReturn('Salario');
        when(() => mockL10n.categoryBusiness).thenReturn('Negocios');
        when(() => mockL10n.categoryFreelance).thenReturn('Freelance');
        when(() => mockL10n.categoryRentals).thenReturn('Alquileres');
        when(() => mockL10n.categoryInvestments).thenReturn('Inversiones');
        when(() => mockL10n.categoryInterests).thenReturn('Intereses');
        when(() => mockL10n.categoryPensions).thenReturn('Pensiones');
        when(() => mockL10n.categoryDividends).thenReturn('Dividendos');
        when(() => mockL10n.categoryAwards).thenReturn('Premios');
        when(() => mockL10n.categoryRefunds).thenReturn('Reembolsos');
        when(() => mockL10n.categorySales).thenReturn('Ventas');
        when(() => mockL10n.categoryOthersIncome).thenReturn('Otros Ingresos');

        expect(
          AppFunctions.getCategoryName('TRANSPORT', mockL10n),
          equals('Transporte'),
        );
        expect(
          AppFunctions.getCategoryName('FEEDING', mockL10n),
          equals('Alimentación'),
        );
        expect(
          AppFunctions.getCategoryName('HEALTH', mockL10n),
          equals('Salud'),
        );
        expect(
          AppFunctions.getCategoryName('ENTERTAINMENT', mockL10n),
          equals('Entretenimiento'),
        );
        expect(
          AppFunctions.getCategoryName('TRIPS', mockL10n),
          equals('Viajes'),
        );
        expect(
          AppFunctions.getCategoryName('TECHNOLOGY', mockL10n),
          equals('Tecnología'),
        );
        expect(
          AppFunctions.getCategoryName('EDUCATION', mockL10n),
          equals('Educación'),
        );
        expect(
          AppFunctions.getCategoryName('FASHION', mockL10n),
          equals('Moda'),
        );
        expect(
          AppFunctions.getCategoryName('TAXES', mockL10n),
          equals('Impuestos'),
        );
        expect(
          AppFunctions.getCategoryName('INSURANCE', mockL10n),
          equals('Seguros'),
        );
        expect(
          AppFunctions.getCategoryName('DWELLING', mockL10n),
          equals('Vivienda'),
        );
        expect(
          AppFunctions.getCategoryName('GIFTS', mockL10n),
          equals('Regalos'),
        );
        expect(
          AppFunctions.getCategoryName('OTHERS_EXPENSE', mockL10n),
          equals('Otros Gastos'),
        );
        expect(
          AppFunctions.getCategoryName('SALARY', mockL10n),
          equals('Salario'),
        );
        expect(
          AppFunctions.getCategoryName('BUSINESS', mockL10n),
          equals('Negocios'),
        );
        expect(
          AppFunctions.getCategoryName('FREELANCE', mockL10n),
          equals('Freelance'),
        );
        expect(
          AppFunctions.getCategoryName('RENTALS', mockL10n),
          equals('Alquileres'),
        );
        expect(
          AppFunctions.getCategoryName('INVESTMENTS', mockL10n),
          equals('Inversiones'),
        );
        expect(
          AppFunctions.getCategoryName('INTERESTS', mockL10n),
          equals('Intereses'),
        );
        expect(
          AppFunctions.getCategoryName('PENSIONS', mockL10n),
          equals('Pensiones'),
        );
        expect(
          AppFunctions.getCategoryName('DIVIDENDS', mockL10n),
          equals('Dividendos'),
        );
        expect(
          AppFunctions.getCategoryName('AWARDS', mockL10n),
          equals('Premios'),
        );
        expect(
          AppFunctions.getCategoryName('REFUNDS', mockL10n),
          equals('Reembolsos'),
        );
        expect(
          AppFunctions.getCategoryName('SALES', mockL10n),
          equals('Ventas'),
        );
        expect(
          AppFunctions.getCategoryName('OTHERS_INCOME', mockL10n),
          equals('Otros Ingresos'),
        );
        expect(AppFunctions.getCategoryName('UNKNOWN', mockL10n), equals(''));
      });
    });

    group('getCategoryAnimatedIcon', () {
      test('returns correct animated icon widget for all categories', () {
        Widget? getIconForCat(String name) {
          return AppFunctions.getCategoryAnimatedIcon(
            Category(
              id: '1',
              name: name,
              type: CategoryType.expense,
              color: '#FFFFFF',
              icon: 'TEST',
            ),
            40,
          );
        }

        expect(getIconForCat('TRANSPORT'), isA<TransportAnimatedIcon>());
        expect(getIconForCat('FEEDING'), isA<FeedingAnimatedIcon>());
        expect(getIconForCat('HEALTH'), isA<HealthAnimatedIcon>());
        expect(
          getIconForCat('ENTERTAINMENT'),
          isA<EntertainmentAnimatedIcon>(),
        );
        expect(getIconForCat('TRIPS'), isA<TripsAnimatedIcon>());
        expect(getIconForCat('TECHNOLOGY'), isA<TechnologyAnimatedIcon>());
        expect(getIconForCat('EDUCATION'), isA<EducationAnimatedIcon>());
        expect(getIconForCat('FASHION'), isA<FashionAnimatedIcon>());
        expect(getIconForCat('TAXES'), isA<TaxesAnimatedIcon>());
        expect(getIconForCat('INSURANCE'), isA<InsuranceAnimatedIcon>());
        expect(getIconForCat('DWELLING'), isA<DwellingAnimatedIcon>());
        expect(getIconForCat('GIFTS'), isA<GiftsAnimatedIcon>());
        expect(
          getIconForCat('OTHERS_EXPENSE'),
          isA<OthersExpenseAnimatedIcon>(),
        );
        expect(getIconForCat('SALARY'), isA<SalaryAnimatedIcon>());
        expect(getIconForCat('BUSINESS'), isA<BusinessAnimatedIcon>());
        expect(getIconForCat('FREELANCE'), isA<FreelanceAnimatedIcon>());
        expect(getIconForCat('RENTALS'), isA<RentalsAnimatedIcon>());
        expect(getIconForCat('INVESTMENTS'), isA<InvestmentsAnimatedIcon>());
        expect(getIconForCat('INTERESTS'), isA<InterestsAnimatedIcon>());
        expect(getIconForCat('PENSIONS'), isA<PensionsAnimatedIcon>());
        expect(getIconForCat('DIVIDENDS'), isA<DividendsAnimatedIcon>());
        expect(getIconForCat('AWARDS'), isA<AwardsAnimatedIcon>());
        expect(getIconForCat('REFUNDS'), isA<RefundsAnimatedIcon>());
        expect(getIconForCat('SALES'), isA<SalesAnimatedIcon>());
        expect(getIconForCat('OTHERS_INCOME'), isA<OthersIncomeAnimatedIcon>());
        expect(getIconForCat('UNKNOWN'), isNull);
      });
    });

    group('getCategoryIcon', () {
      test('returns HugeIcon icon list for valid icon', () {
        expect(
          AppFunctions.getCategoryIcon('DIRECTIONS_CAR'),
          equals(HugeIcons.strokeRoundedCar01),
        );
        expect(
          AppFunctions.getCategoryIcon('RESTAURANT'),
          equals(HugeIcons.strokeRoundedRestaurant01),
        );
        expect(
          AppFunctions.getCategoryIcon('UNKNOWN'),
          equals(HugeIcons.strokeRoundedAlert02),
        );
      });
    });

    group('getTypeName', () {
      test('returns expected string', () {
        final mockL10n = MockAppLocalizations();
        when(() => mockL10n.expenseName).thenReturn('Gastos');
        when(() => mockL10n.incomeName).thenReturn('Ingresos');

        expect(
          AppFunctions.getTypeName(CategoryType.expense, mockL10n),
          equals('Gastos'),
        );
        expect(
          AppFunctions.getTypeName(CategoryType.income, mockL10n),
          equals('Ingresos'),
        );
      });
    });

    group('getTypeIcon', () {
      test('returns correct icon', () {
        expect(
          AppFunctions.getTypeIcon(CategoryType.expense),
          equals(HugeIcons.strokeRoundedMoneyRemove01),
        );
        expect(
          AppFunctions.getTypeIcon(CategoryType.income),
          equals(HugeIcons.strokeRoundedMoneyAdd01),
        );
      });
    });

    group('buildChartData', () {
      const categoryIncome = Category(
        id: '1',
        name: 'Income Category',
        type: CategoryType.income,
        color: '#FFFFFF',
        icon: 'TEST',
      );
      const categoryExpense = Category(
        id: '2',
        name: 'Expense Category',
        type: CategoryType.expense,
        color: '#000000',
        icon: 'TEST',
      );
      test('returns correct chart data', () {
        final movements = <Movement>[
          Movement(
            id: '1',
            title: 'desc',
            description: 'desc',
            price: 100,
            date: DateTime.now(),
            category: categoryIncome,
            user: 'user_1',
          ),
          Movement(
            id: '2',
            title: 'desc',
            description: 'desc',
            price: 50,
            date: DateTime.now(),
            category: categoryExpense,
            user: 'user_1',
          ),
          Movement(
            id: '3',
            title: 'desc',
            description: 'desc',
            price: 200,
            date: DateTime.now(),
            category: categoryIncome,
            user: 'user_1',
          ),
        ];

        final result = AppFunctions.buildChartData(movements: movements);

        expect(result.length, equals(2));
        expect(result[0].category.id, equals('1'));
        expect(result[0].value, equals(300));
        expect(result[1].category.id, equals('2'));
        expect(result[1].value, equals(50));
      });
    });

    group('buildTrendData', () {
      const categoryExpense = Category(
        id: '2',
        name: 'Expense Category',
        type: CategoryType.expense,
        color: '#000000',
        icon: 'TEST',
      );
      test('returns correct trend data', () {
        final movements = <Movement>[
          Movement(
            id: '1',
            title: 'desc',
            description: 'desc',
            price: 100,
            date: DateTime(2023, 1, 15),
            category: categoryExpense,
            user: 'user_1',
          ),
          Movement(
            id: '2',
            title: 'desc',
            description: 'desc',
            price: 50,
            date: DateTime(2023, 2, 10),
            category: categoryExpense,
            user: 'user_1',
          ),
        ];

        final result = AppFunctions.buildTrendData(
          movements: movements,
          startMonth: DateTime(2023),
          endMonth: DateTime(2023, 3),
          language: 'en',
        );

        expect(result.length, equals(3));
        expect(result[0].xValue, equals('Jan'));
        expect(result[0].yValue, equals(100));
        expect(result[1].xValue, equals('Feb'));
        expect(result[1].yValue, equals(50));
        expect(result[2].xValue, equals('Mar'));
        expect(result[2].yValue, equals(0));
      });
    });

    group('buildResumeTrendData', () {
      const categoryIncome = Category(
        id: '1',
        name: 'Income Category',
        type: CategoryType.income,
        color: '#FFFFFF',
        icon: 'TEST',
      );
      const categoryExpense = Category(
        id: '2',
        name: 'Expense Category',
        type: CategoryType.expense,
        color: '#000000',
        icon: 'TEST',
      );
      test('returns correct resume trend data', () {
        final movements = <Movement>[
          Movement(
            id: '1',
            title: 'desc',
            description: 'desc',
            price: 100,
            date: DateTime(2023, 1, 15),
            category: categoryIncome,
            user: 'user_1',
          ),
          Movement(
            id: '2',
            title: 'desc',
            description: 'desc',
            price: 50,
            date: DateTime(2023, 1, 10),
            category: categoryExpense,
            user: 'user_1',
          ),
        ];

        final result = AppFunctions.buildResumeTrendData(
          movements: movements,
          startMonth: DateTime(2023),
          endMonth: DateTime(2023),
          language: 'en',
          selResumeItems: {
            ResumeItemType.income: true,
            ResumeItemType.expense: true,
            ResumeItemType.balance: true,
          },
        );

        expect(result.length, equals(3));
        expect(result[0][0].yValue, equals(100));
        expect(result[1][0].yValue, equals(50));
        expect(result[2][0].yValue, equals(50));
      });
    });

    group('getPrompt', () {
      test('replaces variables correctly', () {
        final mockRemoteConfig = MockRemoteConfigService();
        when(
          () => mockRemoteConfig.geminiPromptExtractReceiptData,
        ).thenReturn('Test {{type}} {{language}} {{categories}}');
        getIt.registerLazySingleton<RemoteConfigService>(
          () => mockRemoteConfig,
        );

        final result = AppFunctions.getPrompt(
          movementType: CategoryType.expense,
          categories: const [
            Category(
              id: '1',
              name: 'FOOD',
              type: CategoryType.expense,
              color: '#FFFFFF',
              icon: 'TEST',
            ),
          ],
          language: 'es',
        );

        expect(result, equals('Test expense es FOOD'));
      });
    });

    group('buildMovementFromFile', () {
      const categoryIncome = Category(
        id: '1',
        name: 'INCOME',
        type: CategoryType.income,
        color: '#FFFFFF',
        icon: 'TEST',
      );

      test('uses remote model when local is unavailable', () async {
        final mockRemoteConfig = MockRemoteConfigService();
        final mockAiService = MockAiService();
        when(
          () => mockRemoteConfig.geminiPromptExtractReceiptData,
        ).thenReturn('Prompt');
        when(() => mockAiService.isLocalModelAvailable).thenReturn(false);
        when(
          () => mockAiService.generateContentRemote(
            prompt: any(named: 'prompt'),
            responseMimeType: any(named: 'responseMimeType'),
          ),
        ).thenAnswer(
          (_) async =>
              '{"title": "Test Title", "price": 100, "description": "Test", "category": "INCOME", "date": "15/01/2023"}',
        );

        getIt
          ..registerLazySingleton<RemoteConfigService>(() => mockRemoteConfig)
          ..registerLazySingleton<AiService>(() => mockAiService);

        final movement = await AppFunctions.buildMovementFromFile(
          movementType: CategoryType.income,
          categories: const [categoryIncome],
          language: 'en',
          mimeType: 'image/jpeg',
          bytes: Uint8List.fromList([]),
          modelType: ModelType.cloud,
        );

        expect(movement.title, equals('Test Title'));
        expect(movement.price, equals(100));
        expect(movement.category.id, equals('1'));
      });

      test('uses local model when requested and available', () async {
        final mockRemoteConfig = MockRemoteConfigService();
        final mockAiService = MockAiService();
        when(
          () => mockRemoteConfig.geminiPromptExtractReceiptData,
        ).thenReturn('Prompt');
        when(() => mockAiService.isLocalModelAvailable).thenReturn(true);
        when(
          () => mockAiService.generateContentLocal(
            textPrompt: any(named: 'textPrompt'),
            imagePrompt: any(named: 'imagePrompt'),
          ),
        ).thenAnswer(
          (_) async =>
              '{"title": "Local Title", "price": 50, "description": "Local", "category": "INCOME", "date": "15/01/2023"}',
        );

        getIt
          ..registerLazySingleton<RemoteConfigService>(() => mockRemoteConfig)
          ..registerLazySingleton<AiService>(() => mockAiService);

        final movement = await AppFunctions.buildMovementFromFile(
          movementType: CategoryType.income,
          categories: const [categoryIncome],
          language: 'en',
          mimeType: 'image/jpeg',
          bytes: Uint8List.fromList([]),
          modelType: ModelType.local,
        );

        expect(movement.title, equals('Local Title'));
        expect(movement.price, equals(50));
        expect(movement.category.id, equals('1'));
      });
    });

    group('getAntRecommendations', () {
      test('returns recommendations list using remote model', () async {
        final mockRemoteConfig = MockRemoteConfigService();
        final mockAiService = MockAiService();
        final mockDatabaseService = MockDatabaseService();
        final mockL10n = MockAppLocalizations();

        when(
          () => mockRemoteConfig.geminiPromptDetectAntExpense,
        ).thenReturn('Prompt {{transactions_list}}');
        when(() => mockRemoteConfig.geminiAntLookbackDays).thenReturn(30);

        when(
          () => mockDatabaseService.getMovements(
            userId: any(named: 'userId'),
            from: any(named: 'from'),
            to: any(named: 'to'),
          ),
        ).thenAnswer((_) async => []);

        when(() => mockAiService.isLocalModelAvailable).thenReturn(false);
        when(
          () =>
              mockAiService.generateContentRemote(prompt: any(named: 'prompt')),
        ).thenAnswer((_) async => 'Rec 1 ||| Rec 2 ||| Rec 3');

        getIt
          ..registerLazySingleton<RemoteConfigService>(() => mockRemoteConfig)
          ..registerLazySingleton<AiService>(() => mockAiService)
          ..registerLazySingleton<DatabaseService>(() => mockDatabaseService);

        final result = await AppFunctions.getAntRecommendations(
          userId: 'user_1',
          language: 'en',
          l10n: mockL10n,
        );

        expect(result, isNotNull);
        expect(result!.length, equals(3));
        expect(result[0], equals('Rec 1'));
        expect(result[1], equals('Rec 2'));
        expect(result[2], equals('Rec 3'));
      });
    });
  });
}
