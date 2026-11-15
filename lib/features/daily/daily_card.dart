import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/router.dart';
import '../../core/theme/blueprint.dart';
import '../../data/firestore_repository.dart';
import '../../data/models.dart';
import '../game/application/catalog_provider.dart';
import '../game/application/game_controller.dart';
import '../game/domain/level.dart';
import 'daily.dart';
import 'daily_share.dart';

typedef DailyToday = ({String key, String number, Level level, DailyResult? result, DailyStats? stats});

/// Today's plate, the player's result and everyone's tally. Re-runs when the
/// profile is invalidated, which happens right after a plate is finished.
final dailyTodayProvider = FutureProvider<DailyToday>((ref) async {
  ref.watch(profileProvider);
  final key = Daily.keyFor(DateTime.now());
  final entry = Daily.entryFor(await ref.watch(catalogProvider.future), key);
  final repo = ref.watch(repositoryProvider);
  DailyResult? result;
  DailyStats? stats;
  if (repo != null) {
    try {
      result = await repo.dailyResult(key);
      stats = await repo.dailyStats(key);
    } catch (_) {
      // The card still works without the counts.
    }
  }
  return (key: key, number: entry.number, level: entry.level, result: result, stats: stats);
});

/// The plate of the day banner on the home screen: the four digits as a
/// plate, then either an invitation (how many already played) or, once done,
/// the time and how it compares, with a share button.
class DailyCard extends ConsumerWidget {
  const DailyCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final today = ref.watch(dailyTodayProvider).value;
    final result = today?.result;
    final done = result != null && result.finished;
    final stats = today?.stats;

    final String title;
    final String subtitle;
    if (!done) {
      title = l.modeDaily;
      final plays = stats?.plays ?? 0;
      subtitle = plays > 0 ? l.dailyPlayedToday(plays) : l.dailyBeFirst;
    } else if (result.solved) {
      title = l.dailyDoneIn(Daily.formatSeconds(result.seconds));
      final better = stats?.betterThan(result.seconds);
      subtitle = better != null ? l.dailyBetterThan(better) : l.dailyFirstToday;
    } else {
      title = l.dailyMissedTitle;
      subtitle = l.dailyComeBack;
    }

    final fg = bp.onInk;
    final digits = (today?.number ?? '····').split('');

    void share(BuildContext button) {
      final streak = ref.read(profileProvider).value?.dailyStreak ?? 0;
      shareDailyText(
        button,
        Daily.shareText(
          key: today!.key,
          solved: result!.solved,
          seconds: result.seconds,
          referenceSeconds: today.level.seconds,
          hints: result.hints,
          blind: result.blind,
          streak: streak,
          labels: dailyShareLabels(l, hints: result.hints, streak: streak),
          link: dailyShareLink,
        ),
      );
    }

    return Material(
      color: bp.ink,
      child: InkWell(
        onTap: () => context.go(newGameLocation(mode: GameMode.daily, level: Level.intermediate)),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // The stripe follows the seed colour, through its accent.
              Container(width: 6, color: bp.accent),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
                  child: Row(
                    children: [
                      Semantics(
                        label: digits.join(' '),
                        excludeSemantics: true,
                        child: Row(
                          children: [
                            for (final d in digits)
                              Container(
                                width: 28,
                                height: 34,
                                margin: const EdgeInsets.only(right: 4),
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: done ? fg.withValues(alpha: 0.14) : null,
                                  border: Border.all(color: fg.withValues(alpha: 0.6), width: 1.2),
                                ),
                                child: Text(
                                  d,
                                  style: t.titleMedium?.copyWith(color: fg, fontWeight: FontWeight.w700, height: 1),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Flexible(
                                  child: Text(
                                    title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: t.titleSmall?.copyWith(color: fg, fontWeight: FontWeight.w700),
                                  ),
                                ),
                                if (done && result.solved) ...[
                                  const SizedBox(width: 6),
                                  Icon(Icons.check, size: 16, color: fg),
                                ],
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              subtitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: t.bodySmall?.copyWith(color: fg.withValues(alpha: 0.8)),
                            ),
                          ],
                        ),
                      ),
                      if (done)
                        Builder(
                          builder: (button) => IconButton(
                            tooltip: l.dailyShare,
                            color: fg,
                            icon: const Icon(Icons.ios_share),
                            onPressed: () => share(button),
                          ),
                        )
                      else
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Icon(Icons.chevron_right, color: fg),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
