part of 'movements_home_cubit.dart';

enum RecommendationsStatus {
  initial,
  loading,
  success,
  failure;

  bool get isInitial => this == RecommendationsStatus.initial;
  bool get isLoading => this == RecommendationsStatus.loading;
  bool get isSuccess => this == RecommendationsStatus.success;
  bool get isFailure => this == RecommendationsStatus.failure;
}

class MovementsHomeState extends Equatable {
  const MovementsHomeState({
    this.filterType,
    this.filterCategory,
    this.recommendationsStatus = RecommendationsStatus.initial,
    this.recommendations,
    this.showRecommendations = true,
  });

  final CategoryType? filterType;
  final Category? filterCategory;
  final RecommendationsStatus recommendationsStatus;
  final List<String>? recommendations;
  final bool showRecommendations;

  MovementsHomeState copyWith({
    CategoryType? filterType,
    Category? filterCategory,
    RecommendationsStatus? recommendationsStatus,
    List<String>? recommendations,
    bool? showRecommendations,
  }) {
    return MovementsHomeState(
      filterType: filterType,
      filterCategory: filterCategory,
      recommendationsStatus:
          recommendationsStatus ?? this.recommendationsStatus,
      recommendations: recommendations ?? this.recommendations,
      showRecommendations: showRecommendations ?? this.showRecommendations,
    );
  }

  @override
  List<Object?> get props => [
    filterType,
    filterCategory,
    recommendationsStatus,
    recommendations,
    showRecommendations,
  ];
}
