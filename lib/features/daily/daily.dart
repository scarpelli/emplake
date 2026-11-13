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

  static String shareText({
    required String key,
    required bool solved,
    required int seconds,
    required int hints,
    required bool blind,
    required int streak,
    required String hintsLabel,
    required String blindLabel,
  }) {
    final date = '${key.substring(8, 10)}/${key.substring(5, 7)}';
    return [
      'EMPLAKE $date',
      solved ? '✓ ${seconds}s' : '✗',
      if (solved) hintsLabel,
      if (solved && blind) blindLabel,
      if (streak > 0) '🔥$streak',
    ].join(' · ');
  }
}
