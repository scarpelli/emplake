import '../game/domain/catalog.dart';
import '../game/domain/level.dart';

abstract final class Daily {
  static String keyFor(DateTime now) {
    final d = now.toUtc();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${d.year}-${two(d.month)}-${two(d.day)}';
  }

  static String yesterdayOf(String key) {
    final d = DateTime.parse('${key}T00:00:00Z').subtract(const Duration(days: 1));
    return keyFor(d);
  }

  static CatalogEntry entryFor(Catalog catalog, String key) {
    final pool = [
      for (final level in Level.values)
        for (final e in catalog.entriesFor(level))
          if (e.stars == 2) e,
    ];
    var h = 7;
    for (final c in key.codeUnits) {
      h = (h * 131 + c) % 1000000007;
    }
    return pool[h % pool.length];
  }

  static int nextStreak({required String key, required bool solved, String? lastDaily, int current = 0}) {
    if (!solved) return 0;
    if (lastDaily == key) return current;
    return lastDaily == yesterdayOf(key) ? current + 1 : 1;
  }

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
