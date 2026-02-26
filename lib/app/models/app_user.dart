import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase;

class AppUserInfo extends Equatable {
  const AppUserInfo({
    required this.uid,
    this.providerId,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
  });

  factory AppUserInfo.fromFirebaseUserInfo(firebase.UserInfo info) {
    return AppUserInfo(
      uid: info.uid ?? '',
      providerId: info.providerId,
      email: info.email,
      displayName: info.displayName,
      photoURL: info.photoURL,
      phoneNumber: info.phoneNumber,
    );
  }

  final String uid;
  final String? providerId;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;

  @override
  List<Object?> get props => [
        uid,
        providerId,
        email,
        displayName,
        photoURL,
        phoneNumber,
      ];
}

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoURL,
    this.phoneNumber,
    this.providerData = const [],
  });

  factory AppUser.fromFirebaseUser(firebase.User user) {
    return AppUser(
      uid: user.uid,
      email: user.email,
      displayName: user.displayName,
      photoURL: user.photoURL,
      phoneNumber: user.phoneNumber,
      providerData:
          user.providerData.map(AppUserInfo.fromFirebaseUserInfo).toList(),
    );
  }

  static const empty = AppUser(uid: '');

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoURL;
  final String? phoneNumber;
  final List<AppUserInfo> providerData;

  bool get isEmpty => this == AppUser.empty;
  bool get isNotEmpty => this != AppUser.empty;

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoURL,
        phoneNumber,
        providerData,
      ];
}
