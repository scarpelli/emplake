import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../game/application/game_controller.dart';
import '../game/domain/expr.dart';
import '../game/domain/level.dart';
import '../game/domain/solution_codec.dart';
import '../game/presentation/tree_view.dart';

enum HelpTab { play, operators, scoring }

/// Below this width the help slides up as a bottom sheet; above it, it pops
/// up as a centred dialog growing out of the help button.
const _compactWidth = 600.0;

/// Opens the help over the current screen. The game clock is held while it
/// is open, so reading the rules mid-plate costs no time.
Future<void> showHelp(BuildContext context, {HelpTab tab = HelpTab.play}) {
  final game = ProviderScope.containerOf(context, listen: false).read(gameControllerProvider.notifier);
  return game.whileHeld(
    () => showGeneralDialog<void>(
      context: context,
      barrierDismissible: true,
      barrierLabel: context.l10n.close,
      barrierColor: Colors.black.withValues(alpha: 0.45),
      transitionDuration: const Duration(milliseconds: 340),
      pageBuilder: (_, _, _) => _HelpSheet(initialTab: tab.index),
      transitionBuilder: (context, animation, _, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        if (MediaQuery.sizeOf(context).width < _compactWidth) {
          return SlideTransition(
            position: Tween(begin: const Offset(0, 1), end: Offset.zero).animate(curved),
            child: child,
          );
        }
        // Grows out of the help button, the last item of the navigation bar.
        return FadeTransition(
          opacity: curved,
          child: ScaleTransition(
            alignment: const Alignment(0.8, 1),
            scale: Tween(begin: 0.6, end: 1.0).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

class _HelpSheet extends StatefulWidget {
  const _HelpSheet({required this.initialTab});

  final int initialTab;

  @override
  State<_HelpSheet> createState() => _HelpSheetState();
}

class _HelpSheetState extends State<_HelpSheet> {
  double _drag = 0;

  void _onDragEnd(DragEndDetails d) {
    if (_drag > 120 || (d.primaryVelocity ?? 0) > 700) {
      Navigator.of(context).pop();
    } else {
      setState(() => _drag = 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final size = MediaQuery.sizeOf(context);
    final compact = size.width < _compactWidth;

    final header = Padding(
      padding: EdgeInsets.fromLTRB(20, compact ? 4 : 16, 8, 8),
      child: PageTitle(
        eyebrow: l.navHelp.toUpperCase(),
        title: l.helpPageTitle,
        trailing: IconButton(
          icon: const Icon(Icons.close),
          tooltip: l.close,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (compact)
          // Drag handle: pulling the sheet down closes it.
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragUpdate: (d) => setState(() => _drag = math.max(0, _drag + d.delta.dy)),
            onVerticalDragEnd: _onDragEnd,
            child: Column(
              children: [
                const SizedBox(height: 10),
                Container(width: 40, height: 4, color: bp.lineSoft),
                header,
              ],
            ),
          )
        else
          header,
        Expanded(child: HelpContent(initialTab: widget.initialTab)),
        Container(
          padding: EdgeInsets.fromLTRB(20, 10, 20, 12 + (compact ? MediaQuery.paddingOf(context).bottom : 0)),
          decoration: BoxDecoration(
            border: Border(top: BorderSide(color: bp.lineSoft)),
          ),
          alignment: Alignment.centerRight,
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l.helpGotIt),
          ),
        ),
      ],
    );

    final panel = Semantics(
      scopesRoute: true,
      namesRoute: true,
      explicitChildNodes: true,
      label: l.helpPageTitle,
      child: Material(
        type: MaterialType.transparency,
        child: Container(
          decoration: BoxDecoration(
            border: compact ? Border(top: BorderSide(color: bp.line)) : Border.all(color: bp.line),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.18), blurRadius: 24, offset: const Offset(0, 8))],
          ),
          child: GridBackground(child: body),
        ),
      ),
    );

    if (compact) {
      return Align(
        alignment: Alignment.bottomCenter,
        child: AnimatedContainer(
          duration: Duration(milliseconds: _drag == 0 ? 200 : 0),
          curve: Curves.easeOut,
          transform: Matrix4.translationValues(0, _drag, 0),
          height: size.height * 0.88,
          width: double.infinity,
          child: panel,
        ),
      );
    }
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SizedBox(
            width: 640,
            height: math.min(size.height * 0.82, 760),
            child: panel,
          ),
        ),
      ),
    );
  }
}

/// The three help tabs (how to play, operators, scoring).
class HelpContent extends StatelessWidget {
  const HelpContent({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;

    return DefaultTabController(
      length: 3,
      initialIndex: initialTab,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
          const Expanded(child: TabBarView(children: [_PlayTab(), _OperatorsTab(), _ScoringTab()])),
        ],
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
      _Bullet('${l.modeAdventure}: ${l.adventureStarsRule}'),
    ]);
  }
}
