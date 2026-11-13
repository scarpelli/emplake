import 'dart:math';

import 'catalog.dart';
import 'level.dart';
import 'rules.dart';

enum ChallengeKind {
  clock,

  restricted,
}

class LadderStep {
  const LadderStep(this.level, this.stars);

  final Level level;
  final Set<int> stars;
}

abstract final class Ladder {
  static const steps = [
    LadderStep(Level.easy, {1}),
    LadderStep(Level.easy, {2}),
    LadderStep(Level.intermediate, {1}),
    LadderStep(Level.intermediate, {2}),
    LadderStep(Level.advanced, {1}),
    LadderStep(Level.advanced, {2}),
    LadderStep(Level.hard, {1, 2}),
    LadderStep(Level.hard, {2, 3}),
  ];

  static const perStep = 3;

  static LadderStep at(int step) => steps[min(step, steps.length - 1)];
}

class ChallengeRun {
  const ChallengeRun({
    required this.kind,
    this.step = 0,
    this.inStep = 0,
    this.solved = 0,
    this.skipped = 0,
    this.lives = startLives,
    this.clock = clockStart,
    this.seen = const [],
    this.over = false,
    this.recorded = false,
  });

  static const clockStart = 180;
  static const skipPenalty = 10;
  static const stepBonus = 10;
  static const startLives = 3;

  final ChallengeKind kind;

  final int step;
  final int inStep;

  final int solved;
  final int skipped;

  final int lives;

  final int clock;

  final List<String> seen;

  final bool over;

  final bool recorded;

  LadderStep get ladder => Ladder.at(step);

  ChallengeRun _copy({
    int? step,
    int? inStep,
    int? solved,
    int? skipped,
    int? lives,
    int? clock,
    List<String>? seen,
    bool? over,
    bool? recorded,
  }) => ChallengeRun(
    kind: kind,
    step: step ?? this.step,
    inStep: inStep ?? this.inStep,
    solved: solved ?? this.solved,
    skipped: skipped ?? this.skipped,
    lives: lives ?? this.lives,
    clock: clock ?? this.clock,
    seen: seen ?? this.seen,
    over: over ?? this.over,
    recorded: recorded ?? this.recorded,
  );

  ChallengeRun playing(String id) => _copy(seen: [...seen, id]);

  bool get nextClimbs => inStep + 1 >= Ladder.perStep;

  ChallengeRun solve({required int secondsLeft}) {
    final climbs = nextClimbs;
    return _copy(
      solved: solved + 1,
      step: climbs ? step + 1 : step,
      inStep: climbs ? 0 : inStep + 1,
      clock: kind == ChallengeKind.clock ? secondsLeft + (climbs ? stepBonus : 0) : clock,
    );
  }

  ChallengeRun skip({required int secondsLeft}) {
    if (kind == ChallengeKind.clock) {
      final left = secondsLeft - skipPenalty;
      return _copy(skipped: skipped + 1, clock: max(0, left), over: left <= 0);
    }
    return _loseLife(skipped: skipped + 1);
  }

  ChallengeRun timeUp() => kind == ChallengeKind.clock ? _copy(clock: 0, over: true) : _loseLife();

  ChallengeRun _loseLife({int? skipped}) => _copy(lives: max(0, lives - 1), skipped: skipped, over: lives <= 1);

  ChallengeRun abandon() => over ? this : _copy(over: true);

  ChallengeRun markRecorded() => _copy(recorded: true);

  Map<String, dynamic> toJson() => {
    'kind': kind.name,
    'step': step,
    'inStep': inStep,
    'solved': solved,
    'skipped': skipped,
    'lives': lives,
    'clock': clock,
    'seen': seen,
    'over': over,
    'recorded': recorded,
  };

  factory ChallengeRun.fromJson(Map<String, dynamic> j) => ChallengeRun(
    kind: ChallengeKind.values.byName(j['kind'] as String),
    step: j['step'] as int? ?? 0,
    inStep: j['inStep'] as int? ?? 0,
    solved: j['solved'] as int? ?? 0,
    skipped: j['skipped'] as int? ?? 0,
    lives: j['lives'] as int? ?? startLives,
    clock: j['clock'] as int? ?? clockStart,
    seen: (j['seen'] as List? ?? const []).cast<String>(),
    over: j['over'] as bool? ?? false,
    recorded: j['recorded'] as bool? ?? false,
  );
}

class ChallengePlate {
  const ChallengePlate(this.entry, [this.variant]);

  final CatalogEntry entry;
  final RestrictedVariant? variant;

  Level get level => entry.level;
  Restriction? get rule => variant?.rule;

  String get solution => variant?.solution ?? entry.solution;
}

ChallengePlate? nextChallengePlate(Catalog catalog, ChallengeRun run, {Random? random}) {
  final r = random ?? Random();
  final rung = run.ladder;
  bool fits(CatalogEntry e) =>
      !run.seen.contains(e.id) && (run.kind == ChallengeKind.clock ? !e.trivial : e.variants.isNotEmpty);

  final level = catalog.entriesFor(rung.level).where(fits).toList();
  var pool = level.where((e) => rung.stars.contains(e.stars)).toList();
  if (pool.isEmpty) pool = level;
  if (pool.isEmpty) pool = catalog.all.where(fits).toList();
  if (pool.isEmpty) return null;
  final entry = pool[r.nextInt(pool.length)];
  if (run.kind == ChallengeKind.clock) return ChallengePlate(entry);
  return ChallengePlate(entry, entry.variants[r.nextInt(entry.variants.length)]);
}
