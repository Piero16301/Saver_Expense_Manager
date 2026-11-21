import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
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

    testWidgets(
      'hideLoading does not throw when original context is unmounted',
      (tester) async {
        late AppLoader loader;
        var showChild = true;
        late StateSetter setHostState;

        await tester.pumpWidget(
          MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: StatefulBuilder(
              builder: (context, setState) {
                setHostState = setState;
                return Scaffold(
                  body: showChild
                      ? Builder(
                          builder: (childContext) {
                            loader = AppLoader(childContext);
                            return ElevatedButton(
                              onPressed: () => loader.showLoading(),
                              child: const Text('Show'),
                            );
                          },
                        )
                      : const SizedBox.shrink(),
                );
              },
            ),
          ),
        );

        await tester.tap(find.text('Show'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(CircularLoadingAnimation), findsOneWidget);

        setHostState(() => showChild = false);
        await tester.pump();

        expect(() => loader.hideLoading(), returnsNormally);
        await tester.pumpAndSettle();
        expect(find.byType(CircularLoadingAnimation), findsNothing);
      },
    );
  });
}
