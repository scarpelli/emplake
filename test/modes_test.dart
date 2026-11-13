import 'dart:io';
import 'dart:math';

import 'package:emplake/core/prefs.dart';
import 'package:emplake/features/game/application/game_controller.dart';
import 'package:emplake/features/game/domain/adventure.dart';
import 'package:emplake/features/game/domain/catalog.dart';
import 'package:emplake/features/game/domain/challenge.dart';
import 'package:emplake/features/game/domain/evaluator.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/rules.dart';
import 'package:emplake/features/game/domain/solution_codec.dart';
import 'package:emplake/features/game/domain/solver.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final catalog = Catalog.fromJsonString(File('assets/catalog.json').readAsStringSync());

  group('restrictions', () {
    test('text form round-trips', () {
      for (final r in [
        const Restriction.forbid(BinOp.mul),
        const Restriction.require(UnOp.sqrt),
        const Restriction.equalsAt(2),
      ]) {
        expect(Restriction.decode(r.encode()), r);
      }
    });

    test('forbid narrows the rules the evaluator uses', () {
      final rules = const Restriction.forbid(BinOp.mul).rulesFor(Level.hard);
      expect(rules.binary, isNot(contains(BinOp.mul)));
      final board = SolutionCodec.decode('1236', '=(*(*(1,2),3),6)');
      expect(Evaluator(Level.hard).isSolution(board), isTrue);
      expect(Evaluator(rules).isSolution(board), isFalse);
    });

    test('the solver honours each kind of rule', () {
      for (final rule in [
        const Restriction.forbid(BinOp.mul),
        const Restriction.require(BinOp.div),
        const Restriction.equalsAt(0),
      ]) {
        final r = Solver(Level.intermediate, restriction: rule).solve('1236');
        expect(r.solvable, isTrue, reason: '$rule');
        final b = r.board();
        expect(rule.allows(b), isTrue, reason: '$rule ${r.solution}');
        expect(Evaluator(rule.rulesFor(Level.intermediate)).isSolution(b), isTrue, reason: '$rule');
      }
    });
  });

  group('adventure', () {
    test('stars: solved, in time without hints, half the time left', () {
      expect(AdventureStars.of(inTime: false, hints: 0, secondsLeft: 0, levelSeconds: 45), 1);
      expect(AdventureStars.of(inTime: true, hints: 1, secondsLeft: 40, levelSeconds: 45), 1);
      expect(AdventureStars.of(inTime: true, hints: 0, secondsLeft: 10, levelSeconds: 45), 2);
      expect(AdventureStars.of(inTime: true, hints: 0, secondsLeft: 23, levelSeconds: 45), 3);
      expect(AdventureStars.of(inTime: true, hints: 3, secondsLeft: 40, levelSeconds: 45), 0);
    });

    test('the trail holds the whole catalog', () {
      final p = AdventureProgress.from(catalog, const {});
      expect(p.total, catalog.length);
      expect(p.stages.map((s) => s.number), [for (var i = 1; i <= catalog.length; i++) i]);
      expect(p.done, 0);
    });

    test('a window of 3 after the current stage; later columns locked', () {
      final p = AdventureProgress.from(catalog, const {});
      final easy = p.columns.first.stages;
      expect(easy[0].status, StageStatus.current);
      expect(easy.sublist(1, 4).every((s) => s.status == StageStatus.open), isTrue);
      expect(easy[4].status, StageStatus.locked);
      expect(p.columns[1].unlocked, isFalse);
      expect(p.columns[1].stages.every((s) => s.status == StageStatus.locked), isTrue);
    });

    test('the next column opens at the checkpoint; solved plates count anywhere', () {
      final easy = catalog.entriesFor(Level.easy);
      final stars = {for (final e in easy.take(AdventureProgress.checkpoint)) e.id: 1};
      final hard = catalog.entriesFor(Level.hard).last;
      stars[hard.id] = 2;
      final p = AdventureProgress.from(catalog, stars);
      expect(p.columns[0].done, AdventureProgress.checkpoint);
      expect(p.columns[0].current!.number, AdventureProgress.checkpoint + 1);
      expect(p.columns[1].unlocked, isTrue);
      expect(p.columns[1].current, isNotNull);
      expect(p.columns[2].unlocked, isFalse);
      expect(p.stageOf(hard.id)!.status, StageStatus.done);
      expect(p.done, AdventureProgress.checkpoint + 1);
    });
  });

  group('challenge runs', () {
    test('clock: climbing a rung gives +10 s, skipping costs 10 s, time up ends it', () {
      var run = const ChallengeRun(kind: ChallengeKind.clock);
      run = run.solve(secondsLeft: 170).solve(secondsLeft: 160);
      expect((run.step, run.clock), (0, 160));
      run = run.solve(secondsLeft: 150);
      expect((run.step, run.inStep, run.solved, run.clock), (1, 0, 3, 160));
      run = run.skip(secondsLeft: 100);
      expect((run.clock, run.over), (90, false));
      expect(run.skip(secondsLeft: 8).over, isTrue);
      expect(run.timeUp().over, isTrue);
    });

    test('restricted: three lives', () {
      var run = const ChallengeRun(kind: ChallengeKind.restricted);
      run = run.timeUp().skip(secondsLeft: 30);
      expect((run.lives, run.over), (1, false));
      expect(run.timeUp().over, isTrue);
    });

    test('plates follow the ladder, never repeat and respect each challenge', () {
      final r = Random(3);
      for (final kind in ChallengeKind.values) {
        var run = ChallengeRun(kind: kind);
        for (var i = 0; i < 40; i++) {
          final plate = nextChallengePlate(catalog, run, random: r)!;
          expect(run.seen, isNot(contains(plate.entry.id)));
          if (kind == ChallengeKind.clock) {
            expect(plate.entry.trivial, isFalse);
            expect(plate.rule, isNull);
          } else {
            expect(plate.rule, isNotNull);
          }
          if (i < 3) expect(plate.level, Level.easy);
          run = run.playing(plate.entry.id).solve(secondsLeft: 100);
        }
      }
    });
  });

  group('controller', () {
    late ProviderContainer container;
    GameController ctrl() => container.read(gameControllerProvider.notifier);
    GameState state() => container.read(gameControllerProvider)!;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();
      container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    });
    tearDown(() => container.dispose());

    test('clock plates start with the run clock and a 3-minute bar', () {
      const run = ChallengeRun(kind: ChallengeKind.clock, clock: 97);
      ctrl().start(mode: GameMode.challenges, level: Level.easy, number: '1236', run: run);
      expect(state().secondsLeft, 97);
      expect(state().clockLength, ChallengeRun.clockStart);
      expect(state().canHint, isFalse);
      expect(state().canPause, isFalse);
    });

    test('a true equation that breaks the rule is not accepted', () {
      ctrl().start(
        mode: GameMode.challenges,
        level: Level.easy,
        number: '1236',
        run: const ChallengeRun(kind: ChallengeKind.restricted),
        restriction: const Restriction.equalsAt(0),
        solution: '=(1,-(*(2,3),6))',
      );
      ctrl().drop(const PaletteBinaryDrag(BinOp.mul), 0);
      ctrl().drop(const PaletteBinaryDrag(BinOp.mul), 1);
      ctrl().drop(const PaletteEqualsDrag(), 2);
      expect(ctrl().check(), CheckResult.ruleBroken);
      expect(state().ruleBroken, isTrue);
    });

    test('skipping a restricted plate costs a life and shows its solution', () {
      ctrl().start(
        mode: GameMode.challenges,
        level: Level.easy,
        number: '1236',
        run: const ChallengeRun(kind: ChallengeKind.restricted),
        restriction: const Restriction.equalsAt(0),
        solution: '=(1,-(*(2,3),6))',
      );
      ctrl().skipChallenge();
      expect(state().phase, GamePhase.revealed);
      expect(state().run!.lives, 2);
      expect(state().board.eqDigitGap, 0);
    });

    test('a run restored after a reload is over', () {
      ctrl().start(
        mode: GameMode.challenges,
        level: Level.easy,
        number: '1236',
        run: const ChallengeRun(kind: ChallengeKind.clock, solved: 4),
      );
      final restored = GameState.fromJson(state().toJson());
      expect(restored.run!.over, isTrue);
      expect(restored.run!.solved, 4);
      expect(restored.phase, GamePhase.revealed);
    });
  });
}
