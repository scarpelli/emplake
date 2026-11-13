import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/router.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../core/widgets/brand_home.dart';
import '../../data/models.dart';
import '../game/domain/challenge.dart';
import 'challenge_store.dart';

class ChallengesPage extends ConsumerWidget {
  const ChallengesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final stats = ref.watch(challengeStatsProvider).value ?? const {};

    Widget card(ChallengeKind kind, {required bool expand}) {
      final s = stats[kind] ?? const ChallengeStats();
      return _ChallengeCard(
        code: 'D.0${kind.index + 1}',
        tag: kind == ChallengeKind.clock ? l.challengeClockTag : l.challengeRestrictedTag,
        icon: kind == ChallengeKind.clock ? Icons.timer_outlined : Icons.rule,
        title: kind == ChallengeKind.clock ? l.challengeClockTitle : l.challengeRestrictedTitle,
        body: kind == ChallengeKind.clock ? l.challengeClockDesc : l.challengeRestrictedDesc,
        firstLabel: kind == ChallengeKind.clock ? l.challengeRecord : l.challengeStreak,
        first: '${s.best}',
        plays: '${s.plays}',
        onPlay: () => context.go(challengeLocation(kind)),
        expand: expand,
      );
    }

    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 760;
        final pad = wide ? const EdgeInsets.fromLTRB(28, 20, 28, 20) : const EdgeInsets.fromLTRB(20, 12, 20, 0);
        final note = Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Text(l.challengeLadder, style: t.bodySmall?.copyWith(color: bp.muted)),
        );
        return Padding(
          padding: pad,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ModeHeader(title: l.modeChallenges),
              Expanded(
                child: wide
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          note,
                          Expanded(
                            child: Center(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 1240, maxHeight: 640),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(child: card(ChallengeKind.clock, expand: true)),
                                    const SizedBox(width: 40),
                                    Expanded(child: card(ChallengeKind.restricted, expand: true)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    : ListView(
                        padding: const EdgeInsets.only(bottom: 24),
                        children: [
                          note,
                          card(ChallengeKind.clock, expand: false),
                          const SizedBox(height: 16),
                          card(ChallengeKind.restricted, expand: false),
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

class _ChallengeCard extends StatelessWidget {
  const _ChallengeCard({
    required this.code,
    required this.tag,
    required this.icon,
    required this.title,
    required this.body,
    required this.firstLabel,
    required this.first,
    required this.plays,
    required this.onPlay,
    required this.expand,
  });

  final String code;
  final String tag;
  final IconData icon;
  final String title;
  final String body;
  final String firstLabel;
  final String first;
  final String plays;
  final VoidCallback onPlay;

  final bool expand;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    Widget stat(String label, String value) => Expanded(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(label, opacity: 0.6),
            const SizedBox(height: 4),
            Text(value, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
    return Container(
      decoration: BoxDecoration(border: Border.all(color: bp.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: bp.lineSoft)),
            ),
            child: Row(
              children: [
                Text(code, style: t.labelMedium?.copyWith(letterSpacing: 3)),
                const Spacer(),
                Text(tag, style: t.labelMedium?.copyWith(letterSpacing: 3)),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 40, color: bp.ink),
                const SizedBox(height: 20),
                Text(title, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                Text(body, style: t.bodyMedium?.copyWith(height: 1.5, color: bp.ink.withValues(alpha: 0.85))),
              ],
            ),
          ),
          if (expand) const Spacer(),
          Container(
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: bp.lineSoft)),
            ),
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  stat(firstLabel, first),
                  VerticalDivider(width: 1, color: bp.lineSoft),
                  stat(l.challengePlays, plays),
                ],
              ),
            ),
          ),
          Material(
            color: bp.ink,
            child: InkWell(
              onTap: onPlay,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text(
                    l.challengePlay,
                    style: t.titleMedium?.copyWith(color: bp.onInk, fontWeight: FontWeight.w700, letterSpacing: 4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
