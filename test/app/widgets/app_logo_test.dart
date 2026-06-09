import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  group('AppLogo', () {
    testWidgets('renders normally with default size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLogo())),
      );

      expect(find.byType(Image), findsOneWidget);
      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, 100);
      expect(image.height, 100);
    });

    testWidgets('renders normally with custom size', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: AppLogo(width: 50, height: 50))),
      );

      final image = tester.widget<Image>(find.byType(Image));
      expect(image.width, 50);
      expect(image.height, 50);
    });
  });
}
