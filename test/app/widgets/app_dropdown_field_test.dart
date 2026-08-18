import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  group('AppDropdownField', () {
    testWidgets('renders normally', (tester) async {
      final options = [
        const DropdownMenuItem(value: 1, child: Text('Option 1')),
        const DropdownMenuItem(value: 2, child: Text('Option 2')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDropdownField<int>(
              label: 'Dropdown',
              options: options,
              selected: 1,
            ),
          ),
        ),
      );

      expect(find.text('Option 1'), findsOneWidget);
    });

    testWidgets('triggers onChanged', (tester) async {
      int? selectedValue;
      final options = [
        const DropdownMenuItem(value: 1, child: Text('Option 1')),
        const DropdownMenuItem(value: 2, child: Text('Option 2')),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppDropdownField<int>(
              label: 'Dropdown',
              options: options,
              selected: 1,
              onChanged: (value) => selectedValue = value,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(DropdownButton<int>));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Option 2').last);
      await tester.pumpAndSettle();

      expect(selectedValue, 2);
    });
  });
}
