import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  group('AppFilledButton', () {
    testWidgets('renders with label only', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppFilledButton(
              label: 'Click me',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Click me'), findsOneWidget);
      await tester.tap(find.byType(AppFilledButton));
      expect(pressed, isTrue);
    });

    testWidgets('renders with icon and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppFilledButton(label: 'Home', icon: Icon(Icons.home)),
          ),
        ),
      );

      expect(find.text('Home'), findsOneWidget);
      expect(find.byIcon(Icons.home), findsOneWidget);
    });

    testWidgets('renders only icon when isOnlyIcon is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppFilledButton(icon: Icon(Icons.add), isOnlyIcon: true),
          ),
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('renders icon as label if label is null', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppFilledButton(icon: Icon(Icons.star))),
        ),
      );

      expect(find.byIcon(Icons.star), findsNWidgets(2));
    });

    testWidgets(
      'uses VisualDensity.standard by default even in compact theme',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(visualDensity: VisualDensity.compact),
            home: const Scaffold(body: AppFilledButton(label: 'Click me')),
          ),
        );

        final button = tester.widget<FilledButton>(find.byType(FilledButton));
        expect(button.style?.visualDensity, equals(VisualDensity.standard));
      },
    );
  });
}
