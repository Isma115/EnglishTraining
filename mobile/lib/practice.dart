import 'dart:math';

String normalize(String text) => text
    .toLowerCase()
    .replaceAll(RegExp('[’‘]'), "'")
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim()
    .replaceAll(RegExp(r'[.!?]+$'), '');

bool matches(String answer, List<dynamic> accepted) =>
    accepted.any((value) => normalize(value as String) == normalize(answer));

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
