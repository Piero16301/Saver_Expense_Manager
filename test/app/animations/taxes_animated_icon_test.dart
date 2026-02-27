import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/animations/taxes_animated_icon.dart';

void main() {
  testWidgets('TaxesAnimatedIcon renders and animates without errors',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: TaxesAnimatedIcon(color: Colors.blue, size: 40),
        ),
      ),
    );

    expect(find.byType(TaxesAnimatedIcon), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.pump(const Duration(milliseconds: 500));

    await tester.pump(const Duration(milliseconds: 1000));
  });
}
