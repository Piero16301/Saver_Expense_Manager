import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
// ignore: depend_on_referenced_packages // For mock platform interface
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:saver_expense_manager/app/app.dart';
import 'package:saver_expense_manager/l10n/l10n.dart';

class MockRemoteStorageService extends Mock implements RemoteStorageService {}

class MockFilePicker extends Mock
    with MockPlatformInterfaceMixin
    implements FilePicker {}

void main() {
  late RemoteStorageService remoteStorageService;
  late MockFilePicker mockFilePicker;

  setUpAll(() {
    registerFallbackValue(File(''));
    registerFallbackValue(FileType.any);
  });

  setUp(() async {
    remoteStorageService = MockRemoteStorageService();
    mockFilePicker = MockFilePicker();
    FilePicker.platform = mockFilePicker;

    final getIt = GetIt.instance;
    if (getIt.isRegistered<RemoteStorageService>()) {
      await getIt.unregister<RemoteStorageService>();
    }
    getIt.registerLazySingleton<RemoteStorageService>(
      () => remoteStorageService,
    );
  });

  group('AppFileField', () {
    testWidgets('renders labels and attachments with different types',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppFileField(
              label: 'Attachments',
              labelAdd: 'Add File',
              onAdd: (_) {},
              onRemove: (_) async {},
              openFile: (_) async {},
              attachments: const [
                'file1.pdf',
                'image1.png',
                'image2.jpg',
                'image3.jpeg',
                'other.txt',
              ],
            ),
          ),
        ),
      );

      expect(find.text('Attachments'), findsOneWidget);
      expect(find.text('Add File'), findsOneWidget);
      expect(find.byType(Chip), findsNWidgets(5));

      expect(find.text('Document'), findsOneWidget);
      expect(find.text('Image'), findsNWidgets(3));
      expect(find.text('File'), findsOneWidget);
    });

    testWidgets('triggers openFile on tap', (tester) async {
      String? opened;
      final completer = Completer<void>();
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppFileField(
              label: 'Docs',
              labelAdd: 'Add',
              onAdd: (_) {},
              onRemove: (_) async {},
              openFile: (path) async {
                opened = path;
                await completer.future;
              },
              attachments: const ['doc.pdf'],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Document'));
      await tester.pump();

      expect(opened, 'doc.pdf');

      completer.complete();
      await tester.pumpAndSettle();
    });

    testWidgets('shows confirmation dialog on remove and calls onRemove',
        (tester) async {
      String? removed;
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppFileField(
              label: 'Docs',
              labelAdd: 'Add',
              onAdd: (_) {},
              onRemove: (path) async => removed = path,
              openFile: (_) async {},
              attachments: const ['doc.pdf'],
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();

      expect(find.byType(AppAlertDialog), findsOneWidget);

      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      expect(removed, isNull);

      await tester.tap(find.byIcon(Icons.cancel));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      expect(removed, 'doc.pdf');
    });

    testWidgets('handles file upload successfully', (tester) async {
      String? added;
      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenAnswer(
        (_) async => FilePickerResult([
          PlatformFile(
            name: 'test.png',
            size: 100,
            path: 'path/to/test.png',
          ),
        ]),
      );

      when(() => remoteStorageService.uploadFile(any(), any()))
          .thenAnswer((_) async => 'uploaded_path.png');

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppFileField(
              label: 'Docs',
              labelAdd: 'Upload',
              onAdd: (path) => added = path,
              onRemove: (_) async {},
              openFile: (_) async {},
              attachments: const [],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Upload'));
      await tester.pump();
      await tester.pumpAndSettle();

      expect(added, 'uploaded_path.png');
    });

    testWidgets('handles upload error and shows SnackBar', (tester) async {
      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenThrow(Exception('Upload failed'));

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppFileField(
              label: 'Docs',
              labelAdd: 'Upload',
              onAdd: (_) {},
              onRemove: (_) async {},
              openFile: (_) async {},
              attachments: const [],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();

      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Exception: Upload failed'), findsOneWidget);
    });

    testWidgets('does nothing if file picking is cancelled', (tester) async {
      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
        ),
      ).thenAnswer((_) async => null);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: AppFileField(
              label: 'Docs',
              labelAdd: 'Upload',
              onAdd: (_) {
                fail('onAdd should not be called');
              },
              onRemove: (_) async {},
              openFile: (_) async {},
              attachments: const [],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Upload'));
      await tester.pumpAndSettle();
    });
  });
}
