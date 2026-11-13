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
}

Future<_Calls> _pump(WidgetTester tester, {bool showValues = true}) async {
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
              ),
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
    final gaps = find.byIcon(Icons.add);
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

  testWidgets('live values can be hidden', (tester) async {
    await _pump(tester);
    expect(find.textContaining('3'), findsWidgets);
    expect(find.text('→ 3'), findsOneWidget);
    await _pump(tester, showValues: false);
    expect(find.text('→ 3'), findsNothing);
  }, variant: desktop);
}
