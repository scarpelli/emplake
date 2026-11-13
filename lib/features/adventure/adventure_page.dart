import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/router.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../core/widgets/brand_home.dart';
import '../game/application/game_controller.dart';
import '../game/domain/adventure.dart';
import 'adventure_store.dart';

class AdventurePage extends ConsumerStatefulWidget {
  const AdventurePage({super.key});

  @override
  ConsumerState<AdventurePage> createState() => _AdventurePageState();
}

class _AdventurePageState extends ConsumerState<AdventurePage> {
  final _focusKey = GlobalKey(debugLabel: 'adventure-focus');
  bool _scrolled = false;

  void _play(Stage s) {
    if (!s.playable) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(context.l10n.adventureLockedStage)));
      return;
    }
    context.go(
      newGameLocation(mode: GameMode.adventure, level: s.entry.level, number: s.entry.number, stage: s.number),
    );
  }

  void _scrollToFocus() {
    if (_scrolled) return;
    _scrolled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = _focusKey.currentContext;
      if (ctx != null && ctx.mounted) {
        Scrollable.ensureVisible(ctx, alignment: 0.3, duration: const Duration(milliseconds: 300));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final async = ref.watch(adventureProgressProvider);
    final progress = async.value;

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 1000;
        final pad = wide ? const EdgeInsets.fromLTRB(28, 20, 28, 20) : const EdgeInsets.fromLTRB(16, 12, 16, 0);
        final header = ModeHeader(
          title: l.modeAdventure,
          trailing: progress == null
              ? null
              : Text('${progress.done} / ${progress.total}', style: t.titleMedium?.copyWith(letterSpacing: 1)),
        );
        if (progress == null) {
          return Padding(
            padding: pad,
            child: Column(
              children: [
                header,
                Expanded(
                  child: async.hasError
                      ? Center(
                          child: OutlinedButton(
                            onPressed: () => ref.invalidate(adventureStarsProvider),
                            child: Text(l.retry),
                          ),
                        )
                      : const Center(child: BpLoader()),
                ),
              ],
            ),
          );
        }
        _scrollToFocus();
        final focus = progress.focus;
        final intro = Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Wrap(
            spacing: 16,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Text(l.adventureStarsRule, style: t.bodySmall?.copyWith(color: bp.muted)),
              if (focus != null)
                FilledButton.icon(
                  onPressed: () => _play(focus),
                  icon: const Icon(Icons.play_arrow, size: 18),
                  label: Text(l.adventureContinue(focus.number)),
                )
              else if (progress.done == progress.total)
                Text(l.adventureAllDone, style: t.titleSmall?.copyWith(color: bp.ok)),
            ],
          ),
        );

        if (wide) {
          return Padding(
            padding: pad,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                header,
                intro,
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      for (var i = 0; i < progress.columns.length; i++) ...[
                        if (i > 0) const SizedBox(width: 24),
                        Expanded(
                          child: _ColumnPanel(
                            column: progress.columns[i],
                            focus: focus,
                            focusKey: _focusKey,
                            onTap: _play,
                            scrollable: true,
                            perRow: 3,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          );
        }
        final perRow = c.maxWidth >= 640 ? 6 : 3;
        return Padding(
          padding: pad,
          child: Column(
            children: [
              header,
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(bottom: 24),
                  children: [
                    intro,
                    for (final col in progress.columns) ...[
                      _ColumnPanel(
                        column: col,
                        focus: focus,
                        focusKey: _focusKey,
                        onTap: _play,
                        scrollable: false,
                        perRow: perRow,
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ColumnPanel extends StatelessWidget {
  const _ColumnPanel({
    required this.column,
    required this.focus,
    required this.focusKey,
    required this.onTap,
    required this.scrollable,
    required this.perRow,
  });

  final AdventureColumn column;
  final Stage? focus;
  final GlobalKey focusKey;
  final ValueChanged<Stage> onTap;
  final bool scrollable;
  final int perRow;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final level = column.level;
    final grid = GridView.builder(
      padding: const EdgeInsets.all(14),
      shrinkWrap: !scrollable,
      physics: scrollable ? null : const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: perRow,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: scrollable ? 0.7 : 0.85,
      ),
      itemCount: column.stages.length,
      itemBuilder: (context, i) {
        final s = column.stages[i];
        final isFocus = focus?.number == s.number;
        return _StageTile(key: isFocus ? focusKey : null, stage: s, onTap: () => onTap(s));
      },
    );
    return Container(
      decoration: BoxDecoration(border: Border.all(color: bp.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: scrollable ? MainAxisSize.max : MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: bp.line)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        level.label(l).toUpperCase(),
                        style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
                      ),
                    ),
                    Text('${column.done}/${column.total}', style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                  ],
                ),
                const SizedBox(height: 6),
                Semantics(
                  label: l.adventureOps,
                  child: Text(
                    level.operatorLabels.join(' '),
                    style: t.bodySmall?.copyWith(color: bp.muted, letterSpacing: 1),
                  ),
                ),
                if (!column.unlocked) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.lock_outline, size: 14, color: bp.faint),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          l.adventureLockedColumn(AdventureProgress.checkpoint),
                          style: t.bodySmall?.copyWith(color: bp.faint),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          if (scrollable) Expanded(child: grid) else grid,
        ],
      ),
    );
  }
}

class _StageTile extends StatelessWidget {
  const _StageTile({super.key, required this.stage, required this.onTap});

  final Stage stage;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final label = stage.number.toString().padLeft(2, '0');
    final done = stage.status == StageStatus.done;
    final current = stage.status == StageStatus.current;
    final locked = stage.status == StageStatus.locked;

    final Color fg = done ? bp.onInk : (current ? bp.accent : (locked ? bp.faint : bp.ink));
    final state = switch (stage.status) {
      StageStatus.done => '${l.adventureStateDone}, ${l.adventureStarsEarned(stage.stars)}',
      StageStatus.current => l.adventureCurrent,
      StageStatus.open => l.adventureStateOpen,
      StageStatus.locked => l.adventureStateLocked,
    };

    final content = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FittedBox(
          child: Text(
            label,
            style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700, color: fg),
          ),
        ),
        if (done)
          Text(
            '${'★' * stage.stars}${'☆' * (3 - stage.stars)}',
            style: t.labelMedium?.copyWith(color: fg, letterSpacing: 1),
          )
        else if (current)
          Text(l.adventureCurrent, style: t.labelSmall?.copyWith(color: fg)),
      ],
    );

    final Widget box = done
        ? Container(color: bp.ink, child: content)
        : current
        ? Container(
            decoration: BoxDecoration(border: Border.all(color: bp.accent, width: 2)),
            child: content,
          )
        : CustomPaint(
            painter: _DashedBorder(color: locked ? bp.lineSoft : bp.line),
            child: content,
          );

    return Semantics(
      button: true,
      label: l.adventureStageA11y(stage.number, stage.entry.number, state),
      excludeSemantics: true,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(onTap: onTap, child: box),
      ),
    );
  }
}

class _DashedBorder extends CustomPainter {
  const _DashedBorder({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    const dash = 5.0, gap = 4.0;
    void line(Offset a, Offset b) {
      final total = (b - a).distance;
      final dir = (b - a) / total;
      for (var d = 0.0; d < total; d += dash + gap) {
        canvas.drawLine(a + dir * d, a + dir * (d + dash < total ? d + dash : total), paint);
      }
    }

    final r = Offset.zero & size;
    final rect = r.deflate(0.5);
    line(rect.topLeft, rect.topRight);
    line(rect.topRight, rect.bottomRight);
    line(rect.bottomRight, rect.bottomLeft);
    line(rect.bottomLeft, rect.topLeft);
  }

  @override
  bool shouldRepaint(_DashedBorder old) => old.color != color;
}
