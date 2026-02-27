import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/firebase_options.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    tearDown(() {
      debugDefaultTargetPlatformOverride = null;
    });

    test('currentPlatform returns android on Android', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;
      expect(
        DefaultFirebaseOptions.currentPlatform,
        DefaultFirebaseOptions.android,
      );
    });

    test('currentPlatform returns ios on iOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
      expect(
        DefaultFirebaseOptions.currentPlatform,
        DefaultFirebaseOptions.ios,
      );
    });

    test('currentPlatform throws UnsupportedError on macOS', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsUnsupportedError,
      );
    });

    test('currentPlatform throws UnsupportedError on windows', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.windows;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsUnsupportedError,
      );
    });

    test('currentPlatform throws UnsupportedError on linux', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.linux;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsUnsupportedError,
      );
    });

    test('currentPlatform throws UnsupportedError on fuchsia', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;
      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsUnsupportedError,
      );
    });

    test('constants are accessible', () {
      expect(DefaultFirebaseOptions.android.apiKey, isNotEmpty);
      expect(DefaultFirebaseOptions.ios.apiKey, isNotEmpty);
      expect(DefaultFirebaseOptions.googleClientId, isNotEmpty);
      expect(DefaultFirebaseOptions.googleRedirectUri, isNotEmpty);
    });
  });
}
