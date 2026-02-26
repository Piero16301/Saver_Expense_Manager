import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/profile/cubit/profile_cubit.dart';

class MockAuthenticationService extends Mock implements AuthenticationService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockAppUser extends Mock implements AppUser {}

void main() {
  late MockAuthenticationService mockAuthenticationService;
  late MockAppLocalizations mockAppLocalizations;
  late StreamController<AppUser?> userChangesController;
  late ProfileCubit profileCubit;

  setUp(() {
    mockAuthenticationService = MockAuthenticationService();
    mockAppLocalizations = MockAppLocalizations();
    userChangesController = StreamController<AppUser?>();

    when(() => mockAppLocalizations.genericError).thenReturn('Error');
    when(() => mockAuthenticationService.userChanges)
        .thenAnswer((_) => userChangesController.stream);

    profileCubit = ProfileCubit(authService: mockAuthenticationService);
  });

  tearDown(() {
    unawaited(userChangesController.close());
    unawaited(profileCubit.close());
  });

  group('ProfileCubit', () {
    test('initial state is correct', () {
      expect(profileCubit.state, const ProfileState());
    });

    blocTest<ProfileCubit, ProfileState>(
      'emits correct state on userChanges',
      build: () => profileCubit,
      act: (_) {
        final mockUser = MockAppUser();
        when(() => mockUser.displayName).thenReturn('User Name');
        userChangesController.add(mockUser);
      },
      expect: () {
        return [
          isA<ProfileState>()
              .having((s) => s.userName, 'userName', 'User Name')
              .having((s) => s.status, 'status', ProfileStatus.success),
        ];
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'nameChanged updates state',
      build: () => profileCubit,
      act: (cubit) => cubit.nameChanged('New Name'),
      expect: () => [
        const ProfileState(userName: 'New Name'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'toggleEditingName toggles editing',
      build: () => profileCubit,
      act: (cubit) => cubit.toggleEditingName(),
      expect: () => [
        const ProfileState(isEditingName: true),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'saveName updates display name',
      build: () => profileCubit,
      seed: () => const ProfileState(userName: 'New Name'),
      setUp: () {
        when(() => mockAuthenticationService.updateDisplayName(any()))
            .thenAnswer((_) async {});
      },
      act: (cubit) => cubit.saveName(mockAppLocalizations),
      expect: () => const [
        ProfileState(userName: 'New Name', status: ProfileStatus.loading),
        ProfileState(
          userName: 'New Name',
          status: ProfileStatus.success,
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'saveName handles failure',
      build: () => profileCubit,
      seed: () => const ProfileState(userName: 'New Name'),
      setUp: () {
        when(() => mockAuthenticationService.updateDisplayName(any()))
            .thenThrow(Exception());
      },
      act: (cubit) => cubit.saveName(mockAppLocalizations),
      expect: () => const [
        ProfileState(userName: 'New Name', status: ProfileStatus.loading),
        ProfileState(
          userName: 'New Name',
          status: ProfileStatus.failure,
          errorMessage: 'Error',
        ),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'linkGoogle works correctly',
      build: () => profileCubit,
      setUp: () {
        when(() => mockAuthenticationService.linkWithGoogle())
            .thenAnswer((_) async => null);
      },
      act: (cubit) => cubit.linkGoogle(mockAppLocalizations),
      expect: () => const [
        ProfileState(status: ProfileStatus.loading),
        ProfileState(status: ProfileStatus.success),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'logout signs out',
      build: () => profileCubit,
      setUp: () {
        when(() => mockAuthenticationService.signOut())
            .thenAnswer((_) async {});
      },
      act: (cubit) => cubit.logout(mockAppLocalizations),
      expect: () => const <ProfileState>[],
    );
  });
}
