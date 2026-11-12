part of 'summary_home_cubit.dart';

class SummaryHomeState extends Equatable {
  const new({
    this.startMonth,
    this.endMonth,
    this.startYear,
    this.endYear,
    this.periodType = SummaryPeriodType.month,
    this.selResumeItems = const <ResumeItemType, bool>{},
  });

  factory initial() {
    final lastMonths = getIt<RemoteConfigService>().summaryLastMonths;
    final lastYears = getIt<RemoteConfigService>().summaryLastYears;
    final now = DateTime.now();

    return SummaryHomeState(
      startMonth: AppFunctions.substracMonth(lastMonths),
      endMonth: now,
      startYear: AppFunctions.substracYear(lastYears),
      endYear: now,
      selResumeItems: const <ResumeItemType, bool>{
        ResumeItemType.income: true,
        ResumeItemType.balance: true,
        ResumeItemType.expense: true,
      },
    );
  }

  final DateTime? startMonth;
  final DateTime? endMonth;
  final DateTime? startYear;
  final DateTime? endYear;
  final SummaryPeriodType periodType;
  final Map<ResumeItemType, bool> selResumeItems;

  SummaryHomeState copyWith({
    DateTime? startMonth,
    DateTime? endMonth,
    DateTime? startYear,
    DateTime? endYear,
    SummaryPeriodType? periodType,
    Map<ResumeItemType, bool>? selResumeItems,
  }) {
    return SummaryHomeState(
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      startYear: startYear ?? this.startYear,
      endYear: endYear ?? this.endYear,
      periodType: periodType ?? this.periodType,
      selResumeItems: selResumeItems ?? this.selResumeItems,
    );
  }

  @override
  List<Object?> get props => [
    startMonth,
    endMonth,
    startYear,
    endYear,
    periodType,
    selResumeItems,
  ];
}
