import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/cubit/home_cubit.dart';

class MockRemoteConfigService extends Mock implements RemoteConfigService {}

void main() {
  late MockRemoteConfigService mockRemoteConfigService;

  setUp(() {
    mockRemoteConfigService = MockRemoteConfigService();
    when(() => mockRemoteConfigService.homeInitialTab).thenReturn('summary');
    getIt.registerSingleton<RemoteConfigService>(mockRemoteConfigService);
  });

  tearDown(getIt.reset);

  group('HomeState', () {
    test('supports value equality', () {
      expect(
        const HomeState(selectedIndex: 0),
        equals(const HomeState(selectedIndex: 0)),
      );
    });

    test('initial state gets correct tab index from RemoteConfigService', () {
      final state = HomeState.initial();
      expect(
        state.selectedIndex,
        equals(0),
      );
    });

    test('copyWith returns exactly the same state if no params passed', () {
      const state = HomeState(selectedIndex: 1);
      expect(state.copyWith(), equals(state));
    });

    test('copyWith updates selectedIndex correctly', () {
      const state = HomeState(selectedIndex: 0);
      expect(
        state.copyWith(selectedIndex: 2),
        equals(const HomeState(selectedIndex: 2)),
      );
    });
  });

  group('HomeCubit', () {
    test('initial state is HomeState.initial()', () {
      expect(HomeCubit().state, equals(HomeState.initial()));
    });

    blocTest<HomeCubit, HomeState>(
      'toggleSelectedIndex emits correct state with new index',
      build: HomeCubit.new,
      act: (cubit) => cubit.toggleSelectedIndex(2),
      expect: () => [
        const HomeState(selectedIndex: 2),
      ],
    );
  });
}
