import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/home/pages/summary_home/cubit/summary_home_cubit.dart';

void main() {
  group('SummaryHomeState', () {
    test('supports value equality', () {
      expect(const SummaryHomeState(), equals(const SummaryHomeState()));
    });

    test('props are correct', () {
      expect(
        const SummaryHomeState().props,
        equals(<Object?>[null, null, const <ResumeItemType, bool>{}]),
      );
    });

    test('copyWith returns object with updated properties', () {
      final start = DateTime(2022);
      final end = DateTime(2023);
      const items = <ResumeItemType, bool>{ResumeItemType.income: false};
      expect(
        const SummaryHomeState().copyWith(
          startMonth: start,
          endMonth: end,
          selResumeItems: items,
        ),
        equals(
          SummaryHomeState(
            startMonth: start,
            endMonth: end,
            selResumeItems: items,
          ),
        ),
      );
    });

    test('copyWith returns original object when properties are null', () {
      expect(
        const SummaryHomeState().copyWith(),
        equals(const SummaryHomeState()),
      );
    });
  });
}
