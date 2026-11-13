import 'package:flutter/material.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../game/application/game_controller.dart';
import '../game/domain/expr.dart';
import '../game/domain/level.dart';
import '../game/domain/solution_codec.dart';
import '../game/presentation/tree_view.dart';

Future<void> showHelpDialog(BuildContext context, {bool scoring = false}) => showDialog<void>(
  context: context,
  barrierColor: Colors.black.withValues(alpha: 0.5),
  builder: (_) => HelpDialog(initialTab: scoring ? 2 : 0),
);

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final bp = context.bp;
    final size = MediaQuery.sizeOf(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: 520, maxHeight: size.height * 0.85),
        child: DefaultTabController(
          length: 3,
          initialIndex: initialTab,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        l.helpTitle,
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5),
                      ),
                    ),
                    BoxIconButton(
                      icon: Icons.close,
                      tooltip: l.helpGotIt,
                      size: 40,
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              TabBar(
                labelColor: bp.ink,
                unselectedLabelColor: bp.muted,
                indicatorColor: bp.ink,
                dividerColor: bp.lineSoft,
                tabs: [
                  Tab(text: l.helpTabPlay),
                  Tab(text: l.helpTabOperators),
                  Tab(text: l.helpTabScoring),
                ],
              ),
              const Flexible(child: TabBarView(children: [_PlayTab(), _OperatorsTab(), _ScoringTab()])),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                child: FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.helpGotIt)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _scroll(List<Widget> children) => SingleChildScrollView(
  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
);

class _Bullet extends StatelessWidget {
  const _Bullet(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 7, right: 10),
          child: Container(width: 6, height: 6, color: context.bp.ink),
        ),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45))),
      ],
    ),
  );
}

class _PlayTab extends StatelessWidget {
  const _PlayTab();

  static final _example = GameState(
    mode: GameMode.random,
    level: Level.easy,
    board: SolutionCodec.decode('1236', '=(*(*(1,2),3),6)'),
    secondsLeft: 0,
    phase: GamePhase.solved,
  );

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final steps = [l.help1, l.help2, l.help3, l.help4];
    return _scroll([
      for (var i = 0; i < steps.length; i++)
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: bp.ink),
                ),
                child: Text('${i + 1}', style: t.labelMedium),
              ),
              const SizedBox(width: 12),
              Expanded(child: Text(steps[i], style: t.bodyMedium?.copyWith(height: 1.45))),
            ],
          ),
        ),
      Eyebrow(l.helpExample),
      const SizedBox(height: 4),
      Container(
        height: 190,
        decoration: BoxDecoration(border: Border.all(color: bp.lineSoft)),
        child: IgnorePointer(
          child: TreeView(state: _example, onTapNode: (_) {}, onTapGap: (_) {}),
        ),
      ),
      const SizedBox(height: 6),
      Text(l.helpExampleCaption, style: t.bodySmall?.copyWith(color: bp.muted)),
      const SizedBox(height: 16),
      Eyebrow(l.helpKeys),
      const SizedBox(height: 6),
      Text(l.helpKeysList, style: t.bodySmall?.copyWith(height: 1.6, color: bp.muted)),
    ]);
  }
}

class _OperatorsTab extends StatelessWidget {
  const _OperatorsTab();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final sep = context.decimalSeparator;

    String levels(bool Function(Level) allows) => [
      for (final level in Level.values)
        if (allows(level)) level.shortLabel(l),
    ].join(' · ');

    final rows = <(String, String, String, String)>[
      for (final op in BinOp.values) (op.label, op.name(l), op.example(sep), levels((lv) => lv.binary.contains(op))),
      for (final op in UnOp.values) (op.label, op.name(l), op.example(sep), levels((lv) => lv.unary.contains(op))),
      ('( )', l.toggleParens, '(1 + 2) × 3 = 9', levels((_) => true)),
    ];

    return _scroll([
      Text(l.helpOperatorsIntro, style: t.bodyMedium?.copyWith(height: 1.45)),
      const SizedBox(height: 12),
      for (final (symbol, name, example, where) in rows)
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: bp.lineSoft)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 48,
                child: Text(symbol, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name, style: t.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                    Text(example, style: t.bodyMedium),
                    Text(where, style: t.bodySmall?.copyWith(color: bp.muted)),
                  ],
                ),
              ),
            ],
          ),
        ),
      const SizedBox(height: 12),
      Text(l.helpFraction, style: t.bodySmall?.copyWith(color: bp.muted)),
    ]);
  }
}

class _ScoringTab extends StatelessWidget {
  const _ScoringTab();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final levelName = t.labelLarge?.copyWith(fontWeight: FontWeight.w600);

    Widget row(List<Widget> cells, {bool last = false, bool header = false}) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: header ? bp.deep.withValues(alpha: 0.35) : null,
        border: last ? null : Border(bottom: BorderSide(color: bp.lineSoft)),
      ),
      child: Row(children: cells),
    );

    return _scroll([
      Container(
        decoration: BoxDecoration(border: Border.all(color: bp.lineSoft)),
        child: Column(
          children: [
            row(header: true, [
              Expanded(flex: 3, child: Eyebrow(l.infoLevel)),
              Expanded(flex: 2, child: Eyebrow(l.helpScoringTime)),
              Expanded(flex: 2, child: Eyebrow(l.helpScoringBaseCol)),
            ]),
            for (final level in Level.values)
              row(last: level == Level.values.last, [
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: Text(level.label(l), style: levelName),
                  ),
                ),
                Expanded(flex: 2, child: Text('${level.seconds}s', style: t.bodyMedium)),
                Expanded(flex: 2, child: Text(l.pointsShort(level.basePoints), style: t.bodyMedium)),
              ]),
          ],
        ),
      ),
      const SizedBox(height: 12),
      _Bullet(l.helpScoringBase),
      _Bullet(l.helpScoringBonus),
      _Bullet(
        l.helpScoringExample(
          Level.intermediate.basePoints,
          30,
          Level.intermediate.pointsFor(secondsLeft: 30, inTime: true),
        ),
      ),
      _Bullet(l.helpScoringHints),
      _Bullet(l.helpScoringBlind),
      _Bullet(l.helpScoringStreak),
      _Bullet(l.helpScoringLate),
      _Bullet(l.helpScoringReplay),
      _Bullet(l.helpScoringPractice),
      _Bullet(l.helpScoringPause(Level.pauseSeconds)),
    ]);
  }
}
