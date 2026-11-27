import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('MockShareIntentRepository', () {
    test('is a safe no-op implementation by default', () async {
      final repo = MockShareIntentRepository();
      await repo.initialize();
      expect(repo.consumePendingSharedFile(), isNull);
      expect(repo.sharedFileStream, emitsDone);
      await repo.dispose();
    });

    test('supports simulating shared files for mock mode testing', () async {
      final repo = MockShareIntentRepository();
      await repo.initialize();

      const pendingFile = SharedFile(
        path: '/tmp/receipt.pdf',
        name: 'receipt.pdf',
        movementType: CategoryType.expense,
      );
      repo.simulateSharedFile(pendingFile);
      expect(repo.consumePendingSharedFile(), equals(pendingFile));
      expect(repo.consumePendingSharedFile(), isNull);

      final received = <SharedFile>[];
      final sub = repo.sharedFileStream.listen(received.add);
      const streamedFile = SharedFile(
        path: '/tmp/voucher.png',
        name: 'voucher.png',
        movementType: CategoryType.income,
      );
      repo.simulateSharedFile(streamedFile);
      await Future<void>.delayed(Duration.zero);

      expect(received, equals([streamedFile]));
      await sub.cancel();
      await repo.dispose();
    });
  });

  group('MethodChannelShareIntentRepository', () {
    const channel = MethodChannel('test.share.channel');
    late MethodChannelShareIntentRepository repository;

    setUp(() {
      repository = MethodChannelShareIntentRepository(channel: channel);
    });

    tearDown(() async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
      await repository.dispose();
    });

    test('buffers initial supported shared file and consumes once', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getInitialSharedFile') {
              return {
                'path': '/tmp/shared_files/doc.pdf',
                'name': 'doc.pdf',
                'movementType': 'EXPENSE',
              };
            }
            return null;
          });

      await repository.initialize();

      final pending = repository.consumePendingSharedFile();
      expect(
        pending,
        equals(
          const SharedFile(
            path: '/tmp/shared_files/doc.pdf',
            name: 'doc.pdf',
            movementType: CategoryType.expense,
          ),
        ),
      );
      expect(repository.consumePendingSharedFile(), isNull);
    });

    test('ignores initial unsupported shared file', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'getInitialSharedFile') {
              return {
                'path': '/tmp/shared_files/doc.txt',
                'name': 'doc.txt',
                'movementType': 'EXPENSE',
              };
            }
            return null;
          });

      await repository.initialize();

      expect(repository.consumePendingSharedFile(), isNull);
    });

    test(
      'handles MissingPluginException and PlatformException gracefully',
      () async {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, (call) async {
              throw PlatformException(code: 'ERR');
            });

        await expectLater(repository.initialize(), completes);
        expect(repository.consumePendingSharedFile(), isNull);
      },
    );

    test('emits onSharedFile directly when listener is active', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      await repository.initialize();

      final received = <SharedFile>[];
      final sub = repository.sharedFileStream.listen(received.add);

      const codec = StandardMethodCodec();
      final encoded = codec.encodeMethodCall(
        const MethodCall('onSharedFile', {
          'path': '/tmp/shared_files/voucher.png',
          'name': 'voucher.png',
          'movementType': 'INCOME',
        }),
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(channel.name, encoded, (_) {});

      await Future<void>.delayed(Duration.zero);

      expect(received, hasLength(1));
      expect(received.first.movementType, CategoryType.income);
      expect(received.first.name, 'voucher.png');
      expect(repository.consumePendingSharedFile(), isNull);

      await sub.cancel();
    });

    test('buffers onSharedFile when no listener is active', () async {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async => null);

      await repository.initialize();

      const codec = StandardMethodCodec();
      final encoded = codec.encodeMethodCall(
        const MethodCall('onSharedFile', {
          'path': '/tmp/shared_files/voucher.jpg',
          'name': 'voucher.jpg',
          'movementType': 'EXPENSE',
        }),
      );
      await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .handlePlatformMessage(channel.name, encoded, (_) {});

      final pending = repository.consumePendingSharedFile();
      expect(pending?.name, 'voucher.jpg');
      expect(pending?.movementType, CategoryType.expense);
    });
  });
}
