import 'package:flutter/material.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';
import '../application/catalog_provider.dart';
import '../domain/board.dart';
import '../domain/format.dart';
import '../domain/level.dart';
import '../domain/solver.dart';

class OtherSolutions extends ConsumerStatefulWidget {
  const OtherSolutions({super.key, required this.level, required this.board});

  final Level level;
  final Board board;

  static const shown = 5;

  @override
  ConsumerState<OtherSolutions> createState() => _OtherSolutionsState();
}

class _OtherSolutionsState extends ConsumerState<OtherSolutions> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final all = ref.watch(otherSolutionsProvider((widget.level, widget.board.number))).value;
    if (all == null) return const SizedBox.shrink();
    final mine = SolutionFinder.sameIdea(widget.board);
    final others = [
      for (final b in all)
        if (SolutionFinder.sameIdea(b) != mine) b,
    ];
    if (others.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        decoration: BoxDecoration(border: Border.all(color: bp.lineSoft)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Semantics(
              button: true,
              expanded: _open,
              child: InkWell(
                onTap: () => setState(() => _open = !_open),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(minHeight: 40),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 6, 6, 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            l.otherSolutions(others.length),
                            style: t.labelSmall?.copyWith(letterSpacing: 1, color: bp.muted),
                          ),
                        ),
                        Icon(_open ? Icons.expand_less : Icons.expand_more, size: 18, color: bp.muted),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 200),
              alignment: Alignment.topCenter,
              child: !_open
                  ? const SizedBox(width: double.infinity)
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        for (final b in others.take(OtherSolutions.shown))
                          Container(
                            decoration: BoxDecoration(
                              border: Border(top: BorderSide(color: bp.lineSoft)),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            child: Semantics(
                              label: linearText(b),
                              excludeSemantics: true,
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Math.tex(
                                  latexOf(b),
                                  textStyle: TextStyle(fontSize: 16, color: bp.ink),
                                  onErrorFallback: (_) => Text(linearText(b), style: t.bodyMedium),
                                ),
                              ),
                            ),
                          ),
                        if (others.length > OtherSolutions.shown)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(12, 2, 12, 8),
                            child: Text(
                              l.otherSolutionsMore(others.length - OtherSolutions.shown),
                              style: t.bodySmall?.copyWith(color: bp.muted),
                            ),
                          ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
