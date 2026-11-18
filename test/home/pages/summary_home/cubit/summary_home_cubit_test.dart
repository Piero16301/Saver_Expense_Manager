import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/pages/summary_home/cubit/summary_home_cubit.dart';

class MockRemoteConfigService extends Mock implements RemoteConfigService;

class MockAnalyticsService extends Mock implements AnalyticsService;

void main() {
  group('SummaryHomeCubit', () {
    late SummaryHomeCubit summaryHomeCubit;
    late MockRemoteConfigService mockRemoteConfigService;
    late MockAnalyticsService mockAnalyticsService;

    setUp(() {
      mockRemoteConfigService = MockRemoteConfigService();
      mockAnalyticsService = MockAnalyticsService();
      when(() => mockRemoteConfigService.summaryLastMonths).thenReturn(4);
      when(() => mockRemoteConfigService.summaryLastYears).thenReturn(4);
      when(
        () => mockAnalyticsService.logEvent(
          name: any(named: 'name'),
          parameters: any(named: 'parameters'),
        ),
      ).thenAnswer((_) {});
      getIt
        ..registerSingleton<RemoteConfigService>(mockRemoteConfigService)
        ..registerSingleton<AnalyticsService>(mockAnalyticsService);

      summaryHomeCubit = SummaryHomeCubit();
    });

    tearDown(getIt.reset);

    test('initial state is correct', () {
      expect(summaryHomeCubit.state.endMonth, isNotNull);
      expect(summaryHomeCubit.state.startMonth, isNotNull);
      expect(summaryHomeCubit.state.endYear, isNotNull);
      expect(summaryHomeCubit.state.startYear, isNotNull);
      expect(summaryHomeCubit.state.periodType, SummaryPeriodType.month);
      expect(summaryHomeCubit.state.selResumeItems, const {
        ResumeItemType.income: true,
        ResumeItemType.balance: true,
        ResumeItemType.expense: true,
      });
    });

    blocTest<SummaryHomeCubit, SummaryHomeState>(
      'changeStartMonth emits correct state',
      build: () => summaryHomeCubit,
      act: (cubit) => cubit.changeStartMonth(DateTime(2023)),
      expect: () => [
        isA<SummaryHomeState>().having(
          (s) => s.startMonth,
          'startMonth',
          DateTime(2023),
        ),
      ],
    );

    blocTest<SummaryHomeCubit, SummaryHomeState>(
      'changeEndMonth emits correct state',
      build: () => summaryHomeCubit,
      act: (cubit) => cubit.changeEndMonth(DateTime(2023, 12)),
      expect: () => [
        isA<SummaryHomeState>().having(
          (s) => s.endMonth,
          'endMonth',
          DateTime(2023, 12),
        ),
      ],
    );

    blocTest<SummaryHomeCubit, SummaryHomeState>(
      'changeStartYear emits correct state',
      build: () => summaryHomeCubit,
      act: (cubit) => cubit.changeStartYear(DateTime(2022)),
      expect: () => [
        isA<SummaryHomeState>().having(
          (s) => s.startYear,
          'startYear',
          DateTime(2022),
        ),
      ],
    );

    blocTest<SummaryHomeCubit, SummaryHomeState>(
      'changeEndYear emits correct state',
      build: () => summaryHomeCubit,
      act: (cubit) => cubit.changeEndYear(DateTime(2024, 12, 31)),
      expect: () => [
        isA<SummaryHomeState>().having(
          (s) => s.endYear,
          'endYear',
          DateTime(2024, 12, 31),
        ),
      ],
    );

    blocTest<SummaryHomeCubit, SummaryHomeState>(
      'changePeriodType emits correct state',
      build: () => summaryHomeCubit,
      act: (cubit) => cubit.changePeriodType(SummaryPeriodType.year),
      expect: () => [
        isA<SummaryHomeState>().having(
          (s) => s.periodType,
          'periodType',
          SummaryPeriodType.year,
        ),
      ],
      verify: (_) {
        verify(
          () => mockAnalyticsService.logEvent(
            name: 'change_summary_period',
            parameters: {'period': 'year'},
          ),
        ).called(1);
      },
    );

    blocTest<SummaryHomeCubit, SummaryHomeState>(
      'toggleResumeItem toggles boolean correctly',
      build: () => summaryHomeCubit,
      act: (cubit) {
        cubit
          ..toggleResumeItem(ResumeItemType.income)
          ..toggleResumeItem(ResumeItemType.income);
      },
      expect: () => [
        isA<SummaryHomeState>().having(
          (s) => s.selResumeItems[ResumeItemType.income],
          'income value',
          false,
        ),
        isA<SummaryHomeState>().having(
          (s) => s.selResumeItems[ResumeItemType.income],
          'income value',
          true,
        ),
      ],
      verify: (_) {
        verify(
          () => mockAnalyticsService.logEvent(
            name: 'toggle_summary_series',
            parameters: {'series': 'income', 'selected': 'false'},
          ),
        ).called(1);
        verify(
          () => mockAnalyticsService.logEvent(
            name: 'toggle_summary_series',
            parameters: {'series': 'income', 'selected': 'true'},
          ),
        ).called(1);
      },
    );
  });
}
