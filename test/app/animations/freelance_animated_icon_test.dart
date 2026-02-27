import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/animations/freelance_animated_icon.dart';

void main() {
  testWidgets('FreelanceAnimatedIcon renders and animates without errors',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: FreelanceAnimatedIcon(color: Colors.blue, size: 40),
        ),
      ),
    );

    expect(find.byType(FreelanceAnimatedIcon), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.pump(const Duration(milliseconds: 500));

    await tester.pump(const Duration(milliseconds: 1000));
  });
}
