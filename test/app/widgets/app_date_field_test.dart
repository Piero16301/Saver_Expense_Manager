import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  late AppCubit appCubit;

  setUp(() {
    appCubit = MockAppCubit();
  });

  group('AppDateField', () {
    testWidgets('renders normally with formatted date', (tester) async {
      final initialDate = DateTime(2023, 10, 27);
      const state = AppState();
      when(() => appCubit.state).thenReturn(state);
      whenListen(appCubit, Stream.fromIterable([state]));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AppCubit>.value(
              value: appCubit,
              child: AppDateField(label: 'Date', initialDate: initialDate),
            ),
          ),
        ),
      );

      expect(find.text('Date'), findsOneWidget);
      expect(find.textContaining('October 27'), findsOneWidget);
    });

    testWidgets('shows date picker and triggers onDateChanged', (tester) async {
      final initialDate = DateTime(2023, 10, 27);
      DateTime? pickedDate;
      const state = AppState();
      when(() => appCubit.state).thenReturn(state);
      whenListen(appCubit, Stream.fromIterable([state]));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<AppCubit>.value(
              value: appCubit,
              child: AppDateField(
                label: 'Date',
                initialDate: initialDate,
                onDateChanged: (date) => pickedDate = date,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(IconButton));
      await tester.pumpAndSettle();

      await tester.tap(find.text('25'));
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      expect(pickedDate, isNotNull);
      expect(pickedDate!.day, 25);
    });
  });
}
