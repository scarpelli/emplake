import 'dart:io';

import 'package:emplake/core/prefs.dart';
import 'package:emplake/data/models.dart';
import 'package:emplake/features/achievements/achievements.dart';
import 'package:emplake/features/daily/daily.dart';
import 'package:emplake/features/game/application/game_controller.dart';
import 'package:emplake/features/game/domain/catalog.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/hints.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> makeContainer() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  group('score', () {
    test('base + time bonus, then hints, blind bonus and streak', () {
      const level = Level.intermediate;
      expect(level.pointsFor(secondsLeft: 30, inTime: true), 16);
      expect(level.pointsFor(secondsLeft: 30, inTime: true, hints: 1), 10);
      expect(level.pointsFor(secondsLeft: 30, inTime: true, hints: 2), 5);
      expect(level.pointsFor(secondsLeft: 30, inTime: true, hints: 3), 0);
      expect(level.pointsFor(secondsLeft: 30, inTime: true, blind: true), 20);
      expect(level.pointsFor(secondsLeft: 30, inTime: true, streak: 3), 20);
      expect(level.pointsFor(secondsLeft: 30, inTime: true, streak: 99), 24, reason: 'streak caps at +50 %');
      expect(level.pointsFor(secondsLeft: 0, inTime: false, blind: true, streak: 5), 0);
    });
  });

  group('hints', () {
    test('point at the "=" first, then at the smallest branch', () {
      final h = HintInfo.from('1236', '=(*(*(1,2),3),6)');
      expect(h.equalsGap, 2);
      expect(h.linkGap, 0);
      expect(h.linkOp, BinOp.mul);
    });

    test('the third hint reveals the solution and ends the round without points', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      final c = container.read(gameControllerProvider.notifier);
      c.start(mode: GameMode.random, level: Level.easy, number: '1236');
      const sol = '=(*(*(1,2),3),6)';
      c.useHint(sol);
      c.useHint(sol);
      expect(container.read(gameControllerProvider)!.hintsUsed, 2);
      expect(container.read(gameControllerProvider)!.phase, GamePhase.playing);
      c.useHint(sol);
      final s = container.read(gameControllerProvider)!;
      expect(s.phase, GamePhase.revealed);
      expect(s.canHint, isFalse);
    });

    test('hints lower the points of a right answer', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      final c = container.read(gameControllerProvider.notifier);
      c.start(mode: GameMode.random, level: Level.easy, number: '1236', liveValues: false);
      c.useHint('=(*(*(1,2),3),6)');
      c.drop(const PaletteBinaryDrag(BinOp.mul), 0);
      c.drop(const PaletteBinaryDrag(BinOp.mul), 1);
      c.drop(const PaletteEqualsDrag(), 2);
      expect(c.check(), CheckResult.right);
      final s = container.read(gameControllerProvider)!;
      expect(s.pointsEarned, 11);
      expect(s.score.blind, isTrue);
      expect(s.score.hints, 1);
    });
  });

  group('practice and live values', () {
    test('practice has no clock and gives no points', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      final c = container.read(gameControllerProvider.notifier);
      c.start(mode: GameMode.random, level: Level.hard, number: '1236', practice: true);
      final s = container.read(gameControllerProvider)!;
      expect(s.timeUp, isFalse);
      c.drop(const PaletteBinaryDrag(BinOp.mul), 0);
      c.drop(const PaletteBinaryDrag(BinOp.mul), 1);
      c.drop(const PaletteEqualsDrag(), 2);
      expect(c.check(streak: 4), CheckResult.right);
      expect(container.read(gameControllerProvider)!.pointsEarned, 0);
    });

    test('turning live values on mid-number cancels the blind bonus', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      final c = container.read(gameControllerProvider.notifier);
      c.start(mode: GameMode.random, level: Level.easy, number: '1236', liveValues: false);
      expect(container.read(gameControllerProvider)!.sawLiveValues, isFalse);
      c.noteLiveValuesShown();
      expect(container.read(gameControllerProvider)!.sawLiveValues, isTrue);
    });
  });

  group('plate of the day', () {
    final catalog = Catalog.fromJsonString(File('assets/catalog.json').readAsStringSync());

    test('same day, same plate; a ★2 catalog entry', () {
      final a = Daily.entryFor(catalog, '2026-11-13');
      expect(Daily.entryFor(catalog, '2026-11-13').number, a.number);
      expect(a.stars, 2);
      final week = {for (var d = 10; d < 17; d++) Daily.entryFor(catalog, '2026-11-$d').number};
      expect(week.length, greaterThan(3), reason: 'days vary');
    });

    test('streak grows on consecutive days and resets on a miss or a gap', () {
      expect(Daily.nextStreak(key: '2026-11-13', solved: true, lastDaily: '2026-11-12', current: 3), 4);
      expect(Daily.nextStreak(key: '2026-11-13', solved: true, lastDaily: '2026-11-10', current: 3), 1);
      expect(Daily.nextStreak(key: '2026-11-13', solved: false, lastDaily: '2026-11-12', current: 3), 0);
      expect(Daily.yesterdayOf('2026-03-01'), '2026-02-28');
    });

    test('share text', () {
      final text = Daily.shareText(
        key: '2026-11-13',
        solved: true,
        seconds: 32,
        hints: 0,
        blind: true,
        streak: 4,
        hintsLabel: 'sem dicas',
        blindLabel: 'às cegas',
      );
      expect(text, 'EMPLAKE 13/11 · ✓ 32s · sem dicas · às cegas · 🔥4');
    });
  });

  group('achievements', () {
    test('newly reached ones exclude those already unlocked', () {
      const p = UserProfile(
        displayName: '',
        email: '',
        totalPoints: 0,
        solvedCount: 1,
        skippedCount: 0,
        blindSolves: 1,
        achievements: {'firstSolve'},
      );
      expect(Achievement.newlyReached(p), [Achievement.blind]);
      expect(Achievement.newlyReached(p, solvedStars: 3), [Achievement.blind, Achievement.threeStars]);
    });
  });
}
