import 'package:flutter/material.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';
import '../../../core/widgets/bp_widgets.dart';
import '../application/game_controller.dart';
import '../domain/format.dart';
import 'formula_panel.dart';

class ResultSheet extends StatelessWidget {
  const ResultSheet({super.key, required this.state, required this.onMenu, required this.onNext});

  final GameState state;
  final VoidCallback onMenu;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final sep = context.decimalSeparator;
    final v = state.verdict;
    final value = v.left?.display(decimalSeparator: sep) ?? '';
    final inTime = state.solvedInTime;
    final accent = inTime ? bp.ok : bp.accent;

    final saved = switch (state.saveStatus) {
      SaveStatus.saving => (Icons.cloud_upload_outlined, l.saving),
      SaveStatus.savedNew when inTime => (Icons.cloud_done_outlined, l.savedSolved(state.number)),
      SaveStatus.savedNew => (Icons.cloud_done_outlined, l.savedCounts(state.number)),
      SaveStatus.savedReplay => (Icons.cloud_done_outlined, l.savedReplay(state.number)),
      SaveStatus.failed => (Icons.cloud_off_outlined, l.saveError),
      SaveStatus.none => (Icons.cloud_outlined, ''),
    };

    return Material(
      color: bp.panel,
      elevation: 12,
      child: Container(
        decoration: BoxDecoration(border: Border(top: BorderSide(color: bp.line))),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Container(width: 40, height: 4, color: bp.lineSoft)),
            const SizedBox(height: 14),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(shape: BoxShape.circle, color: accent),
                  child: Icon(inTime ? Icons.check : Icons.hourglass_bottom, color: bp.paper),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(inTime ? l.resultTrue : l.resultLate,
                          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1, color: accent)),
                      Text(
                        inTime ? l.resultTrueDetail(value, state.elapsed) : l.resultLateDetail(value),
                        style: t.bodySmall?.copyWith(color: bp.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FormulaPanel(tokens: linearTokens(state.board), latex: latexOf(state.board), compact: true),
            const SizedBox(height: 12),
            Row(
              children: [
                _Stat(label: l.points, value: '+${state.pointsEarned}'),
                const SizedBox(width: 8),
                _Stat(label: l.total, value: state.totalPoints?.toString() ?? '—'),
              ],
            ),
            if (saved.$2.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (state.saveStatus == SaveStatus.saving)
                    const SizedBox(width: 18, height: 18, child: BpLoader(size: 16))
                  else
                    Icon(saved.$1, size: 18, color: state.saveStatus == SaveStatus.failed ? bp.danger : bp.muted),
                  const SizedBox(width: 8),
                  Expanded(child: Text(saved.$2, style: t.bodySmall?.copyWith(color: bp.muted))),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: onMenu, child: Text(l.menu))),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    iconAlignment: IconAlignment.end,
                    icon: const Icon(Icons.arrow_forward),
                    onPressed: onNext,
                    label: Text(l.nextNumber),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(border: Border.all(color: bp.line)),
        child: Row(
          children: [
            Eyebrow(label),
            const Spacer(),
            Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
