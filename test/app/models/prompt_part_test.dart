import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/prompt_part.dart';

void main() {
  group('PromptPart', () {
    test('text constructor creates correct instance', () {
      final part = PromptPart.text(text: 'Hello');

      expect(part.type, equals(PromptPartType.text));
      expect(part.text, equals('Hello'));
      expect(part.mimeType, isNull);
      expect(part.bytes, isNull);
    });

    test('file constructor creates correct instance', () {
      final bytes = Uint8List.fromList([1, 2, 3]);
      final part = PromptPart.file(mimeType: 'image/jpeg', bytes: bytes);

      expect(part.type, equals(PromptPartType.file));
      expect(part.mimeType, equals('image/jpeg'));
      expect(part.bytes, equals(bytes));
      expect(part.text, isNull);
    });
  });

  group('PromptPartType', () {
    test('isText returns true only for text', () {
      expect(PromptPartType.text.isText, isTrue);
      expect(PromptPartType.file.isText, isFalse);
    });

    test('isFile returns true only for file', () {
      expect(PromptPartType.file.isFile, isTrue);
      expect(PromptPartType.text.isFile, isFalse);
    });
  });
}
