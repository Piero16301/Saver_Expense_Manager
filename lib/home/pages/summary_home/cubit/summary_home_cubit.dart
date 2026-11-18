import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:saver_expense_manager/app/app.dart';

part 'summary_home_state.dart';

class SummaryHomeCubit extends Cubit<SummaryHomeState> {
  new() : super(SummaryHomeState.initial());

  void changeStartMonth(DateTime? month) {
    emit(state.copyWith(startMonth: month));
  }

  void changeEndMonth(DateTime? month) {
    emit(state.copyWith(endMonth: month));
  }

  void changeStartYear(DateTime? year) {
    emit(state.copyWith(startYear: year));
  }

  void changeEndYear(DateTime? year) {
    emit(state.copyWith(endYear: year));
  }

  void changePeriodType(SummaryPeriodType periodType) {
    getIt<AnalyticsService>().logEvent(
      name: 'change_summary_period',
      parameters: {'period': periodType.name},
    );
    emit(state.copyWith(periodType: periodType));
  }

  void toggleResumeItem(ResumeItemType resumeItemType) {
    final newSelResumeItems = Map<ResumeItemType, bool>.from(
      state.selResumeItems,
    );
    newSelResumeItems[resumeItemType] =
        !(newSelResumeItems[resumeItemType] ?? true);
    getIt<AnalyticsService>().logEvent(
      name: 'toggle_summary_series',
      parameters: {
        'series': resumeItemType.name,
        'selected': newSelResumeItems[resumeItemType]!.toString(),
      },
    );
    emit(state.copyWith(selResumeItems: newSelResumeItems));
  }
}
