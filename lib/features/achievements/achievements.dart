import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../l10n/app_localizations.dart';
import '../game/domain/level.dart';

enum Achievement {
  firstSolve(Icons.flag_outlined),
  tenInTime(Icons.timer_outlined),
  blind(Icons.visibility_off_outlined),
  threeStars(Icons.star_outline),
  allLevels(Icons.layers_outlined),
  streak5(Icons.local_fire_department_outlined),
  daily7(Icons.calendar_month_outlined),
  hundred(Icons.military_tech_outlined);

  const Achievement(this.icon);

  final IconData icon;

  bool reached(UserProfile p, {int? solvedStars}) => switch (this) {
    firstSolve => p.solvedCount >= 1,
    tenInTime => p.inTimeSolves >= 10,
    blind => p.blindSolves >= 1,
    threeStars => (solvedStars ?? 0) >= 3,
    allLevels => Level.values.every((l) => (p.solvedByLevel[l] ?? 0) > 0),
    streak5 => p.bestStreak >= 5,
    daily7 => p.dailyStreak >= 7,
    hundred => p.solvedCount >= 100,
  };

  static List<Achievement> newlyReached(UserProfile p, {int? solvedStars}) => [
    for (final a in values)
      if (!p.achievements.contains(a.name) && a.reached(p, solvedStars: solvedStars)) a,
  ];

  String title(AppLocalizations l) => switch (this) {
    firstSolve => l.achFirstSolve,
    tenInTime => l.achTenInTime,
    blind => l.achBlind,
    threeStars => l.achThreeStars,
    allLevels => l.achAllLevels,
    streak5 => l.achStreak5,
    daily7 => l.achDaily7,
    hundred => l.achHundred,
  };

  String description(AppLocalizations l) => switch (this) {
    firstSolve => l.achFirstSolveDesc,
    tenInTime => l.achTenInTimeDesc,
    blind => l.achBlindDesc,
    threeStars => l.achThreeStarsDesc,
    allLevels => l.achAllLevelsDesc,
    streak5 => l.achStreak5Desc,
    daily7 => l.achDaily7Desc,
    hundred => l.achHundredDesc,
  };
}
