import 'package:flutter/material.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';
import '../../../core/widgets/bp_widgets.dart';
import '../application/game_controller.dart';
import '../domain/challenge.dart';
import '../domain/format.dart';
import 'formula_panel.dart';

class ResultSheet extends StatelessWidget {
  const ResultSheet({
    super.key,
    required this.state,
    required this.onMenu,
    required this.onNext,
    this.onShare,
    this.onCopy,
    this.stars,
    this.runRecord,
    this.runBest,
  });

  final GameState state;
  final VoidCallback onMenu;
  final VoidCallback onNext;

  /// Plate of the day: opens the share sheet (gets the button's context so
  /// the iPad popover can anchor to it) and copies the scoreboard.
  final void Function(BuildContext button)? onShare;
  final VoidCallback? onCopy;

  final int? stars;

  final bool? runRecord;
  final int? runBest;

  @override
  Widget build(BuildContext context) {
    if (state.run != null) {
      return _RunSheet(state: state, onMenu: onMenu, onNext: onNext, record: runRecord, best: runBest);
    }
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final sep = context.decimalSeparator;
    final v = state.verdict;
    final value = v.left?.display(decimalSeparator: sep) ?? '';
    final revealed = state.phase == GamePhase.revealed;
    final inTime = state.solvedInTime && !revealed;
    final accent = revealed ? bp.ink : (inTime ? bp.ok : bp.accent);
    final saveFailed = !revealed && state.saveStatus == SaveStatus.failed;

    return Material(
      color: bp.panel,
      elevation: 12,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: bp.line)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                  child: Icon(
                    revealed ? Icons.lightbulb_outline : (inTime ? Icons.check : Icons.hourglass_bottom),
                    color: bp.paper,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          revealed ? l.revealedTitle : (inTime ? l.resultTrue : l.resultLate),
                          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1, color: accent),
                        ),
                      ),
                      Text(
                        revealed
                            ? switch (state.mode) {
                                GameMode.adventure => l.revealedDetailAdventure,
                                GameMode.daily => l.revealedDetailDaily,
                                GameMode.random => l.revealedDetail(state.number),
                                _ => l.revealedDetailRetry,
                              }
                            : (inTime ? l.resultTrueDetail(value, state.elapsed) : l.resultLateDetail(value)),
                        style: t.bodySmall?.copyWith(color: bp.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FormulaPanel(tokens: linearTokens(state.board), latex: latexOf(state.board), compact: true),
            if (stars != null && !revealed) ...[
              const SizedBox(height: 16),
              Semantics(
                label: l.adventureStarsEarned(stars!),
                excludeSemantics: true,
                child: Text(
                  '${'★' * stars!}${'☆' * (3 - stars!)}',
                  textAlign: TextAlign.center,
                  style: t.headlineMedium?.copyWith(color: accent, letterSpacing: 8),
                ),
              ),
            ],
            if (!revealed) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _Stat(label: l.points, value: '+${state.pointsEarned}'),
                  const SizedBox(width: 10),
                  _Stat(label: l.total, value: state.totalPoints?.toString() ?? '—'),
                ],
              ),
            ],
            if (saveFailed) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.cloud_off_outlined, size: 18, color: bp.danger),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(l.saveError, style: t.bodySmall?.copyWith(color: bp.muted)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMenu,
                    child: Text(state.mode == GameMode.adventure ? l.adventureTrail : l.menu),
                  ),
                ),
                const SizedBox(width: 8),
                if (onCopy != null) ...[
                  BoxIconButton(icon: Icons.content_copy, tooltip: l.dailyCopy, onPressed: onCopy, size: 40),
                  const SizedBox(width: 8),
                ],
                Expanded(
                  flex: 2,
                  child: onShare != null
                      ? Builder(
                          builder: (button) => FilledButton.icon(
                            icon: const Icon(Icons.share, size: 18),
                            onPressed: () => onShare!(button),
                            label: Text(l.dailyShare),
                          ),
                        )
                      : FilledButton.icon(
                          iconAlignment: IconAlignment.end,
                          icon: const Icon(Icons.arrow_forward),
                          onPressed: onNext,
                          label: Text(state.mode == GameMode.adventure ? l.adventureNext : l.nextNumber),
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

class _RunSheet extends StatelessWidget {
  const _RunSheet({
    required this.state,
    required this.onMenu,
    required this.onNext,
    required this.record,
    required this.best,
  });

  final GameState state;
  final VoidCallback onMenu;
  final VoidCallback onNext;
  final bool? record;
  final int? best;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final run = state.run!;
    final clock = run.kind == ChallengeKind.clock;
    final solved = state.phase == GamePhase.solved;
    final climbed = solved && run.inStep == 0 && run.step > 0;

    final (IconData icon, Color color, String title, String detail) = run.over
        ? (
            Icons.flag_outlined,
            bp.accent,
            clock ? l.runOverClock : l.runOverLives,
            clock ? l.runScoreClock(run.solved) : l.runScoreStreak(run.solved),
          )
        : solved
        ? (
            Icons.check,
            bp.ok,
            l.runRight,
            climbed && clock ? l.runStepUp(run.step + 1, ChallengeRun.stepBonus) : l.runRightDetail,
          )
        : (Icons.heart_broken_outlined, bp.danger, l.runPlateLost, l.runPlateLostDetail);

    return Material(
      color: bp.panel,
      elevation: 12,
      child: Container(
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: bp.line)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
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
                  decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  child: Icon(icon, color: bp.paper),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        liveRegion: true,
                        child: Text(
                          title,
                          style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1, color: color),
                        ),
                      ),
                      Text(detail, style: t.bodySmall?.copyWith(color: bp.muted)),
                    ],
                  ),
                ),
              ],
            ),
            if (run.over) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _Stat(label: clock ? l.challengeRecord : l.challengeStreak, value: '${run.solved}'),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      record == true ? l.runNewRecord : (best == null ? '' : l.runBest(best!)),
                      textAlign: TextAlign.center,
                      style: t.titleSmall?.copyWith(
                        color: record == true ? bp.ok : bp.muted,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            if (!solved) ...[
              const SizedBox(height: 12),
              if (run.over) Text(l.runLastSolution, style: t.bodySmall?.copyWith(color: bp.muted)),
              FormulaPanel(tokens: linearTokens(state.board), latex: latexOf(state.board), compact: true),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(onPressed: onMenu, child: Text(l.menu)),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: FilledButton.icon(
                    iconAlignment: IconAlignment.end,
                    icon: Icon(run.over ? Icons.replay : Icons.arrow_forward),
                    onPressed: onNext,
                    label: Text(run.over ? l.runPlayAgain : l.runNextPlate),
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
