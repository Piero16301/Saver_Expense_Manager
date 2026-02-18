import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:saver_expense_manager/app/models/prompt_part.dart';

void main() {
  group('PromptPart', () {
    test('text constructor creates correct instance', () {
      const text = 'Hello world';
      final promptPart = PromptPart.text(text: text);

      expect(promptPart.type, PromptPartType.text);
      expect(promptPart.text, text);
      expect(promptPart.mimeType, isNull);
      expect(promptPart.bytes, isNull);
    });

    test('file constructor creates correct instance', () {
      const mimeType = 'image/png';
      final bytes = Uint8List.fromList([1, 2, 3]);
      final promptPart = PromptPart.file(mimeType: mimeType, bytes: bytes);

      expect(promptPart.type, PromptPartType.file);
      expect(promptPart.mimeType, mimeType);
      expect(promptPart.bytes, bytes);
      expect(promptPart.text, isNull);
    });
  });

  group('PromptPartType', () {
    test('isText returns true for text type', () {
      expect(PromptPartType.text.isText, isTrue);
      expect(PromptPartType.text.isFile, isFalse);
    });

    test('isFile returns true for file type', () {
      expect(PromptPartType.file.isFile, isTrue);
      expect(PromptPartType.file.isText, isFalse);
    });
  });
}
