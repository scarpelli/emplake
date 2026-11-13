import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';
import '../application/game_controller.dart';
import '../domain/board.dart';
import '../domain/evaluator.dart';
import '../domain/expr.dart';
import '../domain/number_value.dart';

const equalsNodeId = -1;

enum TreeNodeKind { leaf, op, equals, gap }

class PlacedNode {
  const PlacedNode({
    required this.id,
    required this.kind,
    required this.label,
    required this.x,
    required this.row,
    this.children = const [],
    this.flySymbol,
    this.digitGap,
  });

  final int id;
  final TreeNodeKind kind;
  final String label;
  final double x;
  final int row;
  final List<int> children;

  final Object? flySymbol;

  final int? digitGap;
}

class TreeLayout {
  TreeLayout(this.nodes, this.rows);

  final Map<int, PlacedNode> nodes;
  final int rows;

  static int gapId(int gap) => -100 - gap;

  factory TreeLayout.of(Board board) {
    final nodes = <int, PlacedNode>{};
    var maxRow = 0;

    (double, int) place(Node n) {
      switch (n) {
        case Leaf(:final digit, :final index):
          final x = index + 0.5;
          nodes[n.id] = PlacedNode(
            id: n.id,
            kind: TreeNodeKind.leaf,
            label: n.parens ? '($digit)' : '$digit',
            x: x,
            row: 0,
          );
          return (x, 0);
        case Binary(:final op, :final left, :final right):
          final (lx, lr) = place(left);
          final (rx, rr) = place(right);
          final x = (lx + rx) / 2;
          final row = math.max(lr, rr) + 1;
          maxRow = math.max(maxRow, row);
          nodes[n.id] = PlacedNode(
            id: n.id,
            kind: TreeNodeKind.op,
            label: n.parens ? '(${op.symbol})' : op.symbol,
            x: x,
            row: row,
            children: [left.id, right.id],
            flySymbol: op,
            digitGap: n.digitGap,
          );
          return (x, row);
        case Unary(:final op, :final child):
          final (cx, cr) = place(child);
          final row = cr + 1;
          maxRow = math.max(maxRow, row);
          final symbol = switch (op) {
            UnOp.abs => '|x|',
            UnOp.floor => '⌊x⌋',
            UnOp.ceil => '⌈x⌉',
            _ => op.symbol,
          };
          nodes[n.id] = PlacedNode(
            id: n.id,
            kind: TreeNodeKind.op,
            label: n.parens ? '($symbol)' : symbol,
            x: cx,
            row: row,
            children: [child.id],
            flySymbol: op,
          );
          return (cx, row);
      }
    }

    final rootX = <double>[];
    for (final b in board.blocks) {
      rootX.add(place(b).$1);
    }

    var leafCount = 0;
    for (var g = 0; g < board.blocks.length - 1; g++) {
      leafCount += board.blocks[g].descendants.whereType<Leaf>().length;
      if (g == board.eqGap) continue;
      nodes[gapId(g)] = PlacedNode(
        id: gapId(g),
        kind: TreeNodeKind.gap,
        label: '',
        x: leafCount.toDouble(),
        row: 0,
        digitGap: leafCount - 1,
      );
    }

    var rows = maxRow;
    final eq = board.eqGap;
    if (eq != null) {
      rows = maxRow + 1;
      nodes[equalsNodeId] = PlacedNode(
        id: equalsNodeId,
        kind: TreeNodeKind.equals,
        label: '=',
        x: (rootX[eq] + rootX[eq + 1]) / 2,
        row: rows,
        children: [board.blocks[eq].id, board.blocks[eq + 1].id],
        flySymbol: '=',
        digitGap: board.eqDigitGap,
      );
    }
    return TreeLayout(nodes, rows);
  }
}

class TreeView extends StatefulWidget {
  const TreeView({
    super.key,
    required this.state,
    required this.onTapNode,
    required this.onTapGap,
    this.onTapEquals,
    this.onDrop,
    this.canDrop,
    this.onDropOutside,
    this.showValues = true,
    this.hintGaps = const {},
    this.geometry,
    this.emptyHint,
  });

  final GameState state;
  final ValueChanged<int> onTapNode;
  final ValueChanged<int> onTapGap;
  final VoidCallback? onTapEquals;

  final void Function(SignDrag drag, int digitGap)? onDrop;
  final bool Function(SignDrag drag, int digitGap)? canDrop;

  final ValueChanged<SignDrag>? onDropOutside;

  final bool showValues;

  final Set<int> hintGaps;

  final TreeGeometry? geometry;

  final String? emptyHint;

  @override
  State<TreeView> createState() => _TreeViewState();
}

class TreeGeometry {
  final _key = GlobalKey();
  Map<int, Offset> _local = {};
  Map<int, PlacedNode> _nodes = {};

  Offset? globalCenter(int id) {
    final box = _key.currentContext?.findRenderObject() as RenderBox?;
    final p = _local[id];
    if (box == null || p == null || !box.attached) return null;
    return box.localToGlobal(p);
  }

  Iterable<PlacedNode> get operatorNodes => _nodes.values.where((n) => n.flySymbol != null);
}

class _TreeViewState extends State<TreeView> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: 1,
  );
  late TreeLayout _layout = TreeLayout.of(widget.state.board);

  Map<int, Offset> _from = {};

  Map<int, Offset> _shown = {};
  late final _fallbackGeometry = TreeGeometry();

  TreeGeometry get _geometry => widget.geometry ?? _fallbackGeometry;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _c.duration = MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 420);
  }

  @override
  void didUpdateWidget(TreeView old) {
    super.didUpdateWidget(old);
    if (!identical(old.state.board, widget.state.board)) {
      _from = Map.of(_shown);
      _layout = TreeLayout.of(widget.state.board);
      _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  Map<int, Offset> _targets(Size size) {
    const padX = 8.0, padTop = 28.0, padBottom = 26.0;
    final rows = math.max(_layout.rows, 3);
    final rowH = math.min(size.width > 600 ? 96.0 : 64.0, (size.height - padTop - padBottom) / rows);
    final colW = (size.width - 2 * padX) / 4;
    return {
      for (final n in _layout.nodes.values) n.id: Offset(padX + n.x * colW, size.height - padBottom - n.row * rowH),
    };
  }

  Offset _start(int id, Map<int, Offset> targets) {
    final old = _from[id];
    if (old != null) return old;
    final n = _layout.nodes[id]!;
    if (n.children.isEmpty) return targets[id]!;
    final kids = [for (final c in n.children) _start(c, targets)];
    return kids.reduce((a, b) => a + b) / kids.length.toDouble();
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final state = widget.state;
    final eval = state.board.verdict(state.level);
    final selection = state.selection;
    final errorId = eval.result.error?.nodeId;
    final sep = Localizations.localeOf(context).languageCode == 'en' ? '.' : ',';

    final parentOf = <int, PlacedNode>{
      for (final p in _layout.nodes.values)
        for (final c in p.children) c: p,
    };
    final valueStyle = Theme.of(context).textTheme.labelSmall;

    return LayoutBuilder(
      builder: (context, constraints) {
        final targets = _targets(constraints.biggest);
        final width = constraints.biggest.width;

        return AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final t = Curves.easeOutCubic.transform(_c.value);
            final pos = {for (final e in targets.entries) e.key: Offset.lerp(_start(e.key, targets), e.value, t)!};
            _shown = pos;
            _geometry
              .._local = pos
              .._nodes = _layout.nodes;

            return Stack(
              key: _geometry._key,
              clipBehavior: Clip.none,
              children: [
                if (widget.emptyHint != null && state.board.linksMade == 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 8,
                    child: Text(
                      widget.emptyHint!,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: bp.faint, height: 1.5),
                    ),
                  ),
                Positioned.fill(child: CustomPaint(painter: _EdgePainter(_layout, pos, bp.ink))),
                for (final n in _layout.nodes.values)
                  _positioned(
                    pos[n.id]!,
                    Opacity(
                      opacity: _from.isEmpty || _from.containsKey(n.id) ? 1 : t,
                      child: _interactiveNode(
                        n,
                        selected: switch (selection) {
                          GapSelection(:final gap) => n.kind == TreeNodeKind.gap && n.id == TreeLayout.gapId(gap),
                          NodeSelection(:final nodeId) => n.id == nodeId,
                          EqualsSelection() => n.kind == TreeNodeKind.equals,
                          null => false,
                        },
                        error: n.id == errorId,
                      ),
                    ),
                  ),
                for (final n in _layout.nodes.values)
                  if (widget.showValues && n.kind == TreeNodeKind.op && eval.result.values[n.id] != null)
                    _valueLabel(
                      at: pos[n.id]!,
                      gap: _NodeChip.halfWidth(context, n) + 6,
                      onLeft: (parentOf[n.id]?.x ?? n.x) > n.x,
                      width: width,
                      value: eval.result.values[n.id]!.display(decimalSeparator: sep),
                      style: valueStyle?.copyWith(color: selection == NodeSelection(n.id) ? bp.accent : bp.muted),
                    ),
                if (widget.showValues && pos[equalsNodeId] != null)
                  _equalsVerdict(context, pos[equalsNodeId]!, eval, sep),
              ],
            );
          },
        );
      },
    );
  }

  bool get _editable => widget.state.phase == GamePhase.playing && !widget.state.paused;

  SignDrag? _dragOf(PlacedNode n) {
    final gap = n.digitGap;
    if (gap == null || widget.onDrop == null) return null;
    return switch (n.kind) {
      TreeNodeKind.op => MoveBinaryDrag(n.id, gap),
      TreeNodeKind.equals => MoveEqualsDrag(gap),
      _ => null,
    };
  }

  Widget _interactiveNode(PlacedNode n, {required bool selected, required bool error}) {
    final hinted = n.digitGap != null && widget.hintGaps.contains(n.digitGap);
    Widget chip({bool hover = false}) => _NodeChip(
      node: n,
      hint: hinted,
      selected: selected,
      hover: hover,
      error: error,
      onTap: () {
        switch (n.kind) {
          case TreeNodeKind.gap:
            widget.onTapGap(-100 - n.id);
          case TreeNodeKind.equals:
            widget.onTapEquals?.call();
          case TreeNodeKind.leaf || TreeNodeKind.op:
            widget.onTapNode(n.id);
        }
      },
    );

    Widget withDrag({bool hover = false}) {
      final drag = _editable ? _dragOf(n) : null;
      if (drag == null) return chip(hover: hover);
      return SignDraggable(
        data: drag,
        feedback: _NodeChip(node: n, selected: true, error: false, onTap: () {}),
        onCanceledAt: (global) {
          final box = context.findRenderObject() as RenderBox?;
          if (box == null || !box.attached) return;
          final inside = (Offset.zero & box.size).contains(box.globalToLocal(global));
          if (!inside) widget.onDropOutside?.call(drag);
        },
        childWhenDragging: Opacity(opacity: 0.3, child: chip()),
        child: chip(hover: hover),
      );
    }

    final gap = n.digitGap;
    if (gap == null || widget.onDrop == null) return withDrag();
    return DragTarget<SignDrag>(
      onWillAcceptWithDetails: (d) => _editable && (widget.canDrop?.call(d.data, gap) ?? true),
      onAcceptWithDetails: (d) => widget.onDrop!(d.data, gap),
      builder: (context, candidates, _) => withDrag(hover: candidates.isNotEmpty),
    );
  }

  Widget _positioned(Offset center, Widget child) => Positioned(
    left: center.dx - 60,
    top: center.dy - 24,
    width: 120,
    height: 48,
    child: Center(child: child),
  );

  Widget _valueLabel({
    required Offset at,
    required double gap,
    required bool onLeft,
    required double width,
    required String value,
    required TextStyle? style,
  }) {
    final label = IgnorePointer(
      child: Text(onLeft ? '$value ←' : '→ $value', maxLines: 1, softWrap: false, style: style),
    );
    return onLeft
        ? Positioned(right: width - at.dx + gap, top: at.dy - 26, child: label)
        : Positioned(left: at.dx + gap, top: at.dy - 26, child: label);
  }

  Widget _equalsVerdict(BuildContext context, Offset at, Verdict v, String sep) {
    final bp = context.bp;
    final board = widget.state.board;
    final eq = board.eqGap!;
    final values = v.result.values;
    final NumValue? l = values[board.blocks[eq].id];
    final NumValue? r = values[board.blocks[eq + 1].id];
    if (l == null || r == null) return const SizedBox.shrink();
    final complete = board.isComplete;
    final equal = l.equals(r);
    final text =
        '${l.display(decimalSeparator: sep)} ${equal ? '=' : '≠'} ${r.display(decimalSeparator: sep)}'
        '${complete && equal ? ' ✓' : ''}';
    return Positioned(
      left: at.dx + 24,
      top: at.dy - 9,
      child: IgnorePointer(
        child: Text(
          text,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: !complete ? bp.muted : (equal ? bp.ok : bp.danger), fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

class _EdgePainter extends CustomPainter {
  _EdgePainter(this.layout, this.pos, this.color);

  final TreeLayout layout;
  final Map<int, Offset> pos;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.4
      ..style = PaintingStyle.stroke;
    for (final n in layout.nodes.values) {
      final p = pos[n.id];
      if (p == null) continue;
      for (final c in n.children) {
        final q = pos[c];
        if (q != null) canvas.drawLine(p, q, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_EdgePainter old) => true;
}

class _NodeChip extends StatelessWidget {
  const _NodeChip({
    required this.node,
    required this.selected,
    required this.error,
    required this.onTap,
    this.hover = false,
    this.hint = false,
  });

  final PlacedNode node;
  final bool selected;

  final bool hint;

  final bool hover;
  final bool error;
  final VoidCallback onTap;

  static bool _isLong(PlacedNode n) => n.label.length > 2;

  static double halfWidth(BuildContext context, PlacedNode n) {
    if (!_isLong(n)) return 18;
    final painter = TextPainter(
      text: TextSpan(
        text: n.label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
      ),
      textDirection: TextDirection.ltr,
      textScaler: MediaQuery.textScalerOf(context),
      maxLines: 1,
    )..layout();
    final w = painter.width + 16 + 2.8;
    painter.dispose();
    return math.max(36, w) / 2;
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final lit = selected || hover;
    final fill = lit ? bp.accent : (error ? bp.danger : bp.paper);
    final fg = lit ? bp.onAccent : (error ? bp.paper : bp.ink);
    final border = error ? bp.danger : (lit ? bp.accent : bp.ink);

    final Widget shape;
    switch (node.kind) {
      case TreeNodeKind.leaf:
        shape = Container(
          constraints: const BoxConstraints(minWidth: 34),
          height: 34,
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: border, width: 1.4),
          ),
          alignment: Alignment.center,
          child: Text(
            node.label,
            maxLines: 1,
            softWrap: false,
            style: t.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
        );
      case TreeNodeKind.op:
      case TreeNodeKind.equals:
        final long = _isLong(node);
        shape = Container(
          width: long ? null : 36,
          height: 36,
          constraints: const BoxConstraints(minWidth: 36),
          padding: EdgeInsets.symmetric(horizontal: long ? 8 : 0),
          decoration: BoxDecoration(
            color: fill,
            border: Border.all(color: border, width: 1.4),
            borderRadius: BorderRadius.circular(18),
          ),
          alignment: Alignment.center,
          child: Text(
            node.label,
            maxLines: 1,
            softWrap: false,
            style: (long ? t.labelMedium : t.titleMedium)?.copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
        );
      case TreeNodeKind.gap:
        shape = CustomPaint(
          painter: _DashedBoxPainter(lit ? bp.accent : bp.line, filled: lit ? bp.accent : null),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: hover ? 30 : 22,
            height: hover ? 30 : 22,
            child: Icon(Icons.add, size: 14, color: lit ? bp.onAccent : bp.muted),
          ),
        );
    }

    return Semantics(
      button: true,
      selected: selected,
      label: node.kind == TreeNodeKind.gap ? context.l10n.gapLabel(-100 - node.id + 1) : node.label,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(node.kind == TreeNodeKind.gap ? 11 : 6),
            child: hint ? _HintPulse(child: shape) : shape,
          ),
        ),
      ),
    );
  }
}

class _DashedBoxPainter extends CustomPainter {
  _DashedBoxPainter(this.color, {this.filled});
  final Color color;
  final Color? filled;

  @override
  void paint(Canvas canvas, Size size) {
    final r = Offset.zero & size;
    if (filled != null) canvas.drawRect(r, Paint()..color = filled!);
    final p = Paint()
      ..color = color
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;
    final path = Path()..addRect(r);
    for (final m in path.computeMetrics()) {
      for (double d = 0; d < m.length; d += 6) {
        canvas.drawPath(m.extractPath(d, math.min(d + 3, m.length)), p);
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBoxPainter old) => old.color != color || old.filled != filled;
}

class SignDraggable extends StatelessWidget {
  const SignDraggable({
    super.key,
    required this.data,
    required this.feedback,
    required this.child,
    this.childWhenDragging,
    this.onCanceledAt,
  });

  final SignDrag data;
  final Widget feedback;
  final Widget child;
  final Widget? childWhenDragging;

  final ValueChanged<Offset>? onCanceledAt;

  static bool get _touch =>
      defaultTargetPlatform == TargetPlatform.android || defaultTargetPlatform == TargetPlatform.iOS;

  @override
  Widget build(BuildContext context) {
    final lifted = Transform.translate(
      offset: _touch ? const Offset(-22, -64) : const Offset(-22, -22),
      child: Material(type: MaterialType.transparency, child: feedback),
    );
    void canceled(Velocity _, Offset at) => onCanceledAt?.call(at);
    return _touch
        ? LongPressDraggable<SignDrag>(
            data: data,
            delay: const Duration(milliseconds: 220),
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: lifted,
            childWhenDragging: childWhenDragging,
            onDraggableCanceled: canceled,
            child: child,
          )
        : Draggable<SignDrag>(
            data: data,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: lifted,
            childWhenDragging: childWhenDragging,
            onDraggableCanceled: canceled,
            child: child,
          );
  }
}

class PausedVeil extends StatelessWidget {
  const PausedVeil({super.key, required this.paused, required this.child});
  final bool paused;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(end: paused ? 8 : 0),
    duration: const Duration(milliseconds: 250),
    builder: (context, sigma, child) => sigma < 0.1
        ? child!
        : ImageFiltered(
            imageFilter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
            child: child,
          ),
    child: child,
  );
}

class _HintPulse extends StatefulWidget {
  const _HintPulse({required this.child});
  final Widget child;

  @override
  State<_HintPulse> createState() => _HintPulseState();
}

class _HintPulseState extends State<_HintPulse> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c
        ..stop()
        ..value = 1;
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = context.bp.accent;
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => DecoratedBox(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: accent.withValues(alpha: 0.35 + 0.4 * _c.value),
              blurRadius: 6 + 6 * _c.value,
              spreadRadius: 2,
            ),
          ],
        ),
        child: child,
      ),
      child: widget.child,
    );
  }
}
