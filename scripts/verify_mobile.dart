// A socket-free check of the pure Dart logic: dart scripts/verify_mobile.dart.
import '../mobile/lib/practice.dart';

void expect(bool condition, String message) {
  if (!condition) throw StateError(message);
}

void main() {
  expect(
    matches('  WOULD   HAVE BEEN. ', ['would have been']),
    'Answer normalization',
  );
  expect(matches('Hadn’t', ["hadn't"]), 'Smart apostrophes');
  expect(!matches('si', ['sí']), 'Accent distinction');
  expect(!matches('would be', ['would have been']), 'Incorrect tense');
  final first = review(null, true, 0);
  final second = review(first, true, 0);
  final third = review(second, true, 0);
  expect(
    first['interval'] == 1 && second['interval'] == 3 && third['interval'] > 3,
    'Expanding review intervals',
  );
  final failed = review(third, false, 0);
  expect(
    failed['repetitions'] == 0 && failed['due'] == 60000,
    'Failed recall resets',
  );
  final cards = [
    {'id': 'a'},
    {'id': 'b'},
    {'id': 'c'},
  ];
  final progress = {
    'a': {'due': 300},
    'b': {'due': 100},
  };
  expect(nextCard(cards, progress, 400)?['id'] == 'b', 'Oldest due card first');
  expect(
    nextCard(cards, progress, 0)?['id'] == 'c',
    'Unseen card before future reviews',
  );
  expect(
    nextCard(cards.sublist(0, 2), progress, 0) == null,
    'Wait for scheduled review',
  );
  expect(
    pick(cards.sublist(0, 2), 'a')['id'] == 'b',
    'Avoid immediate exercise repetition',
  );
  print('10 pure Dart checks passed.');
}
