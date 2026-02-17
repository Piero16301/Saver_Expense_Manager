import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

void main() {
  group('AppLocalizationsX', () {
    testWidgets('l10n returns AppLocalizations instance', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) {
              expect(context.l10n, isA<AppLocalizations>());
              return const SizedBox();
            },
          ),
        ),
      );
    });
  });
}
