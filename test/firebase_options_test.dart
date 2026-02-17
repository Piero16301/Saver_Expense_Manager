import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    test('currentPlatform returns android options on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      try {
        final options = DefaultFirebaseOptions.currentPlatform;
        expect(options, DefaultFirebaseOptions.android);
        expect(options.apiKey, 'AIzaSyCr0Q9aOOiIOra_Jkown14_Omv8v0rlWpo');
        expect(options.appId, '1:269318126118:android:19c0edc290b70b9dfb04e7');
        expect(options.messagingSenderId, '269318126118');
        expect(options.projectId, 'saver-expense-manager');
        expect(
          options.storageBucket,
          'saver-expense-manager.firebasestorage.app',
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('currentPlatform returns ios options on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      try {
        final options = DefaultFirebaseOptions.currentPlatform;
        expect(options, DefaultFirebaseOptions.ios);
        expect(options.apiKey, 'AIzaSyCliGUV5JtQkDDsIqFK_SXW9HzUzI8S63Y');
        expect(options.appId, '1:269318126118:ios:ccccf972db5c7042fb04e7');
        expect(options.messagingSenderId, '269318126118');
        expect(options.projectId, 'saver-expense-manager');
        expect(
          options.storageBucket,
          'saver-expense-manager.firebasestorage.app',
        );
        expect(
          options.androidClientId,
          '269318126118-59i8g260ddou15dolopo2thrjc0tj6r2.apps.'
          'googleusercontent.com',
        );
        expect(
          options.iosClientId,
          '269318126118-7t1rqm8oho4m39a01tlvavd8735559dn.apps.'
          'googleusercontent.com',
        );
        expect(options.iosBundleId, 'com.pmorales.saver.expense.manager');
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('currentPlatform throws UnsupportedError on macOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      try {
        expect(
          () => DefaultFirebaseOptions.currentPlatform,
          throwsUnsupportedError,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('currentPlatform throws UnsupportedError on Windows', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      try {
        expect(
          () => DefaultFirebaseOptions.currentPlatform,
          throwsUnsupportedError,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('currentPlatform throws UnsupportedError on Linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      try {
        expect(
          () => DefaultFirebaseOptions.currentPlatform,
          throwsUnsupportedError,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('currentPlatform throws UnsupportedError on Fuchsia', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      try {
        expect(
          () => DefaultFirebaseOptions.currentPlatform,
          throwsUnsupportedError,
        );
      } finally {
        debugDefaultTargetPlatformOverride = null;
      }
    });

    test('Additional constants are correct', () {
      expect(
        DefaultFirebaseOptions.googleClientId,
        '269318126118-54eh6vkdnfggcl9jv43ds7pcd927gd34.apps.'
        'googleusercontent.com',
      );
      expect(
        DefaultFirebaseOptions.googleRedirectUri,
        'https://saver-expense-manager.firebaseapp.com/__/auth/handler',
      );
    });
  });
}
