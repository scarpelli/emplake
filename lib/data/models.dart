import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/game/domain/level.dart';

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.email,
    required this.totalPoints,
    required this.solvedCount,
    required this.skippedCount,
    this.streak = 0,
    this.bestStreak = 0,
    this.solvedByLevel = const {},
    this.achievements = const {},
    this.dailyStreak = 0,
    this.lastDaily,
    this.blindSolves = 0,
    this.inTimeSolves = 0,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
    displayName: m['displayName'] as String? ?? '',
    email: m['email'] as String? ?? '',
    totalPoints: (m['totalPoints'] as num?)?.toInt() ?? 0,
    solvedCount: (m['solvedCount'] as num?)?.toInt() ?? 0,
    skippedCount: (m['skippedCount'] as num?)?.toInt() ?? 0,
    streak: (m['streak'] as num?)?.toInt() ?? 0,
    bestStreak: (m['bestStreak'] as num?)?.toInt() ?? 0,
    solvedByLevel: {
      for (final e in ((m['solvedByLevel'] as Map?) ?? const {}).entries)
        ?Level.values.asNameMap()[e.key]: (e.value as num).toInt(),
    },
    achievements: {...((m['achievements'] as Map?) ?? const {}).keys.cast<String>()},
    dailyStreak: (m['dailyStreak'] as num?)?.toInt() ?? 0,
    lastDaily: m['lastDaily'] as String?,
    blindSolves: (m['blindSolves'] as num?)?.toInt() ?? 0,
    inTimeSolves: (m['inTimeSolves'] as num?)?.toInt() ?? 0,
  );

  final String displayName;
  final String email;
  final int totalPoints;
  final int solvedCount;
  final int skippedCount;

  final int streak;
  final int bestStreak;

  final Map<Level, int> solvedByLevel;

  final Set<String> achievements;

  final int dailyStreak;
  final String? lastDaily;

  final int blindSolves;
  final int inTimeSolves;
}

class SolvedEntry {
  const SolvedEntry({
    required this.number,
    required this.level,
    required this.expression,
    required this.latex,
    required this.points,
    required this.seconds,
    required this.inTime,
    required this.solvedAt,
  });

  factory SolvedEntry.fromMap(Map<String, dynamic> m) => SolvedEntry(
    number: m['number'] as String,
    level: Level.values.byName(m['level'] as String),
    expression: m['expression'] as String? ?? '',
    latex: m['latex'] as String? ?? '',
    points: (m['points'] as num?)?.toInt() ?? 0,
    seconds: (m['seconds'] as num?)?.toInt() ?? 0,
    inTime: m['inTime'] as bool? ?? true,
    solvedAt: (m['solvedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
  );

  final String number;
  final Level level;
  final String expression;
  final String latex;
  final int points;
  final int seconds;
  final bool inTime;
  final DateTime solvedAt;
}

class SaveOutcome {
  const SaveOutcome({required this.isNew, required this.pointsAwarded, required this.totalPoints, this.streak = 0});

  final bool isNew;
  final int pointsAwarded;
  final int totalPoints;

  final int streak;
}

class HistorySnapshot {
  const HistorySnapshot({required this.entries, required this.skippedCount, int? solvedCount, this.skipped = const []})
    : solvedCount = solvedCount ?? entries.length;

  final List<SkippedEntry> skipped;

  final int solvedCount;
  final List<SolvedEntry> entries;
  final int skippedCount;
}

class DailyResult {
  const DailyResult({
    required this.number,
    required this.level,
    required this.status,
    this.seconds = 0,
    this.hints = 0,
    this.blind = false,
  });

  factory DailyResult.fromMap(Map<String, dynamic> m) => DailyResult(
    number: m['number'] as String? ?? '',
    level: Level.values.asNameMap()[m['level']] ?? Level.intermediate,
    status: m['status'] as String? ?? 'started',
    seconds: (m['seconds'] as num?)?.toInt() ?? 0,
    hints: (m['hints'] as num?)?.toInt() ?? 0,
    blind: m['blind'] as bool? ?? false,
  );

  final String number;
  final Level level;

  final String status;
  final int seconds;
  final int hints;
  final bool blind;

  bool get solved => status == 'solved';
  bool get finished => status != 'started';
}

class SkippedEntry {
  const SkippedEntry({required this.number, required this.level, this.times = 1, this.revealed = false});

  factory SkippedEntry.fromMap(Map<String, dynamic> m) => SkippedEntry(
    number: m['number'] as String? ?? '',
    level: Level.values.asNameMap()[m['level']] ?? Level.easy,
    times: (m['times'] as num?)?.toInt() ?? 1,
    revealed: m['revealed'] as bool? ?? false,
  );

  final String number;
  final Level level;
  final int times;

  final bool revealed;
}
