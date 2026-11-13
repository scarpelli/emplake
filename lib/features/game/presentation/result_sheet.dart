import 'package:flutter/material.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';
import '../../../core/widgets/bp_widgets.dart';
import '../../help/help_dialog.dart';
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
    this.stars,
    this.runRecord,
    this.runBest,
  });

  final GameState state;
  final VoidCallback onMenu;
  final VoidCallback onNext;

  final VoidCallback? onShare;

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
    final sc = state.score;
    final String breakdown;
    if (state.practice) {
      breakdown = l.practiceNoPoints;
    } else if (state.pointsEarned > 0) {
      breakdown = [
        l.pointsBreakdown(sc.base, sc.timeBonus),
        if (sc.hints > 0) l.scoreHints(sc.hints, (sc.hintFactor * 100).round()),
        if (sc.blind) l.scoreBlind,
        if (sc.streak > 0) l.scoreStreak(sc.streak, ((sc.streakFactor - 1) * 100).round()),
      ].join(' · ');
    } else {
      breakdown = !inTime ? l.pointsLateZero : l.pointsReplayZero;
    }

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
        decoration: BoxDecoration(
          border: Border(top: BorderSide(color: bp.line)),
        ),
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
                            ? l.revealedDetail(state.number)
                            : (inTime ? l.resultTrueDetail(value, state.elapsed) : l.resultLateDetail(value)),
                        style: t.bodySmall?.copyWith(color: bp.muted),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            FormulaPanel(tokens: linearTokens(state.board), latex: latexOf(state.board), compact: true),
            if (stars != null && !revealed) ...[
              const SizedBox(height: 12),
              Semantics(
                label: l.adventureStarsEarned(stars!),
                excludeSemantics: true,
                child: Row(
                  children: [
                    Text(
                      '${'★' * stars!}${'☆' * (3 - stars!)}',
                      style: t.headlineSmall?.copyWith(color: accent, letterSpacing: 4),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(l.adventureStarsRule, style: t.bodySmall?.copyWith(color: bp.muted)),
                    ),
                  ],
                ),
              ),
            ],
            if (!revealed) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  _Stat(label: l.points, value: '+${state.pointsEarned}'),
                  const SizedBox(width: 8),
                  _Stat(label: l.total, value: state.totalPoints?.toString() ?? '—'),
                ],
              ),
              const SizedBox(height: 6),
              InkWell(
                onTap: () => showHelpDialog(context, scoring: true),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 16, color: bp.muted),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(breakdown, style: t.bodySmall?.copyWith(color: bp.muted)),
                      ),
                      Text(
                        l.howScoringWorks,
                        style: t.bodySmall?.copyWith(color: bp.ink, decoration: TextDecoration.underline),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            if (!revealed && saved.$2.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  if (state.saveStatus == SaveStatus.saving)
                    const SizedBox(width: 18, height: 18, child: BpLoader(size: 16))
                  else
                    Icon(saved.$1, size: 18, color: state.saveStatus == SaveStatus.failed ? bp.danger : bp.muted),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(saved.$2, style: t.bodySmall?.copyWith(color: bp.muted)),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onMenu,
                    child: Text(state.mode == GameMode.adventure ? l.adventureTrail : l.menu),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 2,
                  child: onShare != null
                      ? FilledButton.icon(
                          icon: const Icon(Icons.content_copy, size: 18),
                          onPressed: onShare,
                          label: Text(l.dailyCopy),
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
