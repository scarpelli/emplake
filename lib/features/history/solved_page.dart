import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_math_fork/flutter_math.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../data/firestore_repository.dart';
import '../../data/models.dart';
import '../game/domain/level.dart';

class SolvedPage extends ConsumerStatefulWidget {
  const SolvedPage({super.key});

  @override
  ConsumerState<SolvedPage> createState() => _SolvedPageState();
}

class _SolvedPageState extends ConsumerState<SolvedPage> {
  late Future<HistorySnapshot> _future = _load();
  Level? _filter;

  Future<HistorySnapshot> _load() async {
    final repo = ref.read(repositoryProvider);
    if (repo == null) return const HistorySnapshot(entries: [], skippedCount: 0);
    return repo.loadHistory();
  }

  void _reload() => setState(() => _future = _load());

  @override
  Widget build(BuildContext context) {
    ref.listen(profileProvider, (prev, next) {
      if (prev?.isLoading == true && next.hasValue) _reload();
    });
    final l = context.l10n;

    return ContentWidth(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PageTitle(
              eyebrow: l.historyEyebrow,
              title: l.historyTitle,
              trailing: BoxIconButton(icon: Icons.refresh, tooltip: l.retry, onPressed: _reload),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: FutureBuilder<HistorySnapshot>(
                future: _future,
                builder: (context, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return BpLoader(label: l.historyLoading, size: 56);
                  }
                  if (snap.hasError) {
                    return Center(
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Text(l.historyError),
                        const SizedBox(height: 12),
                        OutlinedButton(onPressed: _reload, child: Text(l.retry)),
                      ]),
                    );
                  }
                  return _content(context, snap.data!);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _content(BuildContext context, HistorySnapshot data) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final bp = context.bp;
    final entries = _filter == null ? data.entries : data.entries.where((e) => e.level == _filter).toList();

    Widget stat(String label, int value) => Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(border: Border.all(color: bp.line)),
            child: Row(children: [
              Eyebrow(label),
              const Spacer(),
              Text('$value', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            ]),
          ),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(children: [
          stat(l.solvedCount, data.entries.length),
          const SizedBox(width: 8),
          stat(l.skippedCount, data.skippedCount),
        ]),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final level in <Level?>[null, ...Level.values])
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: SelectTile(
                    selected: _filter == level,
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    onTap: () => setState(() => _filter = level),
                    child: Text(level == null ? l.filterAll : level.shortLabel(l)),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: entries.isEmpty
              ? Center(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(l.historyEmpty, textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton(onPressed: () => context.go('/play'), child: Text(l.newGame)),
                  ]),
                )
              : ListView.separated(
                  padding: const EdgeInsets.only(bottom: 20),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, i) => _SolvedTile(entry: entries[i]),
                ),
        ),
      ],
    );
  }
}

class _SolvedTile extends StatefulWidget {
  const _SolvedTile({required this.entry});
  final SolvedEntry entry;

  @override
  State<_SolvedTile> createState() => _SolvedTileState();
}

class _SolvedTileState extends State<_SolvedTile> {
  bool _open = false;

  String _when(BuildContext context, DateTime d) {
    final l = context.l10n;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(d.year, d.month, d.day);
    if (day == today) return l.today;
    if (day == today.subtract(const Duration(days: 1))) return l.yesterday;
    return DateFormat.Md(Localizations.localeOf(context).toLanguageTag()).format(d);
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final meta = [
      e.level.label(l).toUpperCase(),
      _when(context, e.solvedAt),
      if (!e.inTime) l.lateTag,
      '+${e.points}',
    ].join(' · ');

    return Container(
      decoration: BoxDecoration(border: Border.all(color: bp.line)),
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Text(e.number, style: t.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 2)),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.expression, style: t.bodyMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(meta, style: t.labelSmall?.copyWith(color: bp.muted)),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.25 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            alignment: Alignment.topCenter,
            child: !_open
                ? const SizedBox(width: double.infinity)
                : Container(
                    width: double.infinity,
                    decoration: BoxDecoration(border: Border(top: BorderSide(color: bp.lineSoft))),
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Math.tex(e.latex, textStyle: TextStyle(fontSize: 20, color: bp.ink)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(minimumSize: const Size(0, 34)),
                          onPressed: () async {
                            await Clipboard.setData(ClipboardData(text: e.latex));
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.latexCopied)));
                            }
                          },
                          icon: const Icon(Icons.content_copy, size: 16),
                          label: Text(l.latex),
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
