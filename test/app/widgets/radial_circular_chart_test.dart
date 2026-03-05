import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class MockHttpClient extends Mock implements HttpClient {}

class MockHttpClientRequest extends Mock implements HttpClientRequest {}

class MockHttpClientResponse extends Mock implements HttpClientResponse {}

class MockHttpHeaders extends Mock implements HttpHeaders {}

void main() {
  setUpAll(() {
    registerFallbackValue(Uri());
    registerFallbackValue(FakeStreamSubscription<List<int>>());
  });

  group('RadialCircularChart', () {
    final data = [
      const CategoryData(
        category: Category(
          id: '1',
          name: 'FEEDING',
          color: '#FF0000',
          icon: 'food',
          type: CategoryType.expense,
        ),
        value: 40,
      ),
      const CategoryData(
        category: Category(
          id: '2',
          name: 'TRANSPORT',
          color: '#00FF00',
          icon: 'bus',
          type: CategoryType.expense,
        ),
        value: 20,
      ),
    ];

    testWidgets('renders normally with legend', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: RadialCircularChart(
              data: data,
            ),
          ),
        ),
      );

      expect(find.byType(SfCircularChart), findsOneWidget);
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();
    });

    testWidgets('renders image if provided', (tester) async {
      final mockHttpClient = MockHttpClient();
      final mockRequest = MockHttpClientRequest();
      final mockResponse = MockHttpClientResponse();
      final mockHeaders = MockHttpHeaders();

      when(() => mockHttpClient.getUrl(any()))
          .thenAnswer((_) async => mockRequest);
      when(() => mockRequest.headers).thenReturn(mockHeaders);
      when(mockRequest.close).thenAnswer((_) async => mockResponse);
      when(() => mockResponse.statusCode).thenReturn(HttpStatus.ok);
      when(() => mockResponse.contentLength).thenReturn(0);
      when(() => mockResponse.compressionState)
          .thenReturn(HttpClientResponseCompressionState.notCompressed);
      when(
        () => mockResponse.listen(
          any(),
          onError: any(named: 'onError'),
          onDone: any(named: 'onDone'),
          cancelOnError: any(named: 'cancelOnError'),
        ),
      ).thenAnswer((invocation) {
        final onData =
            invocation.positionalArguments[0] as void Function(List<int>);
        final onDone = invocation.namedArguments[#onDone] as void Function()?;
        onData(
          Uint8List.fromList([
            0x47,
            0x49,
            0x46,
            0x38,
            0x39,
            0x61,
            0x01,
            0x00,
            0x01,
            0x00,
            0x80,
            0x00,
            0x00,
            0xFF,
            0xFF,
            0xFF,
            0x00,
            0x00,
            0x00,
            0x21,
            0xf9,
            0x04,
            0x01,
            0x00,
            0x00,
            0x00,
            0x00,
            0x2c,
            0x00,
            0x00,
            0x00,
            0x00,
            0x01,
            0x00,
            0x01,
            0x00,
            0x00,
            0x02,
            0x02,
            0x44,
            0x01,
            0x00,
            0x3b,
          ]),
        );
        onDone?.call();
        return FakeStreamSubscription<List<int>>();
      });

      await HttpOverrides.runZoned(
        () async {
          await tester.pumpWidget(
            const MaterialApp(
              home: Scaffold(
                body: RadialCircularChart(
                  data: [],
                  image: 'https://example.com/image.png',
                ),
              ),
            ),
          );

          expect(find.byType(Image), findsOneWidget);
          await tester.pump(const Duration(seconds: 1));
          await tester.pumpAndSettle();
        },
        createHttpClient: (_) => mockHttpClient,
      );
    });
  });
}

class FakeStreamSubscription<T> extends Fake implements StreamSubscription<T> {
  @override
  Future<void> cancel() async {}
}
