import 'package:emplake/core/prefs.dart';
import 'package:emplake/features/game/application/game_controller.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/format.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> makeContainer() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
}

void play9227(GameController c) {
  c.selectGap(1);
  c.applyBinary(BinOp.add);
  c.applyUnary(UnOp.sqrt);
  c.selectGap(0);
  c.applyBinary(BinOp.sub);
  c.selectGap(0);
  c.placeEquals();
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('a full game: link, wrap, equals, check', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final c = container.read(gameControllerProvider.notifier);
    c.start(mode: GameMode.random, level: Level.intermediate, number: '9227');
    play9227(c);

    final s = container.read(gameControllerProvider)!;
    expect(linearText(s.board), '9 − √(2 + 2) = 7');
    expect(s.board.isComplete, isTrue);

    expect(c.check(), CheckResult.right);
    final done = container.read(gameControllerProvider)!;
    expect(done.phase, GamePhase.solved);
    expect(done.solvedInTime, isTrue);
    expect(done.pointsEarned, Level.intermediate.pointsFor(secondsLeft: Level.intermediate.seconds, inTime: true));
  });

  test('changing an operator, undo and a false equation', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final c = container.read(gameControllerProvider.notifier);
    c.start(mode: GameMode.random, level: Level.hard, number: '8796');
    c.selectGap(0);
    c.applyBinary(BinOp.add);
    c.applyBinary(BinOp.mul);
    expect(linearText(container.read(gameControllerProvider)!.board), '8 × 7   9   6');
    c.undo();
    expect(linearText(container.read(gameControllerProvider)!.board), '8 + 7   9   6');
    c.selectGap(0);
    c.placeEquals();
    c.selectGap(1);
    c.applyBinary(BinOp.sub);
    expect(c.check(), CheckResult.wrong);
    expect(container.read(gameControllerProvider)!.wrongAttempt, isTrue);
    c.undo();
    expect(container.read(gameControllerProvider)!.wrongAttempt, isFalse);
  });

  test('a hint after a false equation replaces its banner', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final c = container.read(gameControllerProvider.notifier);
    c.start(mode: GameMode.random, level: Level.hard, number: '8796');
    c.selectGap(0);
    c.applyBinary(BinOp.add);
    c.selectGap(0);
    c.placeEquals();
    c.selectGap(1);
    c.applyBinary(BinOp.sub);
    expect(c.check(), CheckResult.wrong);
    c.useHint('=(+(8,7),*(9,6))');
    final s = container.read(gameControllerProvider)!;
    expect(s.hintsUsed, 1);
    expect(s.wrongAttempt, isFalse);
  });

  test('only one pause per number', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final c = container.read(gameControllerProvider.notifier);
    c.start(mode: GameMode.random, level: Level.easy, number: '1234');
    c.pause();
    expect(container.read(gameControllerProvider)!.paused, isTrue);
    c.resume();
    c.pause();
    expect(container.read(gameControllerProvider)!.paused, isFalse);
    expect(container.read(gameControllerProvider)!.pauseUsed, isTrue);
  });

  test('a game in progress is restored paused after reopening', () async {
    final first = await makeContainer();
    final c = first.read(gameControllerProvider.notifier);
    c.start(mode: GameMode.specific, level: Level.intermediate, number: '9227');
    c.selectGap(1);
    c.applyBinary(BinOp.add);
    first.dispose();

    final second = await makeContainer();
    addTearDown(second.dispose);
    final restored = second.read(gameControllerProvider)!;
    expect(restored.mode, GameMode.specific);
    expect(restored.number, '9227');
    expect(linearText(restored.board), '9   2 + 2   7');
    expect(restored.paused, isTrue);
    expect(restored.pauseUsed, isFalse, reason: 'restoring must not spend the player\'s pause');
    expect(restored.history, isNotEmpty);
  });

  test('clearing the game forgets it', () async {
    final first = await makeContainer();
    first.read(gameControllerProvider.notifier)
      ..start(mode: GameMode.random, level: Level.easy, number: '1234')
      ..clear();
    first.dispose();
    final second = await makeContainer();
    addTearDown(second.dispose);
    expect(second.read(gameControllerProvider), isNull);
  });
}
