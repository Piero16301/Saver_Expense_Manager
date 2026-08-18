import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/animations/circular_loading_animation.dart';

void main() {
  group('CircularLoadingAnimation', () {
    testWidgets('renders normally and verifies properties', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularLoadingAnimation(
              outerCircleColor: Colors.red,
              innerCircleColor: Colors.blue,
              backgroundColor: Colors.green,
              size: 150,
            ),
          ),
        ),
      );

      expect(find.byType(CircularLoadingAnimation), findsOneWidget);
      expect(find.byType(CustomPaint), findsWidgets);

      final container = tester.widget<Container>(
        find
            .descendant(
              of: find.byType(CircularLoadingAnimation),
              matching: find.byType(Container),
            )
            .first,
      );

      expect((container.decoration! as BoxDecoration).color, Colors.green);
      expect(container.constraints?.maxWidth, 150.0);
      expect(container.constraints?.maxHeight, 150.0);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('renders center widget if provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularLoadingAnimation(
              outerCircleColor: Colors.red,
              innerCircleColor: Colors.blue,
              backgroundColor: Colors.green,
              centerWidget: Text('Loading...', key: Key('center_widget')),
            ),
          ),
        ),
      );

      expect(find.byKey(const Key('center_widget')), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('animates and repaints correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularLoadingAnimation(
              outerCircleColor: Colors.red,
              innerCircleColor: Colors.blue,
              backgroundColor: Colors.green,
            ),
          ),
        ),
      );

      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularLoadingAnimation(
              outerCircleColor: Colors.yellow,
              innerCircleColor: Colors.purple,
              backgroundColor: Colors.black,
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: CircularLoadingAnimation(
              outerCircleColor: Colors.yellow,
              innerCircleColor: Colors.purple,
              backgroundColor: Colors.black,
            ),
          ),
        ),
      );

      await tester.pump();

      await tester.pumpWidget(const SizedBox());
    });
  });
}
