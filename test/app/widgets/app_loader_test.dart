import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

void main() {
  group('AppLoader', () {
    testWidgets('shows and hides loading dialog', (tester) async {
      late AppLoader loader;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) {
                loader = AppLoader(context);
                return ElevatedButton(
                  onPressed: () => loader.showLoading(),
                  child: const Text('Show'),
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.text('Show'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.byType(CircularLoadingAnimation), findsOneWidget);
      expect(find.text('Loading...'), findsOneWidget);

      loader.hideLoading();
      await tester.pumpAndSettle();

      expect(find.byType(CircularLoadingAnimation), findsNothing);
    });
  });
}
