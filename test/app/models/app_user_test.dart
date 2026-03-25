import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:saver_expense_manager/app/models/models.dart';

class MockFirebaseUser extends Mock implements firebase.User {}

class MockFirebaseUserInfo extends Mock implements firebase.UserInfo {}

void main() {
  group('AppUserInfo', () {
    const uid = 'uid';
    const providerId = 'providerId';
    const email = 'email';
    const displayName = 'displayName';
    const photoURL = 'photoURL';
    const phoneNumber = 'phoneNumber';

    test('supports value equality', () {
      expect(
        const AppUserInfo(
          uid: uid,
          providerId: providerId,
          email: email,
          displayName: displayName,
          photoURL: photoURL,
          phoneNumber: phoneNumber,
        ),
        equals(
          const AppUserInfo(
            uid: uid,
            providerId: providerId,
            email: email,
            displayName: displayName,
            photoURL: photoURL,
            phoneNumber: phoneNumber,
          ),
        ),
      );
    });

    test('props returns correct values', () {
      const userInfo = AppUserInfo(
        uid: uid,
        providerId: providerId,
        email: email,
        displayName: displayName,
        photoURL: photoURL,
        phoneNumber: phoneNumber,
      );

      expect(
        userInfo.props,
        containsAll([
          uid,
          providerId,
          email,
          displayName,
          photoURL,
          phoneNumber,
        ]),
      );
    });

    test('fromFirebaseUserInfo creates correct instance', () {
      final mockInfo = MockFirebaseUserInfo();
      when(() => mockInfo.uid).thenReturn(uid);
      when(() => mockInfo.providerId).thenReturn(providerId);
      when(() => mockInfo.email).thenReturn(email);
      when(() => mockInfo.displayName).thenReturn(displayName);
      when(() => mockInfo.photoURL).thenReturn(photoURL);
      when(() => mockInfo.phoneNumber).thenReturn(phoneNumber);

      final userInfo = AppUserInfo.fromFirebaseUserInfo(mockInfo);

      expect(userInfo.uid, equals(uid));
      expect(userInfo.providerId, equals(providerId));
      expect(userInfo.email, equals(email));
      expect(userInfo.displayName, equals(displayName));
      expect(userInfo.photoURL, equals(photoURL));
      expect(userInfo.phoneNumber, equals(phoneNumber));
    });

    test('fromFirebaseUserInfo handles null values', () {
      final mockInfo = MockFirebaseUserInfo();
      when(() => mockInfo.uid).thenReturn(null);
      when(() => mockInfo.providerId).thenReturn('');
      when(() => mockInfo.email).thenReturn(null);
      when(() => mockInfo.displayName).thenReturn(null);
      when(() => mockInfo.photoURL).thenReturn(null);
      when(() => mockInfo.phoneNumber).thenReturn(null);

      final userInfo = AppUserInfo.fromFirebaseUserInfo(mockInfo);

      expect(userInfo.uid, equals(''));
      expect(userInfo.providerId, equals(''));
    });
  });

  group('AppUser', () {
    const uid = 'uid';
    const email = 'email';
    const displayName = 'displayName';
    const photoURL = 'photoURL';
    const phoneNumber = 'phoneNumber';

    test('supports value equality', () {
      expect(
        const AppUser(
          uid: uid,
          email: email,
          displayName: displayName,
          photoURL: photoURL,
          phoneNumber: phoneNumber,
        ),
        equals(
          const AppUser(
            uid: uid,
            email: email,
            displayName: displayName,
            photoURL: photoURL,
            phoneNumber: phoneNumber,
          ),
        ),
      );
    });

    test('isEmpty returns true for empty user', () {
      expect(AppUser.empty.isEmpty, isTrue);
      expect(AppUser.empty.isNotEmpty, isFalse);
    });

    test('isNotEmpty returns true for non-empty user', () {
      const user = AppUser(uid: uid);
      expect(user.isNotEmpty, isTrue);
      expect(user.isEmpty, isFalse);
    });

    test('fromFirebaseUser creates correct instance', () {
      final mockUser = MockFirebaseUser();
      final mockInfo = MockFirebaseUserInfo();

      when(() => mockInfo.uid).thenReturn(uid);
      when(() => mockInfo.providerId).thenReturn('providerId');
      when(() => mockInfo.email).thenReturn(email);
      when(() => mockInfo.displayName).thenReturn(displayName);
      when(() => mockInfo.photoURL).thenReturn(photoURL);
      when(() => mockInfo.phoneNumber).thenReturn(phoneNumber);

      when(() => mockUser.uid).thenReturn(uid);
      when(() => mockUser.email).thenReturn(email);
      when(() => mockUser.displayName).thenReturn(displayName);
      when(() => mockUser.photoURL).thenReturn(photoURL);
      when(() => mockUser.phoneNumber).thenReturn(phoneNumber);
      when(() => mockUser.providerData).thenReturn([mockInfo]);

      final user = AppUser.fromFirebaseUser(mockUser);

      expect(user.uid, equals(uid));
      expect(user.email, equals(email));
      expect(user.displayName, equals(displayName));
      expect(user.photoURL, equals(photoURL));
      expect(user.phoneNumber, equals(phoneNumber));
      expect(user.providerData.length, equals(1));
      expect(user.providerData.first.uid, equals(uid));
    });
  });
}
