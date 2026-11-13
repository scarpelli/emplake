import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';
import '../domain/format.dart';

class FormulaPanel extends StatefulWidget {
  const FormulaPanel({
    super.key,
    required this.tokens,
    required this.latex,
    this.highlightNodeId,
    this.compact = false,
    this.open,
    this.onOpenChanged,
  });

  final List<FormulaToken> tokens;
  final String latex;
  final int? highlightNodeId;
  final bool compact;

  final bool? open;
  final ValueChanged<bool>? onOpenChanged;

  @override
  State<FormulaPanel> createState() => _FormulaPanelState();
}

class _FormulaPanelState extends State<FormulaPanel> {
  bool _localOpen = false;
  bool _copied = false;

  bool get _open => widget.open ?? _localOpen;

  void _toggle() {
    final next = !_open;
    if (widget.onOpenChanged != null) {
      widget.onOpenChanged!(next);
    } else {
      setState(() => _localOpen = next);
    }
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.latex));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1500));
    if (mounted) setState(() => _copied = false);
  }

  Widget rendered(BuildContext context) {
    final bp = context.bp;
    return Container(
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: bp.lineSoft)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: widget.compact ? 8 : 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Center(
          child: Math.tex(
            widget.latex,
            mathStyle: MathStyle.display,
            textStyle: TextStyle(fontSize: widget.compact ? 18 : 22, color: bp.ink),
            onErrorFallback: (e) => Text(widget.latex, style: Theme.of(context).textTheme.bodySmall),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final base = t.titleMedium?.copyWith(color: bp.ink);

    return Container(
      decoration: BoxDecoration(
        color: bp.deep.withValues(alpha: 0.35),
        border: Border.all(color: bp.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
            child: Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Text.rich(
                      TextSpan(
                        children: [
                          for (final tok in widget.tokens)
                            TextSpan(
                              text: tok.text,
                              style: tok.nodeId != null && tok.nodeId == widget.highlightNodeId
                                  ? base?.copyWith(color: bp.accent, fontWeight: FontWeight.w700)
                                  : base,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Semantics(
                  button: true,
                  expanded: _open,
                  child: InkWell(
                    onTap: _toggle,
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.only(left: 10, right: 4),
                      decoration: BoxDecoration(border: Border.all(color: bp.line)),
                      child: Row(
                        children: [
                          Text(l.latex, style: t.labelSmall?.copyWith(letterSpacing: 1)),
                          Icon(_open ? Icons.expand_less : Icons.expand_more, size: 18),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (widget.compact) rendered(context),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            alignment: Alignment.topCenter,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (!widget.compact) rendered(context),
                      Container(
                        decoration: BoxDecoration(
                          border: Border(top: BorderSide(color: bp.lineSoft)),
                        ),
                        padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                        child: Row(
                          children: [
                            Expanded(
                              child: SelectableText(
                                widget.latex,
                                maxLines: 1,
                                style: t.bodySmall?.copyWith(color: bp.muted, fontFamily: 'monospace'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            OutlinedButton.icon(
                              style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
                              onPressed: _copy,
                              icon: Icon(_copied ? Icons.check : Icons.content_copy, size: 16),
                              label: Text(_copied ? l.copied : l.copy),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
