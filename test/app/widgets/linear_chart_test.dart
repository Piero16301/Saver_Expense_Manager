import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  group('LinearChart', () {
    final titles = ['Income', 'Expense'];
    final colors = [Colors.green, Colors.red];
    final data = [
      [
        const LinearChartData(xValue: 'Jan', yValue: 1000),
        const LinearChartData(xValue: 'Feb', yValue: 1200),
      ],
      [
        const LinearChartData(xValue: 'Jan', yValue: 800),
        const LinearChartData(xValue: 'Feb', yValue: 900),
      ],
    ];

    testWidgets('renders normally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: LinearChart(
              titles: titles,
              colors: colors,
              data: data,
            ),
          ),
        ),
      );

      expect(find.byType(SfCartesianChart), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
    });
  });
}
