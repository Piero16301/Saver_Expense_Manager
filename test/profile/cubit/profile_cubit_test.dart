import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/profile/cubit/profile_cubit.dart';

class MockAuthService extends Mock implements AuthService {}

class MockAppLocalizations extends Mock implements AppLocalizations {}

class MockAppUser extends Mock implements AppUser {}

class MockAnalyticsService extends Mock implements AnalyticsService {}

void main() {
  late MockAuthService mockAuthService;
  late MockAppLocalizations mockAppLocalizations;
  late StreamController<AppUser?> userChangesController;
  late ProfileCubit profileCubit;
  late MockAnalyticsService mockAnalyticsService;

  setUp(() async {
    mockAuthService = MockAuthService();
    mockAppLocalizations = MockAppLocalizations();
    userChangesController = StreamController<AppUser?>();
    mockAnalyticsService = MockAnalyticsService();

    if (getIt.isRegistered<AnalyticsService>()) {
      await getIt.unregister<AnalyticsService>();
    }
    getIt.registerSingleton<AnalyticsService>(mockAnalyticsService);

    when(
      () => mockAnalyticsService.logEvent(
        name: any(named: 'name'),
        parameters: any(named: 'parameters'),
      ),
    ).thenAnswer((_) {});

    when(() => mockAppLocalizations.genericError).thenReturn('Error');
    when(() => mockAuthService.userChanges)
        .thenAnswer((_) => userChangesController.stream);

    profileCubit = ProfileCubit(authService: mockAuthService);
  });

  tearDown(() {
    unawaited(userChangesController.close());
    unawaited(profileCubit.close());
  });

  group('ProfileCubit', () {
    test('initial state is correct', () {
      expect(profileCubit.state, const ProfileState());
    });

    test('uses default AuthService if none provided', () async {
      final mockAuth = MockAuthService();
      when(() => mockAuth.userChanges).thenAnswer((_) => const Stream.empty());

      if (getIt.isRegistered<AuthService>()) {
        await getIt.unregister<AuthService>();
      }
      getIt.registerSingleton<AuthService>(mockAuth);

      final cubit = ProfileCubit();
      expect(cubit.state, const ProfileState());
      unawaited(cubit.close());
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
        when(() => mockAuthService.updateDisplayName(any()))
            .thenAnswer((_) async => true);
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
        when(() => mockAuthService.updateDisplayName(any()))
            .thenAnswer((_) async => false);
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
        when(() => mockAuthService.linkWithGoogle())
            .thenAnswer((_) async => true);
      },
      act: (cubit) => cubit.linkGoogle(mockAppLocalizations),
      expect: () => const [
        ProfileState(status: ProfileStatus.loading),
        ProfileState(status: ProfileStatus.success),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'logout handles failure',
      build: () => profileCubit,
      setUp: () {
        when(() => mockAuthService.signOut()).thenAnswer((_) async => false);
      },
      act: (cubit) => cubit.logout(mockAppLocalizations),
      expect: () => const [
        ProfileState(status: ProfileStatus.failure, errorMessage: 'Error'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'logout signs out',
      build: () => profileCubit,
      setUp: () {
        when(() => mockAuthService.signOut()).thenAnswer((_) async => true);
      },
      act: (cubit) => cubit.logout(mockAppLocalizations),
      expect: () => const <ProfileState>[],
    );

    blocTest<ProfileCubit, ProfileState>(
      'linkEmail works correctly',
      build: () => profileCubit,
      setUp: () {
        when(
          () => mockAuthService.linkWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => true);
      },
      act: (cubit) => cubit.linkEmail(
        mockAppLocalizations,
        email: 'email@test.com',
        password: 'password',
      ),
      expect: () => const [
        ProfileState(status: ProfileStatus.loading),
        ProfileState(status: ProfileStatus.success),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'linkEmail handles failure',
      build: () => profileCubit,
      setUp: () {
        when(
          () => mockAuthService.linkWithEmailPassword(
            email: any(named: 'email'),
            password: any(named: 'password'),
          ),
        ).thenAnswer((_) async => false);
      },
      act: (cubit) => cubit.linkEmail(
        mockAppLocalizations,
        email: 'email@test.com',
        password: 'password',
      ),
      expect: () => const [
        ProfileState(status: ProfileStatus.loading),
        ProfileState(status: ProfileStatus.failure, errorMessage: 'Error'),
        ProfileState(errorMessage: 'Error'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'unlinkProvider works correctly',
      build: () => profileCubit,
      setUp: () {
        when(() => mockAuthService.unlinkProvider(any()))
            .thenAnswer((_) async => true);
      },
      act: (cubit) => cubit.unlinkProvider(mockAppLocalizations, 'providerId'),
      expect: () => const [
        ProfileState(status: ProfileStatus.loading),
        ProfileState(status: ProfileStatus.success),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'unlinkProvider handles failure',
      build: () => profileCubit,
      setUp: () {
        when(() => mockAuthService.unlinkProvider(any()))
            .thenAnswer((_) async => false);
      },
      act: (cubit) => cubit.unlinkProvider(mockAppLocalizations, 'providerId'),
      expect: () => const [
        ProfileState(status: ProfileStatus.loading),
        ProfileState(status: ProfileStatus.failure, errorMessage: 'Error'),
        ProfileState(errorMessage: 'Error'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'linkGoogle handles failure',
      build: () => profileCubit,
      setUp: () {
        when(() => mockAuthService.linkWithGoogle())
            .thenAnswer((_) async => false);
      },
      act: (cubit) => cubit.linkGoogle(mockAppLocalizations),
      expect: () => const [
        ProfileState(status: ProfileStatus.loading),
        ProfileState(status: ProfileStatus.failure, errorMessage: 'Error'),
        ProfileState(errorMessage: 'Error'),
      ],
    );

    blocTest<ProfileCubit, ProfileState>(
      'saveName returns early when name is empty',
      build: () => profileCubit,
      seed: () => const ProfileState(userName: '  '),
      act: (cubit) => cubit.saveName(mockAppLocalizations),
      expect: () => const <ProfileState>[],
      verify: (_) {
        verifyNever(() => mockAuthService.updateDisplayName(any()));
      },
    );

    blocTest<ProfileCubit, ProfileState>(
      'toggleEditingName sets userName from user if editing',
      build: () => profileCubit,
      seed: () {
        final mockUser = MockAppUser();
        when(() => mockUser.displayName).thenReturn('Original Name');
        return ProfileState(user: mockUser);
      },
      act: (cubit) => cubit.toggleEditingName(),
      expect: () => [
        isA<ProfileState>()
            .having((s) => s.isEditingName, 'isEditingName', true)
            .having((s) => s.userName, 'userName', 'Original Name'),
      ],
    );
  });

  group('ProfileStatus', () {
    test('getters work correctly', () {
      expect(ProfileStatus.initial.isInitial, isTrue);
      expect(ProfileStatus.loading.isLoading, isTrue);
      expect(ProfileStatus.success.isSuccess, isTrue);
      expect(ProfileStatus.failure.isFailure, isTrue);

      expect(ProfileStatus.initial.isLoading, isFalse);
    });
  });

  group('ProfileState', () {
    test('supports value comparisons', () {
      expect(const ProfileState(), const ProfileState());
    });

    test('copyWith works correctly', () {
      expect(
        const ProfileState().copyWith(
          status: ProfileStatus.loading,
          userName: 'Name',
          isEditingName: true,
          errorMessage: 'Error',
        ),
        const ProfileState(
          status: ProfileStatus.loading,
          userName: 'Name',
          isEditingName: true,
          errorMessage: 'Error',
        ),
      );

      final mockUser = MockAppUser();
      expect(
        const ProfileState().copyWith(user: mockUser),
        ProfileState(user: mockUser),
      );
    });
  });
}
