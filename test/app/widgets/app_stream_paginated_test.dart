import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  late MockRemoteConfigService mockRemoteConfig;

  setUp(() async {
    mockRemoteConfig = MockRemoteConfigService();
    if (getIt.isRegistered<RemoteConfigService>()) {
      await getIt.unregister<RemoteConfigService>();
    }
    getIt.registerSingleton<RemoteConfigService>(mockRemoteConfig);

    when(() => mockRemoteConfig.paginationLimit).thenReturn(5);
  });

  tearDown(getIt.reset);

  group('AppStreamPaginated', () {
    testWidgets('shows loading state when stream has no data', (tester) async {
      final controller = StreamController<List<String>>();

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppStreamPaginated<String>(
              stream: (_) => controller.stream,
              itemBuilder: (context, docs, index) => Text(docs[index]),
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await controller.close();
    });

    testWidgets('shows empty state when stream returns empty list', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppStreamPaginated<String>(
              stream: (_) => Stream.value([]),
              itemBuilder: (context, docs, index) => Text(docs[index]),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('No elements registered'), findsOneWidget);
    });

    testWidgets('shows error state when stream has error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppStreamPaginated<String>(
              stream: (_) => Stream.error('Error'),
              itemBuilder: (context, docs, index) => Text(docs[index]),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(
        find.text('An error occurred while loading the elements'),
        findsOneWidget,
      );
    });

    testWidgets('renders items when data is present', (tester) async {
      final items = ['Item 1', 'Item 2', 'Item 3'];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppStreamPaginated<String>(
              stream: (_) => Stream.value(items),
              itemBuilder: (context, docs, index) => Text(docs[index]),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Item 1'), findsOneWidget);
      expect(find.text('Item 2'), findsOneWidget);
      expect(find.text('Item 3'), findsOneWidget);
    });

    testWidgets('increments limit when scrolling to bottom', (tester) async {
      final streamCalls = <int>[];

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: SizedBox(
              height: 200,
              child: AppStreamPaginated<String>(
                stream: (limit) {
                  streamCalls.add(limit);
                  return Stream.value(List.generate(limit, (i) => 'Item $i'));
                },
                itemBuilder: (context, docs, index) =>
                    SizedBox(height: 100, child: Text(docs[index])),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(streamCalls, [5]);

      await tester.drag(find.byType(ListView), const Offset(0, -400));
      await tester.pumpAndSettle();

      expect(streamCalls.length, 2);
      expect(streamCalls[1], 10);

      await tester.drag(find.byType(ListView), const Offset(0, -600));
      await tester.pumpAndSettle();

      expect(find.text('Item 9'), findsOneWidget);
    });
  });
}
