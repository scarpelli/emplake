import 'package:emplake/core/theme/blueprint.dart';
import 'package:emplake/features/game/application/game_controller.dart';
import 'package:emplake/features/game/domain/board.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/presentation/tree_view.dart';
import 'package:emplake/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

GameState _state() =>
    GameState(mode: GameMode.random, level: Level.easy, board: Board.start('1234').link(0, BinOp.add), secondsLeft: 45);

class _Calls {
  final drops = <(SignDrag, int)>[];
  final outside = <SignDrag>[];
  final onNode = <(SignDrag, int)>[];
  final wrong = <SignDrag>[];
}

Future<_Calls> _pump(WidgetTester tester, {bool showValues = true, List<(SignDrag, String)> sources = const []}) async {
  final calls = _Calls();
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [Blueprint.fromSeed(const Color(0xFF2460B7), Brightness.light)]),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(
        body: Column(
          children: [
            SizedBox(
              width: 400,
              height: 300,
              child: TreeView(
                state: _state(),
                showValues: showValues,
                onTapNode: (_) {},
                onTapGap: (_) {},
                onDrop: (d, g) => calls.drops.add((d, g)),
                canDrop: (d, g) => true,
                onDropOutside: calls.outside.add,
                onDropOnNode: (d, id) => calls.onNode.add((d, id)),
                onWrongDrop: calls.wrong.add,
              ),
            ),
            Row(
              children: [
                for (final (drag, label) in sources)
                  SignDraggable(
                    data: drag,
                    feedback: const SizedBox(width: 20, height: 20),
                    child: SizedBox(width: 48, height: 48, child: Center(child: Text('src $label'))),
                  ),
              ],
            ),
            const Expanded(child: SizedBox.expand(key: Key('outside'))),
          ],
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return calls;
}

Future<void> _drag(WidgetTester tester, Finder from, Offset to) async {
  final g = await tester.startGesture(tester.getCenter(from));
  await tester.pump(const Duration(milliseconds: 20));
  await g.moveBy(const Offset(0, -20));
  await tester.pump();
  await g.moveTo(to);
  await tester.pump();
  await g.up();
  await tester.pumpAndSettle();
}

void main() {
  final desktop = TargetPlatformVariant.only(TargetPlatform.windows);

  testWidgets('dragging an operator onto an open gap drops it there', (tester) async {
    final calls = await _pump(tester);
    final gaps = find.bySemanticsLabel(RegExp(r'^vão \d$'));
    expect(gaps, findsNWidgets(2));
    await _drag(tester, find.text('+'), tester.getCenter(gaps.last));
    expect(calls.drops, hasLength(1));
    final (drag, gap) = calls.drops.single;
    expect(drag, isA<MoveBinaryDrag>());
    expect((drag as MoveBinaryDrag).fromGap, 0);
    expect(gap, 2);
  }, variant: desktop);

  testWidgets('dragging an operator off the tree removes it', (tester) async {
    final calls = await _pump(tester);
    await _drag(tester, find.text('+'), tester.getCenter(find.byKey(const Key('outside'))));
    expect(calls.drops, isEmpty);
    expect(calls.outside.single, isA<MoveBinaryDrag>());
  }, variant: desktop);

  testWidgets('a sign that goes on a segment is applied to the number it is dropped on', (tester) async {
    final calls = await _pump(tester, showValues: false, sources: [(const PaletteUnaryDrag(UnOp.sqrt), '√')]);
    await _drag(tester, find.text('src √'), tester.getCenter(find.text('4')));
    expect(calls.wrong, isEmpty);
    final (drag, nodeId) = calls.onNode.single;
    expect((drag as PaletteUnaryDrag).op, UnOp.sqrt);
    expect(nodeId, _state().board.blocks.last.id);
  }, variant: desktop);

  testWidgets('a sign that goes on a segment can wrap a whole branch', (tester) async {
    final calls = await _pump(tester, showValues: false, sources: [(const PaletteParensDrag(), '( )')]);
    await _drag(tester, find.text('src ( )'), tester.getCenter(find.text('+')));
    expect(calls.onNode.single.$2, _state().board.blocks.first.id);
    expect(calls.drops, isEmpty);
  }, variant: desktop);

  testWidgets('a sign that goes on a segment is refused between two numbers', (tester) async {
    final calls = await _pump(tester, showValues: false, sources: [(const PaletteUnaryDrag(UnOp.fact), '!')]);
    await _drag(tester, find.text('src !'), tester.getCenter(find.bySemanticsLabel(RegExp(r'^vão \d$')).last));
    expect(calls.wrong.single, isA<PaletteUnaryDrag>());
    expect(calls.drops, isEmpty);
    expect(calls.onNode, isEmpty);
  }, variant: desktop);

  testWidgets('a sign that goes between numbers is refused on a number', (tester) async {
    final calls = await _pump(tester, showValues: false, sources: [(const PaletteBinaryDrag(BinOp.mul), '×')]);
    await _drag(tester, find.text('src ×'), tester.getCenter(find.text('4')));
    expect(calls.wrong.single, isA<PaletteBinaryDrag>());
    expect(calls.drops, isEmpty);
  }, variant: desktop);

  testWidgets('live values can be hidden', (tester) async {
    await _pump(tester);
    expect(find.textContaining('3'), findsWidgets);
    expect(find.textContaining(_three), findsOneWidget);
    await _pump(tester, showValues: false);
    expect(find.textContaining(_three), findsNothing);
  }, variant: desktop);

  testWidgets('live values of neighbouring branches do not overlap', (tester) async {
    final board = Board.start('9486').applyUnary(0, UnOp.sqrt).applyUnary(1, UnOp.fact).placeEquals(1);
    for (final width in [340.0, 392.0, 480.0]) {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [Blueprint.fromSeed(const Color(0xFF2460B7), Brightness.light)]),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Scaffold(
            body: Center(
              child: SizedBox(
                width: width,
                height: 300,
                child: TreeView(
                  state: GameState(mode: GameMode.random, level: Level.easy, board: board, secondsLeft: 45),
                  onTapNode: (_) {},
                  onTapGap: (_) {},
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final labels = [
        tester.getRect(find.textContaining(RegExp(r'^(→ 3|3 ←)$'))),
        tester.getRect(find.textContaining(RegExp(r'^(→ 24|24 ←)$'))),
        tester.getRect(find.text('24 ≠ 8')),
      ];
      final nodes = [for (final s in ['9', '4', '8', '6', '√', '!', '=']) tester.getRect(find.text(s))];
      for (var i = 0; i < labels.length; i++) {
        for (final other in [...labels.skip(i + 1), ...nodes]) {
          expect(labels[i].overlaps(other), isFalse, reason: 'width $width: ${labels[i]} overlaps $other');
        }
      }
    }
  }, variant: desktop);
}

final _three = RegExp(r'^(→ 3|3 ←)$');
