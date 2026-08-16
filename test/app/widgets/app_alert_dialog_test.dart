import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  group('AppAlertDialog', () {
    testWidgets('renders normally with title and content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAlertDialog(
              title: 'Confirm',
              content: 'Are you sure?',
              confirmLabel: 'Yes',
              cancelLabel: 'No',
              onConfirm: () {},
              onCancel: () {},
            ),
          ),
        ),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Are you sure?'), findsOneWidget);
      expect(find.text('Yes'), findsOneWidget);
      expect(find.text('No'), findsOneWidget);
    });

    testWidgets('renders with child instead of content', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAlertDialog(
              title: 'Dialog',
              confirmLabel: 'OK',
              cancelLabel: 'Cancel',
              onConfirm: () {},
              onCancel: () {},
              child: const Text('Custom child'),
            ),
          ),
        ),
      );

      expect(find.text('Custom child'), findsOneWidget);
    });

    testWidgets('triggers callbacks', (tester) async {
      var confirmed = false;
      var cancelled = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppAlertDialog(
              title: 'Dialog',
              confirmLabel: 'OK',
              cancelLabel: 'Cancel',
              onConfirm: () => confirmed = true,
              onCancel: () => cancelled = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('OK'));
      expect(confirmed, isTrue);

      await tester.tap(find.text('Cancel'));
      expect(cancelled, isTrue);
    });
  });
}
