import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  group('MonthSelector', () {
    late AppCubit appCubit;
    final monthSelected = DateTime(2024, 3, 5);
    var backCalled = false;
    var forwardCalled = false;

    setUp(() {
      appCubit = MockAppCubit();
      when(() => appCubit.state).thenReturn(const AppState());
      backCalled = false;
      forwardCalled = false;
    });

    testWidgets('renders normally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthSelector(
                monthSelected: monthSelected,
                onBack: () => backCalled = true,
                onForward: () => forwardCalled = true,
                onChangeMonth: (d) {},
              ),
            ),
          ),
        ),
      );

      expect(find.textContaining('2024'), findsOneWidget);
    });

    testWidgets('calls onBack and onForward', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(
              body: MonthSelector(
                monthSelected: monthSelected,
                onBack: () => backCalled = true,
                onForward: () => forwardCalled = true,
                onChangeMonth: (d) {},
              ),
            ),
          ),
        ),
      );

      final iconButtons = find.byType(IconButton);
      await tester.tap(iconButtons.at(0));
      expect(backCalled, isTrue);

      await tester.tap(iconButtons.at(1));
      expect(forwardCalled, isTrue);
    });
  });
}
