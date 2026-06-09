import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

void main() {
  group('TotalSpentChart', () {
    final data = [
      const CategoryData(
        category: Category(
          id: '1',
          name: 'Food',
          color: '#FF0000',
          icon: 'food',
          type: CategoryType.expense,
        ),
        value: 100,
      ),
      const CategoryData(
        category: Category(
          id: '2',
          name: 'Transport',
          color: '#00FF00',
          icon: 'bus',
          type: CategoryType.expense,
        ),
        value: 50.5,
      ),
    ];

    testWidgets('renders normally with sum', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: TotalSpentChart(data: data)),
        ),
      );

      expect(find.text('Total'), findsOneWidget);
      expect(find.textContaining('150.50'), findsOneWidget);
    });
  });
}
