import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/app.dart';

void main() {
  group('SharedFile', () {
    test('creates from map with expense type', () {
      final file = SharedFile.fromMap(const {
        'path': '/tmp/shared_files/receipt.pdf',
        'name': 'receipt.pdf',
        'movementType': 'EXPENSE',
      });

      expect(file.path, '/tmp/shared_files/receipt.pdf');
      expect(file.name, 'receipt.pdf');
      expect(file.movementType, CategoryType.expense);
      expect(file.extension, 'pdf');
      expect(file.isSupported, isTrue);
    });

    test('creates from map with income type and uppercase extension', () {
      final file = SharedFile.fromMap(const {
        'path': '/tmp/shared_files/voucher.JPEG',
        'name': 'voucher.JPEG',
        'movementType': 'INCOME',
      });

      expect(file.movementType, CategoryType.income);
      expect(file.extension, 'jpeg');
      expect(file.isSupported, isTrue);
    });

    test('falls back to path when name is empty', () {
      const file = SharedFile(
        path: '/tmp/shared_files/photo.png',
        name: '',
        movementType: CategoryType.expense,
      );

      expect(file.extension, 'png');
      expect(file.isSupported, isTrue);
    });

    test(
      'returns isSupported false for unsupported extension or empty file',
      () {
        const unsupportedExt = SharedFile(
          path: '/tmp/shared_files/notes.txt',
          name: 'notes.txt',
          movementType: CategoryType.expense,
        );
        const noExtension = SharedFile(
          path: '/tmp/shared_files/receipt',
          name: 'receipt',
          movementType: CategoryType.expense,
        );
        const emptySource = SharedFile(
          path: '',
          name: 'receipt.pdf',
          movementType: CategoryType.expense,
        );

        expect(unsupportedExt.isSupported, isFalse);
        expect(noExtension.extension, isEmpty);
        expect(noExtension.isSupported, isFalse);
        expect(emptySource.isSupported, isFalse);
      },
    );

    test('supports bytes-backed shared file and value equality', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final fileA = SharedFile(
        path: '',
        name: 'receipt.jpg',
        movementType: CategoryType.income,
        bytes: bytes,
      );
      final fileB = SharedFile(
        path: '',
        name: 'receipt.jpg',
        movementType: CategoryType.income,
        bytes: bytes,
      );

      expect(fileA.isSupported, isTrue);
      expect(fileA, equals(fileB));
    });
  });
}
