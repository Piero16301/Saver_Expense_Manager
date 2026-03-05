import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  group('AppTextField', () {
    testWidgets('renders normally with label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(label: 'Email'),
          ),
        ),
      );

      expect(find.text('Email'), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('triggers onChanged', (tester) async {
      var value = '';
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Name',
              onChanged: (v) => value = v,
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(AppTextField), 'John');
      expect(value, 'John');
    });

    testWidgets('shows error when isRequired and empty', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Required',
              errorText: 'Field required',
            ),
          ),
        ),
      );

      await tester.enterText(find.byType(AppTextField), 'test');
      await tester.enterText(find.byType(AppTextField), '');
      await tester.pump();
      expect(find.text('Field required'), findsOneWidget);
    });

    testWidgets('renders with prefix and suffix', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Search',
              prefix: Icon(Icons.search),
              suffix: Icon(Icons.clear),
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.search), findsOneWidget);
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('uses initialValue', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Initial',
              initialValue: 'Hello',
            ),
          ),
        ),
      );

      expect(find.text('Hello'), findsOneWidget);
    });

    testWidgets('uses controller', (tester) async {
      final controller = TextEditingController(text: 'Controller Text');
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Ctrl',
              controller: controller,
            ),
          ),
        ),
      );

      expect(find.text('Controller Text'), findsOneWidget);
    });

    testWidgets('obscureText works', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AppTextField(
              label: 'Pass',
              obscureText: true,
            ),
          ),
        ),
      );

      final textField = tester.widget<EditableText>(find.byType(EditableText));
      expect(textField.obscureText, isTrue);
    });
  });
}
