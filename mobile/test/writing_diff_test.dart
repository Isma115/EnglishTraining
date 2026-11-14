import 'dart:convert';
import 'dart:io';

import 'package:english_practice/practice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('writing comparison preserves both texts and highlights the same corrections', () {
    final cases = jsonDecode(
      File('../tests/fixtures/writing-diff.json').readAsStringSync(),
    ) as List;
    for (final item in cases) {
      final changes = writingDiff(
        item['original'] as String,
        item['corrected'] as String,
      );
      expect(
        changes
            .where((part) => part.kind != 'added')
            .map((part) => part.text)
            .join(),
        item['original'],
      );
      expect(
        changes
            .where((part) => part.kind != 'removed')
            .map((part) => part.text)
            .join(),
        item['corrected'],
      );
      expect(changes.every((part) => part.text.isNotEmpty), isTrue);
      if (item['expected'] != null) {
        expect(
          changes
              .map((part) => {'kind': part.kind, 'text': part.text})
              .toList(),
          item['expected'],
        );
      }
      if (item['original'] == item['corrected']) {
        expect(changes.every((part) => part.kind == 'equal'), isTrue);
      }
    }
  });
}
