import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:saver_expense_manager/app/app.dart';

part 'movements_home_state.dart';

class MovementsHomeCubit extends Cubit<MovementsHomeState> {
  MovementsHomeCubit() : super(const MovementsHomeState()) {
    unawaited(getRecommendations());
  }

  void updateFilterType(CategoryType? type) {
    emit(
      state.copyWith(
        filterType: type,
        filterCategory: type == null
            ? null
            : type == state.filterType
                ? state.filterCategory
                : null,
      ),
    );
  }

  void updateFilterCategory(Category? category) {
    emit(
      state.copyWith(
        filterType: state.filterType,
        filterCategory: category,
      ),
    );
  }

  void changeShowRecommendations() {
    emit(state.copyWith(showRecommendations: !state.showRecommendations));
  }

  Future<void> getRecommendations() async {
    final localStorage = getIt<LocalStorageService>();
    var nowDate = DateTime.now();
    nowDate = DateTime(nowDate.year, nowDate.month, nowDate.day);
    final recommendationsDate = localStorage.getRecommendationsDate();

    if (recommendationsDate != null &&
        recommendationsDate.isAtSameMomentAs(nowDate)) {
      emit(
        state.copyWith(
          recommendationsStatus: RecommendationsStatus.success,
          recommendations: localStorage.getRecommendations(),
          showRecommendations: false,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        recommendationsStatus: RecommendationsStatus.loading,
      ),
    );

    try {
      final auth = getIt<AuthenticationService>().auth;
      final language = getIt<LocalStorageService>().getLanguage() ??
          AppVariables.supportedLocales.first;
      final recommendations = await AppFunctions.getAntRecommendations(
        userId: auth.currentUser!.uid,
        language: '${language.languageCode}-${language.countryCode}',
      );
      if (recommendations != null) {
        localStorage
          ..saveRecommendations(recommendations: recommendations)
          ..saveRecommendationsDate(date: nowDate);
      }
      emit(
        state.copyWith(
          recommendationsStatus: RecommendationsStatus.success,
          recommendations: recommendations,
          showRecommendations: true,
        ),
      );
    } on Exception catch (_) {
      emit(
        state.copyWith(
          recommendationsStatus: RecommendationsStatus.failure,
        ),
      );
    }
  }
}
