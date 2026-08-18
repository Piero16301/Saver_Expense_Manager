import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/animations/health_animated_icon.dart';

void main() {
  testWidgets('HealthAnimatedIcon renders and animates without errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: HealthAnimatedIcon(color: Colors.blue, size: 40)),
      ),
    );

    expect(find.byType(HealthAnimatedIcon), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.pump(const Duration(milliseconds: 500));

    await tester.pump(const Duration(milliseconds: 1000));
  });
}
