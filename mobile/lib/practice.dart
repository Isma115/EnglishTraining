import 'dart:convert';
import 'dart:math';

import 'package:unorm_dart/unorm_dart.dart' as unicode;

String normalize(String text) => unicode
    .nfkc(text)
    .toLowerCase()
    .replaceAll(RegExp('[’‘]'), "'")
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim()
    .replaceAll(RegExp(r'[.!?]+$'), '');

bool matches(String answer, List<dynamic> accepted) =>
    accepted.any((value) => normalize(value as String) == normalize(answer));

Map<String, dynamic> parseProgress(String? text) {
  final decoded = jsonDecode(text ?? '{}');
  if (decoded is! Map<String, dynamic>) {
    throw const FormatException('Invalid vocabulary progress');
  }
  decoded.removeWhere(
    (key, value) =>
        value is! Map ||
        ['due', 'ease', 'interval', 'repetitions'].any(
          (field) => value[field] is! num || !(value[field] as num).isFinite,
        ) ||
        (value['repetitions'] as num) % 1 != 0,
  );
  for (final value in decoded.values) {
    value['repetitions'] = (value['repetitions'] as num).toInt();
  }
  return decoded;
}

Map<String, dynamic> pick(List<dynamic> items, [String? previous]) {
  final pool = items.length > 1
      ? items.where((item) => item['id'] != previous).toList()
      : items;
  return Map<String, dynamic>.from(pool[Random().nextInt(pool.length)] as Map);
}

Map<String, dynamic> review(
  Map<String, dynamic>? previous,
  bool correct, [
  int? time,
]) {
  final now = time ?? DateTime.now().millisecondsSinceEpoch;
  final state = previous ?? {'repetitions': 0, 'interval': 0, 'ease': 2.5};
  final ease = max(1.3, (state['ease'] as num) + (correct ? 0.1 : -0.2));
  final repetitions = state['repetitions'] as int;
  final interval = !correct
      ? 0
      : repetitions == 0
      ? 1
      : repetitions == 1
      ? 3
      : ((state['interval'] as num) * ease).round();
  return {
    'repetitions': correct ? repetitions + 1 : 0,
    'interval': interval,
    'ease': ease,
    'due': now + (correct ? interval * 86400000 : 60000),
  };
}

Map<String, dynamic>? nextCard(
  List<dynamic> cards,
  Map<String, dynamic> progress, [
  int? time,
]) {
  final now = time ?? DateTime.now().millisecondsSinceEpoch;
  final due = cards
      .where(
        (card) =>
            progress[card['id']] != null &&
            (progress[card['id']]['due'] as num) <= now,
      )
      .toList();
  due.sort(
    (a, b) => (progress[a['id']]['due'] as num).compareTo(
      progress[b['id']]['due'] as num,
    ),
  );
  if (due.isNotEmpty) return Map<String, dynamic>.from(due.first as Map);
  final fresh = cards.where((card) => progress[card['id']] == null).toList();
  return fresh.isEmpty ? null : pick(fresh);
}

typedef WritingChange = ({String kind, String text});

List<WritingChange> writingDiff(String original, String corrected) {
  final pattern = RegExp(
    r'''\s+|[^\s.,!?;:()[\]{}"'“”‘’—–-]+|[^\s]''',
    unicode: true,
  );
  List<String> tokens(String text) =>
      pattern.allMatches(text).map((m) => m.group(0)!).toList();
  final changes = <WritingChange>[];
  void emit(String kind, List<String> parts) {
    final text = parts.join();
    if (text.isEmpty) return;
    if (changes.isNotEmpty && changes.last.kind == kind) {
      changes[changes.length - 1] = (
        kind: kind,
        text: changes.last.text + text,
      );
    } else {
      changes.add((kind: kind, text: text));
    }
  }

  // Hirschberg's LCS keeps memory linear in the text length.
  List<int> lengths(List<String> a, List<String> b) {
    var row = List<int>.filled(b.length + 1, 0);
    for (final token in a) {
      final next = List<int>.filled(b.length + 1, 0);
      for (var j = 0; j < b.length; j++) {
        next[j + 1] = token == b[j] ? row[j] + 1 : max(row[j + 1], next[j]);
      }
      row = next;
    }
    return row;
  }

  void compare(List<String> a, List<String> b) {
    var prefix = 0, suffix = 0;
    while (prefix < a.length && prefix < b.length && a[prefix] == b[prefix]) {
      prefix++;
    }
    emit('equal', a.sublist(0, prefix));
    a = a.sublist(prefix);
    b = b.sublist(prefix);
    while (suffix < a.length &&
        suffix < b.length &&
        a[a.length - 1 - suffix] == b[b.length - 1 - suffix]) {
      suffix++;
    }
    final tail = a.sublist(a.length - suffix);
    a = a.sublist(0, a.length - suffix);
    b = b.sublist(0, b.length - suffix);
    final words = a.toSet();
    if (a.isEmpty || b.isEmpty || !b.any(words.contains)) {
      emit('removed', a);
      emit('added', b);
    } else if (a.length == 1) {
      final index = b.indexOf(a[0]);
      emit('added', b.sublist(0, index));
      emit('equal', a);
      emit('added', b.sublist(index + 1));
    } else {
      final middle = a.length ~/ 2;
      final left = lengths(a.sublist(0, middle), b);
      final right = lengths(
        a.sublist(middle).reversed.toList(),
        b.reversed.toList(),
      );
      var split = 0;
      for (var j = 1; j <= b.length; j++) {
        if (left[j] + right[b.length - j] >
            left[split] + right[b.length - split]) {
          split = j;
        }
      }
      compare(a.sublist(0, middle), b.sublist(0, split));
      compare(a.sublist(middle), b.sublist(split));
    }
    emit('equal', tail);
  }

  compare(tokens(original), tokens(corrected));
  return changes;
}
