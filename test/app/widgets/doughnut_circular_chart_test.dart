import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

void main() {
  group('DoughnutCircularChart', () {
    final data = [
      const CategoryData(
        category: Category(
          id: '1',
          name: 'FEEDING',
          color: '#FF0000',
          icon: 'food',
          type: CategoryType.expense,
        ),
        value: 100,
      ),
      const CategoryData(
        category: Category(
          id: '2',
          name: 'TRANSPORT',
          color: '#00FF00',
          icon: 'bus',
          type: CategoryType.expense,
        ),
        value: 50,
      ),
    ];

    testWidgets('renders normally with annotations', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: DoughnutCircularChart(data: data)),
        ),
      );

      expect(find.byType(SfCircularChart), findsOneWidget);
      expect(
        find.byWidgetPredicate(
          (widget) =>
              widget is Text && widget.data != null && widget.data!.isNotEmpty,
        ),
        findsWidgets,
      );
      expect(find.textContaining('100'), findsOneWidget);
      expect(find.text('66%'), findsOneWidget);

      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('navigates to details on button press', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: DoughnutCircularChart(data: data, selectedIndex: 1),
            ),
          ),
          GoRoute(
            name: AppRoute.category.name,
            path: '/category',
            builder: (context, state) =>
                const Scaffold(body: Text('Category Detail Page')),
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          routerConfig: router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      );

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Category Detail Page'), findsOneWidget);
    });
  });
}
