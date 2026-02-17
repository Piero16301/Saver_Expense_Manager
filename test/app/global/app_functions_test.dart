import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

class MockAiService extends Mock implements AiService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

void main() {
  late MockRemoteConfigService mockRemoteConfigService;
  late MockAiService mockAiService;
  late MockAppLocalizations mockAppLocalizations;

  setUpAll(() {
    registerFallbackValue(
      const Category(
        id: 'id',
        name: 'name',
        icon: 'icon',
        color: 'color',
        type: CategoryType.expense,
      ),
    );
  });

  setUp(() async {
    await GetIt.I.reset();
    mockRemoteConfigService = MockRemoteConfigService();
    mockAiService = MockAiService();
    mockAppLocalizations = MockAppLocalizations();

    GetIt.I.registerSingleton<RemoteConfigService>(mockRemoteConfigService);
    GetIt.I.registerSingleton<AiService>(mockAiService);
  });

  group('AppFunctions', () {
    testWidgets('showSnackBar displays a snackbar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    AppFunctions.showSnackBar(
                      context,
                      message: 'Test Message',
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
      await tester.pump(); // Start animation
      await tester.pump(const Duration(seconds: 1)); // Finish animation

      expect(find.text('Test Message'), findsOneWidget);
    });

    group('buildResumeTrendData', () {
      test('builds resume trend data correctly', () {
        final startMonth = DateTime(2023);
        final endMonth = DateTime(2023);

        final movements = [
          Movement(
            id: '1',
            date: DateTime(2023, 1, 10),
            price: 100,
            category: const Category(
              id: 'c1',
              name: 'Inc',
              icon: 'i',
              color: 'c',
              type: CategoryType.income,
            ),
            description: 'd',
            user: 'u',
            title: 't',
            movementRecap: 'r',
          ),
          Movement(
            id: '2',
            date: DateTime(2023, 1, 15),
            price: 40,
            category: const Category(
              id: 'c2',
              name: 'Exp',
              icon: 'i',
              color: 'c',
              type: CategoryType.expense,
            ),
            description: 'd',
            user: 'u',
            title: 't',
            movementRecap: 'r',
          ),
        ];

        final selResumeItems = {
          ResumeItemType.income: true,
          ResumeItemType.expense: true,
          ResumeItemType.balance: true,
        };

        final data = AppFunctions.buildResumeTrendData(
          movements: movements,
          startMonth: startMonth,
          endMonth: endMonth,
          language: 'en_US',
          selResumeItems: selResumeItems,
        );

        expect(data.length, 3);
        expect(data[0].length, 1);
        expect(data[0][0].yValue, 100.0);

        expect(data[1].length, 1);
        expect(data[1][0].yValue, 40.0);

        expect(data[2].length, 1);
        expect(data[2][0].yValue, 60.0);
      });
    });

    group('highResPicture', () {
      test('returns empty string if url is null', () {
        expect(AppFunctions.highResPicture(), isEmpty);
      });

      test('returns low resolution url by default', () {
        const url = 'https://example.com/image=s96-c';
        expect(
          AppFunctions.highResPicture(url: url),
          'https://example.com/image=s200-c',
        );
      });

      test('returns medium resolution url', () {
        const url = 'https://example.com/image=s96-c';
        expect(
          AppFunctions.highResPicture(
            url: url,
            resolution: ImageResolutionType.medium,
          ),
          'https://example.com/image=s400-c',
        );
      });

      test('returns high resolution url', () {
        const url = 'https://example.com/image=s96-c';
        expect(
          AppFunctions.highResPicture(
            url: url,
            resolution: ImageResolutionType.high,
          ),
          'https://example.com/image=s600-c',
        );
      });
    });

    group('getInitialTabIndex', () {
      test('returns 0 for expensesTab', () {
        expect(AppFunctions.getInitialTabIndex(AppVariables.expensesTab), 0);
      });

      test('returns 1 for movementsTab', () {
        expect(AppFunctions.getInitialTabIndex(AppVariables.movementsTab), 1);
      });

      test('returns 2 for summaryTab', () {
        expect(AppFunctions.getInitialTabIndex(AppVariables.summaryTab), 2);
      });

      test('returns 3 for incomesTab', () {
        expect(AppFunctions.getInitialTabIndex(AppVariables.incomesTab), 3);
      });

      test('returns 0 for unknown tab', () {
        expect(AppFunctions.getInitialTabIndex('unknown'), 0);
      });
    });

    group('substracMonth', () {
      test('returns correct date when subtracting months', () {
        expect(AppFunctions.substracMonth(1), isA<DateTime>());
      });
    });

    group('calculateIncomesAndExpenses', () {
      test('calculates correct values for past and current month', () {
        final endMonth = DateTime(2023, 10);
        final movements = [
          Movement(
            id: '1',
            date: DateTime(2023, 10, 5),
            price: 100,
            category: const Category(
              id: '1',
              name: 'Cat1',
              icon: 'icon',
              color: 'color',
              type: CategoryType.income,
            ),
            description: 'Income Oct',
            user: 'user1',
            title: 'Income Oct',
            movementRecap: 'Income Oct',
          ),
          Movement(
            id: '2',
            date: DateTime(2023, 10, 10),
            price: 50,
            category: const Category(
              id: '2',
              name: 'Cat2',
              icon: 'icon',
              color: 'color',
              type: CategoryType.expense,
            ),
            description: 'Expense Oct',
            user: 'user1',
            title: 'Expense Oct',
            movementRecap: 'Expense Oct',
          ),
          Movement(
            id: '3',
            date: DateTime(2023, 9, 15),
            price: 200,
            category: const Category(
              id: '1',
              name: 'Cat1',
              icon: 'icon',
              color: 'color',
              type: CategoryType.income,
            ),
            description: 'Income Sep',
            user: 'user1',
            title: 'Income Sep',
            movementRecap: 'Income Sep',
          ),
          Movement(
            id: '4',
            date: DateTime(2023, 9, 20),
            price: 30,
            category: const Category(
              id: '2',
              name: 'Cat2',
              icon: 'icon',
              color: 'color',
              type: CategoryType.expense,
            ),
            description: 'Expense Sep',
            user: 'user1',
            title: 'Expense Sep',
            movementRecap: 'Expense Sep',
          ),
          Movement(
            id: '5',
            date: DateTime(2023, 8, 20),
            price: 500,
            category: const Category(
              id: '1',
              name: 'Cat1',
              icon: 'icon',
              color: 'color',
              type: CategoryType.income,
            ),
            description: 'Income Aug',
            user: 'user1',
            title: 'Income Aug',
            movementRecap: 'Income Aug',
          ),
        ];

        final result = AppFunctions.calculateIncomesAndExpenses(
          movements: movements,
          endMonth: endMonth,
        );

        expect(result.$1, 200.0);
        expect(result.$2, 30.0);
        expect(result.$3, 100.0);
        expect(result.$4, 50.0);
      });
    });

    group('calculateCategoryAmounts', () {
      test('aggregates amounts by category correctly', () {
        const category1 = Category(
          id: 'c1',
          name: 'Cat1',
          icon: 'i1',
          color: 'col1',
          type: CategoryType.expense,
        );
        const category2 = Category(
          id: 'c2',
          name: 'Cat2',
          icon: 'i2',
          color: 'col2',
          type: CategoryType.expense,
        );
        final movements = [
          Movement(
            id: '1',
            date: DateTime.now(),
            price: 10,
            category: category1,
            description: 'd1',
            user: 'u1',
            title: 'd1',
            movementRecap: 'd1',
          ),
          Movement(
            id: '2',
            date: DateTime.now(),
            price: 20,
            category: category1,
            description: 'd2',
            user: 'u1',
            title: 'd2',
            movementRecap: 'd2',
          ),
          Movement(
            id: '3',
            date: DateTime.now(),
            price: 5,
            category: category2,
            description: 'd3',
            user: 'u1',
            title: 'd3',
            movementRecap: 'd3',
          ),
          Movement(
            id: '4',
            date: DateTime.now(),
            price: 100,
            category: const Category(
              id: 'c3',
              name: 'Cat3',
              icon: 'i3',
              color: 'col3',
              type: CategoryType.income,
            ),
            description: 'd4',
            user: 'u1',
            title: 'd4',
            movementRecap: 'd4',
          ),
        ];

        final result = AppFunctions.calculateCategoryAmounts(
          movements: movements,
          filterType: CategoryType.expense,
        );

        expect(result.length, 2);
        expect(result['c1']?.totalExpense, 30.0);
        expect(result['c2']?.totalExpense, 5.0);
      });
    });

    group('getCategoryIcon', () {
      test('returns correct icon for known keys', () {
        expect(
          AppFunctions.getCategoryIcon('DIRECTIONS_CAR'),
          HugeIcons.strokeRoundedCar01,
        );
        expect(
          AppFunctions.getCategoryIcon('RESTAURANT'),
          HugeIcons.strokeRoundedRestaurant01,
        );
      });

      test('returns default icon for unknown key', () {
        expect(
          AppFunctions.getCategoryIcon('UNKNOWN_KEY'),
          HugeIcons.strokeRoundedAlert02,
        );
      });
    });

    group('getTypeIcon', () {
      test('returns correct icon', () {
        expect(
          AppFunctions.getTypeIcon(CategoryType.expense),
          HugeIcons.strokeRoundedMoneyRemove01,
        );
        expect(
          AppFunctions.getTypeIcon(CategoryType.income),
          HugeIcons.strokeRoundedMoneyAdd01,
        );
      });
    });

    group('getPrompt', () {
      test('generates correct prompt string', () {
        when(() => mockRemoteConfigService.geminiPromptExtractReceiptData)
            .thenReturn(
          'Type: {{type}}, Lang: {{language}}, Cats: {{categories}}',
        );

        final categories = [
          const Category(
            id: '1',
            name: 'Food',
            icon: 'icon',
            color: 'color',
            type: CategoryType.expense,
          ),
          const Category(
            id: '2',
            name: 'Transport',
            icon: 'icon',
            color: 'color',
            type: CategoryType.expense,
          ),
        ];

        final prompt = AppFunctions.getPrompt(
          movementType: CategoryType.expense,
          categories: categories,
          language: 'en',
        );

        expect(prompt, 'Type: expense, Lang: en, Cats: Food, Transport');
      });
    });

    group('getCategoryName', () {
      test('returns localized name for categories', () {
        when(() => mockAppLocalizations.categoryTransport)
            .thenReturn('Transport Loc');
        when(() => mockAppLocalizations.categoryFeeding)
            .thenReturn('Feeding Loc');

        expect(
          AppFunctions.getCategoryName('TRANSPORT', mockAppLocalizations),
          'Transport Loc',
        );
        expect(
          AppFunctions.getCategoryName('FEEDING', mockAppLocalizations),
          'Feeding Loc',
        );
      });

      test('returns empty for unknown category', () {
        expect(
          AppFunctions.getCategoryName('UNKNOWN', mockAppLocalizations),
          '',
        );
      });
    });

    group('getTypeName', () {
      test('returns localized name for type', () {
        when(() => mockAppLocalizations.expenseName).thenReturn('Expense Loc');
        when(() => mockAppLocalizations.incomeName).thenReturn('Income Loc');

        expect(
          AppFunctions.getTypeName(
            CategoryType.expense,
            mockAppLocalizations,
          ),
          'Expense Loc',
        );
        expect(
          AppFunctions.getTypeName(CategoryType.income, mockAppLocalizations),
          'Income Loc',
        );
      });
    });
  });
}
