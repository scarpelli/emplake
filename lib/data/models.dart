import 'package:cloud_firestore/cloud_firestore.dart';

import '../features/game/domain/level.dart';

class UserProfile {
  const UserProfile({
    required this.displayName,
    required this.email,
    required this.totalPoints,
    required this.solvedCount,
    required this.skippedCount,
  });

  factory UserProfile.fromMap(Map<String, dynamic> m) => UserProfile(
        displayName: m['displayName'] as String? ?? '',
        email: m['email'] as String? ?? '',
        totalPoints: (m['totalPoints'] as num?)?.toInt() ?? 0,
        solvedCount: (m['solvedCount'] as num?)?.toInt() ?? 0,
        skippedCount: (m['skippedCount'] as num?)?.toInt() ?? 0,
      );

  final String displayName;
  final String email;
  final int totalPoints;
  final int solvedCount;
  final int skippedCount;
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
  const SaveOutcome({required this.isNew, required this.pointsAwarded, required this.totalPoints});

  final bool isNew;
  final int pointsAwarded;
  final int totalPoints;
}

class HistorySnapshot {
  const HistorySnapshot({required this.entries, required this.skippedCount});
  final List<SolvedEntry> entries;
  final int skippedCount;
}
