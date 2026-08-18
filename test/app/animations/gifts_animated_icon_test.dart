import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/animations/gifts_animated_icon.dart';

void main() {
  testWidgets('GiftsAnimatedIcon renders and animates without errors', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: GiftsAnimatedIcon(color: Colors.blue, size: 40)),
      ),
    );

    expect(find.byType(GiftsAnimatedIcon), findsOneWidget);
    expect(find.byType(CustomPaint), findsWidgets);

    await tester.pump(const Duration(milliseconds: 500));

    await tester.pump(const Duration(milliseconds: 1000));
  });
}
