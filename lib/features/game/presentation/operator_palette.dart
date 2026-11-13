import 'package:flutter/material.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';
import '../../../core/widgets/bp_widgets.dart';
import '../application/game_controller.dart';
import '../domain/expr.dart';
import 'tree_view.dart';

class PaletteKeys {
  final _keys = <Object, GlobalKey>{};
  GlobalKey of(Object symbol) => _keys.putIfAbsent(symbol, GlobalKey.new);

  Offset? globalCenter(Object symbol) {
    final box = _keys[symbol]?.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }
}

class OperatorPalette extends StatelessWidget {
  const OperatorPalette({
    super.key,
    required this.state,
    required this.keys,
    required this.onBinary,
    required this.onEquals,
    required this.onUnary,
    required this.onParens,
    required this.onRemove,
  });

  final GameState state;
  final PaletteKeys keys;
  final ValueChanged<BinOp> onBinary;
  final VoidCallback onEquals;
  final ValueChanged<UnOp> onUnary;
  final VoidCallback onParens;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final board = state.board;
    final sel = state.selection;
    final playing = state.phase == GamePhase.playing && !state.paused;
    final node = sel is NodeSelection ? board.find(sel.nodeId) : null;
    final gap = sel is GapSelection ? sel.gap : null;

    final canLinkGap = playing && gap != null && board.canLink(gap);
    final canEquals = playing && gap != null && board.canPlaceEquals(gap);
    final binaryNode = playing && node is Binary ? node : null;
    final nodeSelected = playing && node != null;
    final carried = sel is CarrySelection ? sel : null;

    final betweenHint = switch (sel) {
      GapSelection() => l.paletteGapSelected,
      CarrySelection(:final op) => l.paletteCarrying(op?.label ?? '='),
      EqualsSelection() => l.paletteNodeSelected('='),
      NodeSelection() when node != null => l.paletteNodeSelected(TreeLayout.of(board).nodes[node.id]?.label ?? ''),
      _ => l.paletteTapGap,
    };
    final rules = state.rules;
    final binaryOps = [
      for (final op in BinOp.values)
        if (state.level.binary.contains(op)) op,
    ];
    final unaryOps = [
      for (final op in UnOp.values)
        if (state.level.unary.contains(op)) op,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Eyebrow(
          '${l.paletteBetween} · $betweenHint',
          opacity: canLinkGap || canEquals || binaryNode != null || carried != null ? 0.75 : 0.5,
        ),
        const SizedBox(height: 8),
        _Grid(
          columns: binaryOps.length + 1,
          children: [
            for (final op in binaryOps)
              _dragWhenPlaying(
                playing && rules.binary.contains(op),
                PaletteBinaryDrag(op),
                op.label,
                _OpButton(
                  key: keys.of(op),
                  label: op.label,
                  tooltip: rules.binary.contains(op)
                      ? '${op.name(l)} · ${op.example(context.decimalSeparator)}'
                      : l.ruleShortForbid(op.label),
                  enabled: playing && rules.binary.contains(op),
                  struck: !rules.binary.contains(op),
                  active: binaryNode?.op == op || carried?.op == op,
                  onTap: () => onBinary(op),
                ),
              ),
            _dragWhenPlaying(
              playing,
              const PaletteEqualsDrag(),
              '=',
              _OpButton(
                key: keys.of('='),
                label: '=',
                tooltip: '=',
                enabled: playing,
                active: carried?.isEquals ?? false,
                onTap: onEquals,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Eyebrow('${l.paletteOver} · ${l.paletteTapNode}', opacity: nodeSelected ? 0.75 : 0.45),
        const SizedBox(height: 8),
        _Grid(
          columns: 5,
          dashed: true,
          children: [
            for (final op in unaryOps)
              _OpButton(
                key: keys.of(op),
                label: op.label,
                tooltip: rules.unary.contains(op)
                    ? '${op.name(l)} · ${op.example(context.decimalSeparator)}'
                    : l.ruleShortForbid(op.label),
                enabled: nodeSelected && rules.unary.contains(op),
                struck: !rules.unary.contains(op),
                active: false,
                dashed: true,
                onTap: () => onUnary(op),
              ),
            _OpButton(
              label: '( )',
              tooltip: l.toggleParens,
              enabled: nodeSelected,
              active: node?.parens ?? false,
              dashed: true,
              onTap: onParens,
            ),
            _OpButton(
              icon: Icons.backspace_outlined,
              tooltip: l.removeOperator,
              enabled: playing && (node is Unary || node is Binary || (sel is EqualsSelection && board.eqGap != null)),
              active: false,
              dashed: true,
              onTap: onRemove,
            ),
          ],
        ),
      ],
    );
  }
}

Widget _dragWhenPlaying(bool playing, SignDrag drag, String label, Widget button) {
  if (!playing) return button;
  return SignDraggable(data: drag, feedback: _DragBubble(label), child: button);
}

class _DragBubble extends StatelessWidget {
  const _DragBubble(this.label);
  final String label;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bp.accent,
        shape: BoxShape.circle,
        border: Border.all(color: bp.accent),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(color: bp.onAccent, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _Grid extends StatelessWidget {
  const _Grid({required this.columns, required this.children, this.dashed = false});
  final int columns;
  final List<Widget> children;
  final bool dashed;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      const gap = 6.0;
      final cols = columns.clamp(1, 7);
      final w = (c.maxWidth - gap * (cols - 1)) / cols;
      return Wrap(
        spacing: gap,
        runSpacing: gap,
        children: [for (final child in children) SizedBox(width: w, height: dashed ? 40 : 44, child: child)],
      );
    },
  );
}

class _OpButton extends StatelessWidget {
  const _OpButton({
    super.key,
    this.label,
    this.icon,
    required this.tooltip,
    required this.enabled,
    required this.active,
    required this.onTap,
    this.dashed = false,
    this.struck = false,
  });

  final String? label;
  final IconData? icon;
  final String tooltip;
  final bool enabled;
  final bool active;
  final bool dashed;

  final bool struck;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final fg = active ? bp.onInk : bp.ink;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        selected: active,
        label: tooltip,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 150),
          opacity: enabled || active ? 1 : 0.35,
          child: Material(
            color: active ? bp.ink : Colors.transparent,
            child: InkWell(
              onTap: enabled ? onTap : null,
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(border: Border.all(color: bp.ink.withValues(alpha: 0.7))),
                child: icon != null
                    ? Icon(icon, size: 18, color: fg)
                    : Text(
                        label!,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w600,
                          decoration: struck ? TextDecoration.lineThrough : null,
                          decorationThickness: 2,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
