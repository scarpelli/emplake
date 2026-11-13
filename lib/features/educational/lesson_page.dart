import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/router.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../game/application/catalog_provider.dart';
import '../game/application/game_controller.dart';
import '../game/domain/catalog.dart';
import '../game/domain/expr.dart';
import '../game/domain/format.dart';
import '../game/domain/replay.dart';
import '../game/presentation/tree_view.dart';
import '../settings/settings_controller.dart';

String _symbol(Enum op) => op is BinOp ? op.label : (op as UnOp).label;

String _name(Enum op, BuildContext context) => op is BinOp ? op.name(context.l10n) : (op as UnOp).name(context.l10n);

String _example(Enum op, BuildContext context) =>
    op is BinOp ? op.example(context.decimalSeparator) : (op as UnOp).example(context.decimalSeparator);

class LessonsPage extends ConsumerWidget {
  const LessonsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final catalog = ref.watch(catalogProvider);
    final done = ref.watch(settingsProvider.select((s) => s.lessonsDone));

    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => context.go('/play'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    children: [
                      Icon(Icons.arrow_back, size: 18, semanticLabel: l.back),
                      const SizedBox(width: 6),
                      Eyebrow(l.modeLabel(l.modeEducational.toUpperCase())),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              const HelpButton(),
            ],
          ),
          const SizedBox(height: 16),
          PageTitle(eyebrow: l.lessonsEyebrow(done.length, catalog.value?.lessons.length ?? 0), title: l.lessonsTitle),
          const SizedBox(height: 8),
          Text(l.lessonsIntro, style: t.bodyMedium?.copyWith(color: bp.muted, height: 1.45)),
          const SizedBox(height: 16),
          ...switch (catalog) {
            AsyncData(:final value) => [
              for (final lesson in value.lessons)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: SelectTile(
                    selected: false,
                    onTap: () => context.go('/play/learn/${lesson.op.name}'),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: Text(_symbol(lesson.op), style: t.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _name(lesson.op, context),
                                style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              Text(_example(lesson.op, context), style: t.bodySmall?.copyWith(color: bp.muted)),
                            ],
                          ),
                        ),
                        Icon(
                          done.contains(lesson.op.name) ? Icons.check_circle : Icons.play_circle_outline,
                          color: done.contains(lesson.op.name) ? bp.ok : bp.ink,
                          semanticLabel: done.contains(lesson.op.name) ? l.lessonDone : null,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
            AsyncError() => [Text(l.historyError)],
            _ => [const BpLoader()],
          },
        ],
      ),
    );
  }
}

class LessonPlayerPage extends ConsumerStatefulWidget {
  const LessonPlayerPage({super.key, required this.op});

  final String op;

  @override
  ConsumerState<LessonPlayerPage> createState() => _LessonPlayerPageState();
}

class _LessonPlayerPageState extends ConsumerState<LessonPlayerPage> {
  int _step = 0;
  Timer? _auto;

  @override
  void dispose() {
    _auto?.cancel();
    super.dispose();
  }

  void _play(int length) {
    _auto?.cancel();
    if (_step >= length - 1) setState(() => _step = 0);
    _auto = Timer.periodic(const Duration(milliseconds: 1400), (t) {
      if (!mounted) return t.cancel();
      if (_step >= length - 1) {
        t.cancel();
        setState(() => _auto = null);
        return;
      }
      setState(() => _step++);
    });
    setState(() {});
  }

  String _caption(ReplayStep step, Lesson lesson, BuildContext context) {
    final l = context.l10n;
    final d = step.board.digits;
    if (step.equals) return l.lessonStepEquals(d[step.gap!], d[step.gap! + 1]);
    final op = step.op;
    if (op == null) return l.lessonStepStart(lesson.example.number);
    if (op is BinOp) return l.lessonStepLink(d[step.gap!], d[step.gap! + 1], op.label, op.name(l));
    return l.lessonStepUnary((op as UnOp).label, op.name(l));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final catalog = ref.watch(catalogProvider).value;
    final lesson = catalog?.lessons.where((x) => x.op.name == widget.op).firstOrNull;
    if (lesson == null) return const BpLoader();

    final steps = replaySolution(lesson.example.number, lesson.example.solution);
    final step = steps[_step.clamp(0, steps.length - 1)];
    final last = _step >= steps.length - 1;
    final demo = GameState(
      mode: GameMode.educational,
      level: lesson.example.level,
      board: step.board,
      secondsLeft: 0,
      phase: last ? GamePhase.solved : GamePhase.playing,
      practice: true,
    );

    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          InkWell(
            onTap: () => context.go('/play/learn'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                children: [
                  Icon(Icons.arrow_back, size: 18, semanticLabel: l.back),
                  const SizedBox(width: 6),
                  Eyebrow(l.lessonsTitle.toUpperCase()),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          PageTitle(eyebrow: _symbol(lesson.op), title: _name(lesson.op, context)),
          const SizedBox(height: 4),
          Text(_example(lesson.op, context), style: t.bodyMedium?.copyWith(color: bp.muted)),
          const SizedBox(height: 16),
          Container(
            height: 260,
            decoration: BoxDecoration(border: Border.all(color: bp.line)),
            padding: const EdgeInsets.all(8),
            child: IgnorePointer(
              child: TreeView(state: demo, onTapNode: (_) {}, onTapGap: (_) {}),
            ),
          ),
          const SizedBox(height: 10),
          Semantics(
            liveRegion: true,
            child: Text(
              '${_step + 1}/${steps.length} · ${_caption(step, lesson, context)}',
              style: t.bodyMedium?.copyWith(height: 1.45),
            ),
          ),
          const SizedBox(height: 6),
          Text(linearText(step.board), style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Row(
            children: [
              BoxIconButton(
                icon: Icons.chevron_left,
                tooltip: l.lessonPrev,
                onPressed: _step > 0 ? () => setState(() => _step--) : null,
              ),
              const SizedBox(width: 8),
              BoxIconButton(
                icon: _auto == null ? Icons.play_arrow : Icons.pause,
                tooltip: _auto == null ? l.lessonPlay : l.pause,
                onPressed: () {
                  if (_auto != null) {
                    _auto!.cancel();
                    setState(() => _auto = null);
                  } else {
                    _play(steps.length);
                  }
                },
              ),
              const SizedBox(width: 8),
              BoxIconButton(
                icon: Icons.chevron_right,
                tooltip: l.lessonNext,
                onPressed: last ? null : () => setState(() => _step++),
              ),
              const Spacer(),
              FilledButton.icon(
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l.lessonNowYou),
                onPressed: () => context.go(
                  newGameLocation(
                    mode: GameMode.educational,
                    level: lesson.practice.level,
                    number: lesson.practice.number,
                    practice: true,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(l.lessonNowYouHint, style: t.bodySmall?.copyWith(color: bp.muted)),
        ],
      ),
    );
  }
}
