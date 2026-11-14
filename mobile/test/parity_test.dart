import 'dart:convert';
import 'dart:io';

import 'package:english_practice/practice.dart';
import 'package:flutter_test/flutter_test.dart' hide matches;

void main() {
  final fixture = jsonDecode(
    File('../tests/fixtures/practice-parity.json').readAsStringSync(),
  ) as Map<String, dynamic>;

  test(
    'mobile follows the shared desktop/mobile answer and progress cases',
    () {
      for (final item in fixture['answers'] as List) {
        expect(
          matches(item['answer'] as String, item['accepted'] as List),
          item['correct'],
          reason: item['answer'] as String,
        );
      }
      for (final item in fixture['progress'] as List) {
        if (item['error'] == true) {
          expect(
            () => parseProgress(item['text'] as String?),
            throwsFormatException,
          );
        } else {
          expect(parseProgress(item['text'] as String?), item['expected']);
        }
      }
    },
  );

  test('mobile follows the shared desktop/mobile review schedule', () {
    Map<String, dynamic>? state;
    for (final item in fixture['reviews'] as List) {
      state = review(state, item['correct'] as bool, item['now'] as int);
      expect(state['ease'], closeTo(item['ease'] as num, 1e-10));
      for (final key in ['repetitions', 'interval', 'due']) {
        expect(state[key], item[key]);
      }
    }
  });

  test('mobile bundles exactly the same five exercise banks as desktop', () {
    for (final name in [
      'grammar',
      'reading',
      'writing',
      'vocabulary',
      'translation',
    ]) {
      expect(
        File('assets/data/$name.json').readAsBytesSync(),
        File('../data/$name.json').readAsBytesSync(),
        reason: name,
      );
    }
  });
}
