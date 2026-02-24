import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/profile/cubit/profile_cubit.dart';

class MockAppUser extends Mock implements AppUser {}

void main() {
  group('ProfileState', () {
    test('supports value equality', () {
      expect(
        const ProfileState(),
        equals(const ProfileState()),
      );
    });

    test('props are correct', () {
      expect(
        const ProfileState().props,
        equals(<Object?>[
          ProfileStatus.initial,
          null,
          '',
          false,
          null,
        ]),
      );
    });

    test('copyWith returns object with updated properties', () {
      final mockAppUser = MockAppUser();
      expect(
        const ProfileState().copyWith(
          user: mockAppUser,
          userName: 'test',
          status: ProfileStatus.success,
          errorMessage: 'error',
          isEditingName: true,
        ),
        equals(
          ProfileState(
            user: mockAppUser,
            userName: 'test',
            status: ProfileStatus.success,
            errorMessage: 'error',
            isEditingName: true,
          ),
        ),
      );
    });

    test('copyWith returns original object when properties are null', () {
      expect(
        const ProfileState().copyWith(),
        equals(const ProfileState()),
      );
    });
  });
}
