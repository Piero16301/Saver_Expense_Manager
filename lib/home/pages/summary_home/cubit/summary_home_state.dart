part of 'summary_home_cubit.dart';

class SummaryHomeState extends Equatable {
  const SummaryHomeState({
    this.startMonth,
    this.endMonth,
    this.selResumeItems = const <ResumeItemType, bool>{},
  });

  factory SummaryHomeState.initial() {
    return SummaryHomeState(
      startMonth: AppFunctions.substracMonth(
        getIt<RemoteConfigService>().summaryLastMonths,
      ),
      endMonth: DateTime.now(),
      selResumeItems: const <ResumeItemType, bool>{
        ResumeItemType.income: true,
        ResumeItemType.balance: true,
        ResumeItemType.expense: true,
      },
    );
  }

  final DateTime? startMonth;
  final DateTime? endMonth;
  final Map<ResumeItemType, bool> selResumeItems;

  SummaryHomeState copyWith({
    DateTime? startMonth,
    DateTime? endMonth,
    Map<ResumeItemType, bool>? selResumeItems,
  }) {
    return SummaryHomeState(
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      selResumeItems: selResumeItems ?? this.selResumeItems,
    );
  }

  @override
  List<Object?> get props => [startMonth, endMonth, selResumeItems];
}
