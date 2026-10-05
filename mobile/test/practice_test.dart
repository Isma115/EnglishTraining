import 'package:flutter_test/flutter_test.dart' hide matches;
import 'package:english_practice/practice.dart';

void main() {
  test('answers tolerate spacing and apostrophes while retaining accents', () {
    expect(matches('  WOULD  HAVE BEEN. ', ['would have been']), isTrue);
    expect(matches('Hadn’t', ["hadn't"]), isTrue);
    expect(matches('si', ['sí']), isFalse);
  });
  test(
    'review expands successful intervals and resets after failed recall',
    () {
      final first = review(null, true, 0);
      final second = review(first, true, 0);
      final third = review(second, true, 0);
      expect(first['interval'], 1);
      expect(second['interval'], 3);
      expect(third['interval'], greaterThan(3));
      final failed = review(third, false, 0);
      expect(failed['repetitions'], 0);
      expect(failed['due'], 60000);
    },
  );
  test('due cards come first and future cards wait until their due time', () {
    final cards = [
      {'id': 'a'},
      {'id': 'b'},
      {'id': 'c'},
    ];
    final progress = {
      'a': {'due': 300},
      'b': {'due': 100},
    };
    expect(nextCard(cards, progress, 400)?['id'], 'b');
    expect(nextCard(cards, progress, 0)?['id'], 'c');
    expect(nextCard(cards.sublist(0, 2), progress, 0), isNull);
  });
}
