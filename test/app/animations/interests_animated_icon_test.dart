import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/animations/interests_animated_icon.dart';

void main() {
  testWidgets('InterestsAnimatedIcon renders and animates without errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: InterestsAnimatedIcon(color: Colors.blue, size: 40),
        ),
      ),
    );

    expect(find.byType(InterestsAnimatedIcon), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.pump(const Duration(milliseconds: 500));

    await tester.pump(const Duration(milliseconds: 1000));
  });
}
