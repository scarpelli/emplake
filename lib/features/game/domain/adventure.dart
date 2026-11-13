import 'catalog.dart';
import 'level.dart';

abstract final class AdventureStars {
  static int of({required bool inTime, required int hints, required int secondsLeft, required int levelSeconds}) {
    if (hints >= 3) return 0;
    if (!inTime || hints > 0) return 1;
    return secondsLeft * 2 >= levelSeconds ? 3 : 2;
  }

  static int ofSolved({required Level level, required bool inTime, required int hints, required int seconds}) =>
      of(inTime: inTime, hints: hints, secondsLeft: level.seconds - seconds, levelSeconds: level.seconds);
}

enum StageStatus { done, current, open, locked }

class Stage {
  const Stage({required this.entry, required this.number, required this.stars, required this.status});

  final CatalogEntry entry;

  final int number;
  final int stars;
  final StageStatus status;

  bool get playable => status != StageStatus.locked;
}

class AdventureColumn {
  const AdventureColumn({required this.level, required this.stages, required this.unlocked});

  final Level level;
  final List<Stage> stages;
  final bool unlocked;

  int get done => stages.where((s) => s.status == StageStatus.done).length;
  int get total => stages.length;
  Stage? get current => stages.where((s) => s.status == StageStatus.current).firstOrNull;
}

class AdventureProgress {
  AdventureProgress._(this.columns);

  static const window = 3;
  static const checkpoint = 12;

  factory AdventureProgress.from(Catalog catalog, Map<String, int> stars) {
    final columns = <AdventureColumn>[];
    var number = 0;
    var unlocked = true;
    for (final level in Level.values) {
      final entries = catalog.entriesFor(level);
      final got = [for (final e in entries) stars[e.id] ?? 0];
      final current = got.indexWhere((s) => s == 0);
      final stages = <Stage>[
        for (var i = 0; i < entries.length; i++)
          Stage(
            entry: entries[i],
            number: ++number,
            stars: got[i],
            status: got[i] > 0
                ? StageStatus.done
                : !unlocked
                ? StageStatus.locked
                : i == current
                ? StageStatus.current
                : i <= current + window
                ? StageStatus.open
                : StageStatus.locked,
          ),
      ];
      final column = AdventureColumn(level: level, stages: stages, unlocked: unlocked);
      columns.add(column);
      final need = entries.length < checkpoint ? entries.length : checkpoint;
      unlocked = unlocked && column.done >= need;
    }
    return AdventureProgress._(columns);
  }

  final List<AdventureColumn> columns;

  int get done => columns.fold(0, (a, c) => a + c.done);
  int get total => columns.fold(0, (a, c) => a + c.total);

  Iterable<Stage> get stages => columns.expand((c) => c.stages);

  Stage? stage(int number) => stages.where((s) => s.number == number).firstOrNull;

  Stage? stageOf(String id) => stages.where((s) => s.entry.id == id).firstOrNull;

  Stage? get focus {
    for (final c in columns.reversed) {
      if (c.unlocked && c.current != null) return c.current;
    }
    return null;
  }

  Stage? nextAfter(int number) {
    final s = stage(number);
    if (s == null) return null;
    final col = columns.firstWhere((c) => c.level == s.entry.level);
    for (final t in col.stages) {
      if (t.number > number && t.status != StageStatus.done && t.playable) return t;
    }
    return null;
  }
}
