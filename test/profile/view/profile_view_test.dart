import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';
import 'package:saver_expense_manager/profile/profile.dart';

class MockProfileCubit extends MockCubit<ProfileState>
    implements ProfileCubit {}

class FakeAppLocalizations extends Fake implements AppLocalizations {}

const _userNoProviders = AppUser(
  uid: 'uid-1',
  displayName: 'Test User',
);

const _userBothProviders = AppUser(
  uid: 'uid-2',
  displayName: 'Test User',
  providerData: [
    AppUserInfo(
      uid: 'uid-2',
      providerId: 'google.com',
      email: 'user@gmail.com',
    ),
    AppUserInfo(
      uid: 'uid-2',
      providerId: 'password',
      email: 'user@email.com',
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('ProfileView', () {
    late MockProfileCubit profileCubit;

    setUpAll(() {
      registerFallbackValue(const ProfileState());
      registerFallbackValue(FakeAppLocalizations());
    });

    setUp(() {
      profileCubit = MockProfileCubit();
      when(() => profileCubit.stream).thenAnswer((_) => const Stream.empty());
      when(() => profileCubit.close()).thenAnswer((_) async {});
    });

    Future<void> pumpProfileView(
      WidgetTester tester, {
      required ProfileState state,
    }) async {
      when(() => profileCubit.state).thenReturn(state);

      final router = GoRouter(
        initialLocation: '/profile',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const Scaffold(body: Text('Home')),
            routes: [
              GoRoute(
                path: 'profile',
                builder: (routeContext, routeState) =>
                    BlocProvider<ProfileCubit>(
                  create: (_) => profileCubit,
                  child: const ProfileView(),
                ),
              ),
            ],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp.router(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          routerConfig: router,
        ),
      );
      await tester.pump();

      if (state.user != null) {
        await tester.pumpAndSettle();
      }
    }

    testWidgets('shows CircularProgressIndicator when user is null',
        (tester) async {
      await pumpProfileView(tester, state: const ProfileState());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows user display name when loaded', (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
        ),
      );
      expect(find.text('Test User'), findsOneWidget);
    });

    testWidgets('shows HugeIcon user placeholder when photoURL is null',
        (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
        ),
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedUser,
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows Connect buttons when no providers are linked',
        (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
        ),
      );

      expect(find.text('Connect'), findsNWidgets(2));
    });

    testWidgets('shows unlink buttons when providers are linked',
        (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userBothProviders,
        ),
      );

      expect(find.text('user@gmail.com'), findsOneWidget);
      expect(find.text('user@email.com'), findsOneWidget);

      expect(
        find.byWidgetPredicate(
          (w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedDelete01,
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('shows AppTextField when editing name', (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
          isEditingName: true,
          userName: 'Test User',
        ),
      );

      expect(find.byType(AppTextField), findsOneWidget);

      expect(
        find.byWidgetPredicate(
          (w) =>
              w is HugeIcon &&
              w.icon == HugeIcons.strokeRoundedCheckmarkCircle01,
        ),
        findsOneWidget,
      );
      expect(
        find.byWidgetPredicate(
          (w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedCancelCircle,
        ),
        findsOneWidget,
      );
    });

    testWidgets('calls nameChanged when text field changes', (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
          isEditingName: true,
          userName: 'Test User',
        ),
      );

      await tester.enterText(find.byType(AppTextField), 'New Name');
      verify(() => profileCubit.nameChanged('New Name')).called(1);
    });

    testWidgets('calls toggleEditingName when edit icon is tapped',
        (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
        ),
      );

      final editButton = find.byWidgetPredicate(
        (w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedEdit01,
      );
      await tester.tap(editButton);
      verify(() => profileCubit.toggleEditingName()).called(1);
    });

    testWidgets('calls toggleEditingName when cancel icon is tapped',
        (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
          isEditingName: true,
          userName: 'Test User',
        ),
      );

      final cancelButton = find.byWidgetPredicate(
        (w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedCancelCircle,
      );
      await tester.tap(cancelButton);
      verify(() => profileCubit.toggleEditingName()).called(1);
    });

    testWidgets('calls saveName when checkmark icon is tapped', (tester) async {
      when(() => profileCubit.saveName(any())).thenAnswer((_) async {});

      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
          isEditingName: true,
          userName: 'Test User',
        ),
      );

      final saveButton = find.byWidgetPredicate(
        (w) =>
            w is HugeIcon && w.icon == HugeIcons.strokeRoundedCheckmarkCircle01,
      );
      await tester.tap(saveButton);
      verify(() => profileCubit.saveName(any())).called(1);
    });

    testWidgets('shows logout dialog when logout button is tapped',
        (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
        ),
      );

      await tester.tap(find.byType(AppFilledButton));
      await tester.pumpAndSettle();

      expect(find.byType(AppAlertDialog), findsOneWidget);
    });

    testWidgets('calls logout when dialog is confirmed', (tester) async {
      when(() => profileCubit.logout(any())).thenAnswer((_) async {});

      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
        ),
      );

      await tester.tap(find.byType(AppFilledButton));
      await tester.pumpAndSettle();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(AppAlertDialog)));
      await tester.tap(find.text(l10n.logoutConfirm).last);
      await tester.pumpAndSettle();

      verify(() => profileCubit.logout(any())).called(1);
    });

    testWidgets('dismisses logout dialog when cancel is tapped',
        (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
        ),
      );

      await tester.tap(find.byType(AppFilledButton));
      await tester.pumpAndSettle();
      expect(find.byType(AppAlertDialog), findsOneWidget);

      final l10n =
          AppLocalizations.of(tester.element(find.byType(AppAlertDialog)));
      await tester.tap(find.text(l10n.logoutCancel));
      await tester.pumpAndSettle();

      expect(find.byType(AppAlertDialog), findsNothing);
      verifyNever(() => profileCubit.logout(any()));
    });

    testWidgets('shows error snackbar on failure status', (tester) async {
      whenListen(
        profileCubit,
        Stream.fromIterable([
          const ProfileState(
            status: ProfileStatus.failure,
            errorMessage: 'Something went wrong',
            user: _userNoProviders,
          ),
        ]),
        initialState: const ProfileState(user: _userNoProviders),
      );

      await pumpProfileView(
        tester,
        state: const ProfileState(user: _userNoProviders),
      );

      await tester.pumpAndSettle();
      expect(find.text('Something went wrong'), findsOneWidget);
    });

    testWidgets('calls linkGoogle when Google connect button is tapped',
        (tester) async {
      when(() => profileCubit.linkGoogle(any())).thenAnswer((_) async {});

      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
        ),
      );

      await tester.tap(find.text('Connect').first);
      verify(() => profileCubit.linkGoogle(any())).called(1);
    });

    testWidgets(
        'shows unlink dialog for Google when delete icon is tapped with 2 '
        'providers', (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userBothProviders,
        ),
      );

      final deleteButtons = find.byWidgetPredicate(
        (w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedDelete01,
      );
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(find.byType(AppAlertDialog), findsOneWidget);
    });

    testWidgets(
        'shows snackbar instead of dialog when only one provider is linked',
        (tester) async {
      const userWithOneProvider = AppUser(
        uid: 'uid-single',
        displayName: 'Single Provider User',
        providerData: [
          AppUserInfo(
            uid: 'uid-single',
            providerId: 'google.com',
            email: 'single@gmail.com',
          ),
        ],
      );

      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: userWithOneProvider,
        ),
      );

      final deleteButton = find.byWidgetPredicate(
        (w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedDelete01,
      );
      await tester.tap(deleteButton.first);
      await tester.pumpAndSettle();

      expect(find.byType(AppAlertDialog), findsNothing);
    });

    testWidgets('calls unlinkProvider when unlink dialog is confirmed',
        (tester) async {
      when(() => profileCubit.unlinkProvider(any(), any()))
          .thenAnswer((_) async {});

      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userBothProviders,
        ),
      );

      final deleteButtons = find.byWidgetPredicate(
        (w) => w is HugeIcon && w.icon == HugeIcons.strokeRoundedDelete01,
      );
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      final l10n =
          AppLocalizations.of(tester.element(find.byType(AppAlertDialog)));
      await tester.tap(find.text(l10n.unlinkProviderConfirm));
      await tester.pumpAndSettle();

      verify(() => profileCubit.unlinkProvider(any(), any())).called(1);
    });

    testWidgets(
        'shows link email dialog when Email provider Connect button is tapped',
        (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(
          status: ProfileStatus.success,
          user: _userNoProviders,
        ),
      );

      await tester.tap(find.text('Connect').last);
      await tester.pumpAndSettle();

      expect(find.byType(AppAlertDialog), findsOneWidget);
      expect(find.byType(AppTextField), findsWidgets);
    });

    testWidgets('navigates back when back button is tapped', (tester) async {
      await pumpProfileView(
        tester,
        state: const ProfileState(),
      );

      final backButton = find.byType(IconButton).first;
      await tester.tap(backButton);
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });
  });
}
