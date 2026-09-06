import 'package:flutter_test/flutter_test.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  group('AppOutlinedButton', () {
    testWidgets('renders with label only', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(body: AppOutlinedButton(label: 'Outlined')),
        ),
      );

      expect(find.text('Outlined'), findsOneWidget);
    });

    testWidgets('renders with icon and label', (tester) async {
      const icon = HugeIcons.strokeRoundedSun03;
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppOutlinedButton(label: 'Add', icon: icon),
          ),
        ),
      );

      expect(find.text('Add'), findsOneWidget);
      expect(find.byType(HugeIcon), findsOneWidget);
    });

    testWidgets('triggers onPressed', (tester) async {
      var pressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppOutlinedButton(
              label: 'Press',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(AppOutlinedButton));
      expect(pressed, isTrue);
    });

    testWidgets(
      'uses VisualDensity.standard by default even in compact theme',
      (tester) async {
        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeData(visualDensity: VisualDensity.compact),
            home: const Scaffold(body: AppOutlinedButton(label: 'Press')),
          ),
        );

        final button = tester.widget<OutlinedButton>(
          find.byType(OutlinedButton),
        );
        expect(button.style?.visualDensity, equals(VisualDensity.standard));
      },
    );
  });
}
