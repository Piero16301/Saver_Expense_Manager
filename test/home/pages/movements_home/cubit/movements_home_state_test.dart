import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/pages/movements_home/cubit/movements_home_cubit.dart';

void main() {
  group('MovementsHomeState', () {
    test('supports value equality', () {
      expect(const MovementsHomeState(), equals(const MovementsHomeState()));
    });

    test('props are correct', () {
      expect(
        const MovementsHomeState().props,
        equals(<Object?>[
          null,
          null,
          RecommendationsStatus.initial,
          null,
          true,
        ]),
      );
    });

    test('copyWith returns object with updated properties', () {
      const type = CategoryType.expense;
      const category = Category(
        id: '1',
        name: 'Food',
        icon: 'pizza',
        color: 'red',
        type: type,
      );
      const recs = ['Test 1'];
      expect(
        const MovementsHomeState().copyWith(
          filterType: type,
          filterCategory: category,
          recommendationsStatus: RecommendationsStatus.success,
          recommendations: recs,
          showRecommendations: false,
        ),
        equals(
          const MovementsHomeState(
            filterType: type,
            filterCategory: category,
            recommendationsStatus: RecommendationsStatus.success,
            recommendations: <String>['Test 1'],
            showRecommendations: false,
          ),
        ),
      );
    });

    test('copyWith returns original object when properties are null', () {
      expect(
        const MovementsHomeState().copyWith(),
        equals(const MovementsHomeState()),
      );
    });
  });

  group('RecommendationsStatus', () {
    test('getters return correct values', () {
      expect(RecommendationsStatus.initial.isInitial, isTrue);
      expect(RecommendationsStatus.loading.isLoading, isTrue);
      expect(RecommendationsStatus.success.isSuccess, isTrue);
      expect(RecommendationsStatus.failure.isFailure, isTrue);
    });
  });
}
