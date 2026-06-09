import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';

class MockAppCubit extends MockCubit<AppState> implements AppCubit {}

void main() {
  group('ListMovementsItemHome', () {
    late AppCubit appCubit;
    final movement = Movement(
      id: '1',
      title: 'Lunch',
      description: 'Business lunch',
      price: 25.5,
      date: DateTime(2024, 3, 5),
      category: const Category(
        id: '1',
        name: 'FEEDING',
        color: '#FF0000',
        icon: 'RESTAURANT',
        type: CategoryType.expense,
      ),
      user: 'user1',
    );

    setUp(() {
      appCubit = MockAppCubit();
      when(() => appCubit.state).thenReturn(const AppState());
    });

    testWidgets('renders normally', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: BlocProvider.value(
            value: appCubit,
            child: Scaffold(body: ListMovementsItemHome(movement: movement)),
          ),
        ),
      );

      expect(find.text('Lunch'), findsOneWidget);
      expect(find.textContaining('25.50'), findsOneWidget);
    });

    testWidgets('navigates on tap', (tester) async {
      final router = GoRouter(
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => BlocProvider.value(
              value: appCubit,
              child: Scaffold(body: ListMovementsItemHome(movement: movement)),
            ),
          ),
          GoRoute(
            name: AppRoute.movement.name,
            path: '/movement/:type/:screenType',
            builder: (context, state) =>
                const Scaffold(body: Text('Movement Page')),
          ),
        ],
      );

      await tester.pumpWidget(MaterialApp.router(routerConfig: router));

      await tester.tap(find.byType(ListTile));
      await tester.pumpAndSettle();

      expect(find.text('Movement Page'), findsOneWidget);
    });
  });
}
