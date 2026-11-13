import 'package:emplake/core/prefs.dart';
import 'package:emplake/core/theme/blueprint.dart';
import 'package:emplake/features/game/application/game_controller.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/format.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ProviderContainer> makeContainer() async {
  final prefs = await SharedPreferences.getInstance();
  return ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
}

String text(ProviderContainer c) => linearText(c.read(gameControllerProvider)!.board);

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('backspace removes a binary operator, the "=" and a unary one; undo restores', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final c = container.read(gameControllerProvider.notifier);
    c.start(mode: GameMode.random, level: Level.easy, number: '1234');
    c.selectGap(0);
    c.applyBinary(BinOp.add);
    c.applyUnary(UnOp.sqrt);
    expect(c.removeSelected(), isTrue);
    expect(text(container), '1 + 2   3   4');

    final plus = container.read(gameControllerProvider)!.board.binaryAt(0)!.id;
    expect(container.read(gameControllerProvider)!.selection, NodeSelection(plus));
    expect(c.removeSelected(), isTrue);
    expect(text(container), '1   2   3   4');

    c.selectGap(1);
    c.placeEquals();
    c.selectEquals();
    expect(c.removeSelected(), isTrue);
    expect(container.read(gameControllerProvider)!.board.eqGap, isNull);

    c.undo();
    expect(container.read(gameControllerProvider)!.board.eqDigitGap, 1);
  });

  test('dropping signs from the palette and moving them', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final c = container.read(gameControllerProvider.notifier);
    c.start(mode: GameMode.random, level: Level.easy, number: '1234');
    expect(c.drop(const PaletteBinaryDrag(BinOp.mul), 0), isTrue);
    expect(c.drop(const PaletteEqualsDrag(), 1), isTrue);
    expect(text(container), '1 × 2 = 3   4');
    expect(c.canDrop(const MoveEqualsDrag(1), 1), isFalse, reason: 'dropping where it already is does nothing');
    expect(c.drop(const MoveEqualsDrag(1), 2), isTrue);
    expect(text(container), '1 × 2   3 = 4');
    final mul = container.read(gameControllerProvider)!.board.binaryAt(0)!.id;
    c.dropOutside(MoveBinaryDrag(mul, 0));
    expect(text(container), '1   2   3 = 4');
  });

  test('tutorial hints stop after being marked and come back when re-enabled', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final s = container.read(settingsProvider.notifier);
    expect(container.read(settingsProvider).hintsVisible, isTrue);
    s.markTutorialDone();
    expect(container.read(settingsProvider).hintsVisible, isFalse);
    s.setShowHints(true);
    expect(container.read(settingsProvider).hintsVisible, isTrue);
    s.setShowHints(false);
    expect(container.read(settingsProvider).hintsVisible, isFalse);
    expect(container.read(settingsProvider).showLiveValues, isTrue);
  });

  test('the highlight color follows the seed', () {
    Color accent(int seed, Brightness b) => Blueprint.fromSeed(Color(seed), b).accent;
    expect(accent(0xFF2460B7, Brightness.dark), isNot(accent(0xFF008966, Brightness.dark)));
    expect(accent(0xFF2460B7, Brightness.light), isNot(accent(0xFFA644A0, Brightness.light)));
  });

  test('revealing shows the solution on the board and ends the round without points', () async {
    final container = await makeContainer();
    addTearDown(container.dispose);
    final c = container.read(gameControllerProvider.notifier);
    c.start(mode: GameMode.random, level: Level.hard, number: '1236');
    c.selectGap(0);
    c.applyBinary(BinOp.add);
    c.reveal('=(*(*(1,2),3),6)');
    final s = container.read(gameControllerProvider)!;
    expect(s.phase, GamePhase.revealed);
    expect(s.pointsEarned, 0);
    expect(text(container), '1 × 2 × 3 = 6');
    expect(c.check(), CheckResult.notReady, reason: 'no checking after giving up');
  });

  group('click and carry', () {
    test('a palette sign picked first is dropped on the next tapped gap', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      final c = container.read(gameControllerProvider.notifier);
      c.start(mode: GameMode.random, level: Level.easy, number: '1236');
      c.applyBinary(BinOp.mul);
      expect(container.read(gameControllerProvider)!.selection, const CarrySelection(PaletteBinaryDrag(BinOp.mul)));
      c.selectGap(0);
      expect(text(container), '1 × 2   3   6');
      c.placeEquals();
      c.selectGap(1);
      expect(text(container), '1 × 2   3 = 6');
    });

    test('an operator just created is not carried: the next gap tap selects that gap', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      final c = container.read(gameControllerProvider.notifier);
      c.start(mode: GameMode.random, level: Level.easy, number: '1236');
      c.selectGap(0);
      c.applyBinary(BinOp.mul);
      c.selectGap(1);
      expect(text(container), '1 × 2   3   6');
      expect(container.read(gameControllerProvider)!.selection, const GapSelection(1));
    });

    test('tapping the same palette sign again puts it back', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      final c = container.read(gameControllerProvider.notifier);
      c.start(mode: GameMode.random, level: Level.easy, number: '1236');
      c.applyBinary(BinOp.add);
      c.applyBinary(BinOp.add);
      expect(container.read(gameControllerProvider)!.selection, isNull);
    });

    test('a selected operator or "=" moves to the next tapped gap', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      final c = container.read(gameControllerProvider.notifier);
      c.start(mode: GameMode.random, level: Level.easy, number: '1236');
      c.drop(const PaletteBinaryDrag(BinOp.add), 0);
      final plus = container.read(gameControllerProvider)!.board.binaryAt(0)!.id;
      c.selectNode(plus);
      c.selectGap(1);
      expect(text(container), '1   2   3 + 6');

      c.drop(const PaletteEqualsDrag(), 0);
      c.selectEquals();
      c.selectGap(1);
      expect(text(container), '1   2 = 3 + 6');
    });

    test('a carried sign dropped on an operator or on "=" replaces it', () async {
      final container = await makeContainer();
      addTearDown(container.dispose);
      final c = container.read(gameControllerProvider.notifier);
      c.start(mode: GameMode.random, level: Level.easy, number: '1236');
      c.drop(const PaletteBinaryDrag(BinOp.add), 0);
      c.drop(const PaletteEqualsDrag(), 2);
      c.applyBinary(BinOp.mul);
      final plus = container.read(gameControllerProvider)!.board.binaryAt(0)!.id;
      c.selectNode(plus);
      expect(text(container), '1 × 2   3 = 6');
      c.placeEquals();
      c.selectEquals();
      expect(container.read(gameControllerProvider)!.selection, const EqualsSelection());
    });
  });
}
