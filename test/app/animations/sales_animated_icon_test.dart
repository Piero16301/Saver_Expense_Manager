import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/animations/sales_animated_icon.dart';

void main() {
  testWidgets('SalesAnimatedIcon renders and animates without errors',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SalesAnimatedIcon(color: Colors.blue, size: 40),
        ),
      ),
    );

    expect(find.byType(SalesAnimatedIcon), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.pump(const Duration(milliseconds: 500));

    await tester.pump(const Duration(milliseconds: 1000));
  });
}
