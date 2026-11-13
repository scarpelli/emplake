import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/widgets/bp_widgets.dart';
import '../../../data/firestore_repository.dart';
import '../../../data/models.dart';
import '../../daily/daily.dart';
import '../../settings/settings_controller.dart';
import '../application/catalog_provider.dart';
import '../application/game_controller.dart';
import '../domain/level.dart';
import 'game_page.dart' show tutorialNumber;

class NewGamePage extends ConsumerStatefulWidget {
  const NewGamePage({
    super.key,
    required this.mode,
    required this.level,
    this.number,
    this.exclude,
    this.practice = false,
  });

  final GameMode mode;
  final Level level;
  final String? number;
  final String? exclude;

  final bool practice;

  @override
  ConsumerState<NewGamePage> createState() => _NewGamePageState();
}

class _Prepared {
  const _Prepared(this.number, this.alreadySolved, {this.level, this.dailyDone});
  final String? number;
  final bool alreadySolved;

  final Level? level;

  final DailyResult? dailyDone;
}

class _NewGamePageState extends ConsumerState<NewGamePage> {
  late Future<_Prepared> _future = _prepare();

  Future<_Prepared> _prepare() async {
    final repo = ref.read(repositoryProvider);
    if (widget.mode == GameMode.daily) return _prepareDaily(repo);
    if (widget.mode == GameMode.random && widget.number == null && ref.read(settingsProvider).hintsVisible) {
      return const _Prepared(tutorialNumber, false, level: Level.easy);
    }
    final typed = widget.number;
    if (typed != null) {
      final solved = await repo?.isSolved(widget.level, typed) ?? false;
      return _Prepared(typed, solved);
    }
    final catalog = await ref.read(catalogProvider.future);
    final entry = repo == null
        ? DrawPolicy.pick(catalog, widget.level, const {}, exclude: widget.exclude)
        : await repo.pickUnsolved(catalog, widget.level, exclude: widget.exclude);
    return _Prepared(entry?.number, false);
  }

  Future<_Prepared> _prepareDaily(FirestoreRepository? repo) async {
    final key = Daily.keyFor(DateTime.now());
    final catalog = await ref.read(catalogProvider.future);
    final entry = Daily.entryFor(catalog, key);
    final done = await repo?.dailyResult(key);
    if (done != null) {
      final current = ref.read(gameControllerProvider);
      final resumable = !done.finished && current?.mode == GameMode.daily && current?.number == entry.number;
      if (!resumable) return _Prepared(entry.number, false, level: entry.level, dailyDone: done);
      return _Prepared(null, false, level: entry.level);
    }
    await repo?.startDaily(key, number: entry.number, level: entry.level);
    return _Prepared(entry.number, false, level: entry.level);
  }

  void _launch(_Prepared p) {
    if (p.number != null) {
      ref
          .read(gameControllerProvider.notifier)
          .start(
            mode: widget.mode,
            level: p.level ?? widget.level,
            number: p.number!,
            alreadySolved: p.alreadySolved,
            liveValues: ref.read(settingsProvider).showLiveValues,
            practice: widget.practice,
          );
    }
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return FutureBuilder<_Prepared>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return BpLoader(label: l.loadingNumber, size: 56);
        }
        if (snap.hasError) {
          return _Message(text: l.historyError, action: l.retry, onAction: () => setState(() => _future = _prepare()));
        }
        final p = snap.data!;
        if (p.dailyDone != null) return _DailyDone(result: p.dailyDone!);
        if (p.number == null && widget.mode == GameMode.daily) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) context.go('/game');
          });
          return BpLoader(label: l.loadingNumber, size: 56);
        }
        if (p.number == null) {
          return _Message(text: l.allSolvedCatalog, action: l.menu, onAction: () => context.go('/play'));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _launch(p);
        });
        return BpLoader(label: l.loadingNumber, size: 56);
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.action, required this.onAction});
  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 16),
          OutlinedButton(onPressed: onAction, child: Text(action)),
        ],
      ),
    ),
  );
}

class _DailyDone extends ConsumerWidget {
  const _DailyDone({required this.result});
  final DailyResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final streak = ref.watch(profileProvider).value?.dailyStreak ?? 0;
    final key = Daily.keyFor(DateTime.now());
    final share = Daily.shareText(
      key: key,
      solved: result.solved,
      seconds: result.seconds,
      hints: result.hints,
      blind: result.blind,
      streak: streak,
      hintsLabel: l.hintsCount(result.hints),
      blindLabel: l.blindShort,
    );
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l.dailyAlreadyPlayed, textAlign: TextAlign.center, style: t.titleMedium),
            const SizedBox(height: 12),
            SelectableText(share, textAlign: TextAlign.center, style: t.titleSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                FilledButton.icon(
                  onPressed: () async {
                    await Clipboard.setData(ClipboardData(text: share));
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.copied)));
                    }
                  },
                  icon: const Icon(Icons.content_copy, size: 18),
                  label: Text(l.dailyCopy),
                ),
                OutlinedButton(onPressed: () => context.go('/play'), child: Text(l.menu)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
