import '../game/domain/catalog.dart';
import '../game/domain/level.dart';

abstract final class Daily {
  static String keyFor(DateTime now) => _format(now.toLocal());

  static String _format(DateTime d) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  static DateTime _dateOf(String key) => DateTime.parse('${key}T00:00:00Z');

  static String yesterdayOf(String key) => _format(_dateOf(key).subtract(const Duration(days: 1)));

  static final _epoch = DateTime.utc(2026, 1, 1);

  static int dayNumber(String key) => _dateOf(key).difference(_epoch).inDays;

  static List<CatalogEntry> pool(Catalog catalog) => [
    for (final level in Level.values)
      for (final e in catalog.entriesFor(level))
        if (e.stars == 2) e,
  ];

  static CatalogEntry entryFor(Catalog catalog, String key) {
    final entries = pool(catalog);
    final n = entries.length;
    final day = dayNumber(key);
    final round = (day / n).floor();
    return entries[_round(n, round)[day - round * n]];
  }

  static List<int> _round(int n, int round) {
    final order = _shuffle(n, round);
    if (n > 2 && order.first == _shuffle(n, round - 1).last) {
      order[0] = order[1];
      order[1] = _shuffle(n, round - 1).last;
    }
    return order;
  }

  static List<int> _shuffle(int n, int round) {
    final order = List.generate(n, (i) => i);
    var seed = (round * 7919 + 12345) % 2147483647;
    if (seed <= 0) seed += 2147483646;
    for (var i = n - 1; i > 0; i--) {
      seed = seed * 48271 % 2147483647;
      final j = seed % (i + 1);
      final t = order[i];
      order[i] = order[j];
      order[j] = t;
    }
    return order;
  }

  static int nextStreak({required String key, String? lastDay, int current = 0}) {
    if (lastDay == key) return current;
    return lastDay == yesterdayOf(key) ? current + 1 : 1;
  }

  static int streakOn(String key, {String? lastDay, int current = 0}) =>
      lastDay == key || lastDay == yesterdayOf(key) ? current : 0;

  /// The scoreboard people paste in chats. Nothing in it gives the plate
  /// away: time as a speed bar against the level clock, hints as lamps.
  ///
  /// ```
  /// EMPLAKE · placa do dia 15/11
  ///
  /// ⏱️ 🟩🟩🟩🟩⬜ 42s
  /// 💡 ⚫⚫⚫ sem dicas · 🙈 às cegas
  /// 🔥 5 dias seguidos
  ///
  /// https://…
  /// ```
  static String shareText({
    required String key,
    required bool solved,
    required int seconds,
    required int referenceSeconds,
    required int hints,
    required bool blind,
    required int streak,
    required DailyShareLabels labels,
    String? link,
  }) {
    final date = '${key.substring(8, 10)}/${key.substring(5, 7)}';
    final speed = solved ? (5 * (1 - seconds / referenceSeconds)).ceil().clamp(1, 5) : 0;
    final time = solved
        ? '${'🟩' * speed}${'⬜' * (5 - speed)} ${formatSeconds(seconds)}'
        : '🟥🟥🟥🟥🟥 ${labels.missed}';
    final lamps = '${'🟡' * hints.clamp(0, 3)}${'⚫' * (3 - hints.clamp(0, 3))}';
    return [
      'EMPLAKE · ${labels.title} $date',
      '',
      '⏱️ $time',
      if (solved) ['💡 $lamps ${labels.hints}', if (blind) '🙈 ${labels.blind}'].join(' · '),
      if (streak > 0) '🔥 ${labels.streak}',
      if (link != null) ...['', link],
    ].join('\n');
  }

  static String formatSeconds(int s) => s < 60 ? '${s}s' : '${s ~/ 60}:${(s % 60).toString().padLeft(2, '0')}';
}

/// Localized pieces of [Daily.shareText].
class DailyShareLabels {
  const DailyShareLabels({
    required this.title,
    required this.hints,
    required this.blind,
    required this.streak,
    required this.missed,
  });

  final String title;
  final String hints;
  final String blind;
  final String streak;
  final String missed;
}

/// Everyone's results for one plate of the day (`dailyStats/{key}`): how many
/// finished it, how many missed, and solve times in 10-second buckets. Enough
/// for "1.240 played today" and "faster than 68%" without reading other users.
class DailyStats {
  const DailyStats({this.plays = 0, this.missed = 0, this.times = const {}});

  factory DailyStats.fromMap(Map<String, dynamic> m) => DailyStats(
    plays: (m['plays'] as num?)?.toInt() ?? 0,
    missed: (m['missed'] as num?)?.toInt() ?? 0,
    times: {
      for (final e in ((m['times'] as Map?) ?? const {}).entries)
        ?int.tryParse('${e.key}'.substring(1)): (e.value as num).toInt(),
    },
  );

  static const bucketSeconds = 10;

  /// Firestore map keys must not start with a digit for dotted updates.
  static String bucketKey(int seconds) => 'b${seconds ~/ bucketSeconds}';

  final int plays;
  final int missed;
  final Map<int, int> times;

  /// Share of the other players who did worse (slower bucket or missed), as a
  /// whole percentage; null while nobody else has played.
  int? betterThan(int seconds) {
    final others = plays - 1;
    if (others <= 0) return null;
    final mine = seconds ~/ bucketSeconds;
    final slower = times.entries.where((e) => e.key > mine).fold(0, (a, e) => a + e.value);
    return (100 * (slower + missed) / others).round().clamp(0, 100);
  }
}
