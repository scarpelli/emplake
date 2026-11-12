import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/sound_service.dart';
import '../../../core/l10n_helpers.dart';
import '../../../core/router.dart';
import '../../../core/theme/blueprint.dart';
import '../../../core/widgets/bp_widgets.dart';
import '../../../data/firestore_repository.dart';
import '../application/game_controller.dart';
import '../domain/expr.dart';
import '../domain/format.dart';
import '../domain/level.dart';
import 'fly_back_overlay.dart';
import 'formula_panel.dart';
import 'operator_palette.dart';
import 'result_sheet.dart';
import 'tree_view.dart';

class GamePage extends ConsumerStatefulWidget {
  const GamePage({super.key});

  @override
  ConsumerState<GamePage> createState() => _GamePageState();
}

class _GamePageState extends ConsumerState<GamePage> {
  final _paletteKeys = PaletteKeys();
  final _geometry = TreeGeometry();
  final _focus = FocusNode(debugLabel: 'game');
  bool _sheetVisible = false;
  bool _flying = false;

  GameController get _ctrl => ref.read(gameControllerProvider.notifier);
  SoundService get _sound => ref.read(soundProvider);

  @override
  void initState() {
    super.initState();
    final s = ref.read(gameControllerProvider);
    if (s?.phase == GamePhase.solved) {
      _sheetVisible = true;
      if (s!.saveStatus == SaveStatus.failed) WidgetsBinding.instance.addPostFrameCallback((_) => _save());
    }
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  List<FlyItem> _flyItems() => [
        for (final n in _geometry.operatorNodes)
          if (_geometry.globalCenter(n.id) case final from?)
            if (_paletteKeys.globalCenter(n.flySymbol!) case final to?)
              FlyItem(label: n.label.replaceAll(RegExp(r'[()]'), ''), from: from, to: to),
      ];

  Future<void> _verify() async {
    if (_flying) return;
    final items = _flyItems();
    switch (_ctrl.check()) {
      case CheckResult.notReady:
        return;
      case CheckResult.error:
      case CheckResult.wrong:
        _sound.play(Sfx.error);
      case CheckResult.right:
        _sound.play(Sfx.success);
        _flying = true;
        final save = _save();
        await runFlyBack(context, items);
        _flying = false;
        if (mounted) setState(() => _sheetVisible = true);
        await save;
    }
  }

  Future<void> _save() async {
    final s = ref.read(gameControllerProvider);
    if (s == null) return;
    final repo = ref.read(repositoryProvider);
    if (repo == null) {
      _ctrl.setSaveResult(SaveStatus.failed);
      return;
    }
    _ctrl.setSaveResult(SaveStatus.saving);
    try {
      final out = await repo.saveSolved(
        level: s.level,
        number: s.number,
        expression: linearText(s.board),
        latex: latexOf(s.board),
        points: s.pointsEarned,
        seconds: s.elapsed,
        inTime: s.solvedInTime,
      );
      _ctrl.setSaveResult(
        out.isNew ? SaveStatus.savedNew : SaveStatus.savedReplay,
        totalPoints: out.totalPoints,
        pointsEarned: out.pointsAwarded,
      );
      ref.invalidate(profileProvider);
    } catch (_) {
      _ctrl.setSaveResult(SaveStatus.failed);
    }
  }

  void _skip() {
    final s = ref.read(gameControllerProvider);
    if (s == null || _flying) return;
    _sound.play(Sfx.tap);
    if (s.phase == GamePhase.playing) {
      ref.read(repositoryProvider)?.recordSkip(s.level, s.number).catchError((_) {});
    }
    _goNext(s);
  }

  void _goNext(GameState s) {
    setState(() => _sheetVisible = false);
    context.go(newGameLocation(mode: GameMode.random, level: s.level, exclude: s.number));
  }

  void _menu() {
    setState(() => _sheetVisible = false);
    _ctrl.clear();
    context.go('/play');
  }

  void _binary(BinOp op) {
    final linking = ref.read(gameControllerProvider)?.selection is GapSelection;
    _ctrl.applyBinary(op);
    _sound.play(linking ? Sfx.link : Sfx.tap);
  }

  void _equals() {
    _ctrl.placeEquals();
    _sound.play(Sfx.link);
  }

  void _unary(UnOp op) {
    _ctrl.applyUnary(op);
    _sound.play(Sfx.tap);
  }

  void _key(String ch) {
    final s = ref.read(gameControllerProvider);
    if (s == null) return;
    switch (ch) {
      case '+':
        _binary(BinOp.add);
      case '-':
        _binary(BinOp.sub);
      case '*' || 'x':
        _binary(BinOp.mul);
      case '/':
        _binary(BinOp.div);
      case '^':
        if (s.level.binary.contains(BinOp.pow)) _binary(BinOp.pow);
      case '=':
        _equals();
      case '!':
        if (s.level.unary.contains(UnOp.fact)) _unary(UnOp.fact);
      case '(' || ')':
        _ctrl.toggleParens();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameControllerProvider);
    ref.listen(gameControllerProvider.select((s) => s?.secondsLeft), (prev, next) {
      if (prev == 1 && next == 0) _sound.play(Sfx.timeUp);
    });
    final l = context.l10n;

    if (state == null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.account_tree_outlined, size: 48, color: context.bp.muted),
            const SizedBox(height: 12),
            Text(l.noGame, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton(onPressed: () => context.go('/play'), child: Text(l.newGame)),
          ],
        ),
      );
    }

    final shortcuts = <ShortcutActivator, VoidCallback>{
      const SingleActivator(LogicalKeyboardKey.enter): _verify,
      const SingleActivator(LogicalKeyboardKey.numpadEnter): _verify,
      const SingleActivator(LogicalKeyboardKey.escape): _skip,
      const SingleActivator(LogicalKeyboardKey.tab): _ctrl.cycleSelection,
      const SingleActivator(LogicalKeyboardKey.tab, shift: true): () => _ctrl.cycleSelection(backwards: true),
      const SingleActivator(LogicalKeyboardKey.keyZ, control: true): _ctrl.undo,
      const SingleActivator(LogicalKeyboardKey.keyZ, meta: true): _ctrl.undo,
      for (final ch in ['+', '-', '*', 'x', '/', '^', '=', '!', '(', ')']) CharacterActivator(ch): () => _key(ch),
    };

    return CallbackShortcuts(
      bindings: shortcuts,
      child: Focus(
        focusNode: _focus,
        autofocus: true,
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (_) {
            if (!_focus.hasFocus && FocusManager.instance.primaryFocus?.context?.widget is! EditableText) {
              _focus.requestFocus();
            }
          },
          child: LayoutBuilder(
            builder: (context, c) => c.maxWidth >= 1024 ? _desktop(context, state) : _mobile(context, state, c),
          ),
        ),
      ),
    );
  }

  Widget _tree(GameState state) => Stack(
        children: [
          Positioned.fill(
            child: PausedVeil(
              paused: state.paused,
              child: TreeView(
                state: state,
                geometry: _geometry,
                emptyHint: context.l10n.treeGrowsHint,
                onTapNode: (id) {
                  _ctrl.selectNode(id);
                  _sound.play(Sfx.tap);
                },
                onTapGap: (g) {
                  _ctrl.selectGap(g);
                  _sound.play(Sfx.tap);
                },
              ),
            ),
          ),
          if (state.paused) Center(child: _PausedCard(onResume: _ctrl.resume, left: state.pauseLeft)),
        ],
      );

  Widget _palette(GameState state) => OperatorPalette(
        state: state,
        keys: _paletteKeys,
        onBinary: _binary,
        onEquals: _equals,
        onUnary: _unary,
        onParens: () {
          _ctrl.toggleParens();
          _sound.play(Sfx.tap);
        },
        onRemove: () {
          _ctrl.removeUnary();
          _sound.play(Sfx.tap);
        },
      );

  Widget _formula(GameState state) {
    final sel = state.selection;
    return FormulaPanel(
      tokens: linearTokens(state.board),
      latex: latexOf(state.board),
      highlightNodeId: sel is NodeSelection ? sel.nodeId : null,
    );
  }

  Widget _sheet(GameState state) => IgnorePointer(
        ignoring: !(_sheetVisible && state.phase == GamePhase.solved),
        child: AnimatedSlide(
          offset: _sheetVisible && state.phase == GamePhase.solved ? Offset.zero : const Offset(0, 1.1),
          duration: const Duration(milliseconds: 420),
          curve: Curves.easeOutCubic,
          child: state.phase == GamePhase.solved
              ? ResultSheet(state: state, onMenu: _menu, onNext: () => _goNext(state))
              : const SizedBox.shrink(),
        ),
      );

  Widget _mobile(BuildContext context, GameState state, BoxConstraints c) {
    final tall = c.maxHeight >= 720;
    final fixed = [
      _GameHeader(state: state),
      const SizedBox(height: 10),
      _TimerBar(state: state, onPause: _ctrl.pause),
      const SizedBox(height: 10),
      _DigitsStrip(digits: state.board.digits),
    ];
    final bottom = [
      _formula(state),
      const SizedBox(height: 10),
      _Feedback(state: state),
      _palette(state),
      const SizedBox(height: 10),
      _Actions(state: state, onUndo: _ctrl.undo, onSkip: _skip, onVerify: _verify),
      const SizedBox(height: 12),
    ];

    final content = tall
        ? Column(children: [
            ...fixed,
            Expanded(child: _tree(state)),
            ...bottom,
          ])
        : ListView(children: [
            ...fixed,
            SizedBox(height: 240, child: _tree(state)),
            ...bottom,
          ]);

    return Stack(
      children: [
        ContentWidth(
          child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: content),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: ContentWidth(child: _sheet(state)),
        ),
      ],
    );
  }

  Widget _desktop(BuildContext context, GameState state) {
    final l = context.l10n;
    final bp = context.bp;
    final v = state.verdict;
    final sep = context.decimalSeparator;
    return Padding(
      padding: const EdgeInsets.fromLTRB(28, 16, 28, 16),
      child: Column(
        children: [
          _DesktopHeader(state: state, onPause: _ctrl.pause),
          const SizedBox(height: 16),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(border: Border.all(color: bp.line)),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Eyebrow(l.treeTitleDesktop),
                        Expanded(child: _tree(state)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                SizedBox(
                  width: 440,
                  child: Stack(
                    children: [
                      ListView(
                        children: [
                          Eyebrow(l.formula),
                          const SizedBox(height: 6),
                          _formula(state),
                          if (state.board.isComplete && v.result.ok) ...[
                            const SizedBox(height: 8),
                            Wrap(spacing: 12, children: [
                              Text(l.leftSide(v.left!.display(decimalSeparator: sep))),
                              Text(l.rightSide(v.right!.display(decimalSeparator: sep))),
                              Text(v.isTrue ? l.equalityTrue : l.equalityFalse,
                                  style: TextStyle(color: v.isTrue ? bp.ok : bp.danger)),
                            ]),
                          ],
                          const SizedBox(height: 12),
                          _Feedback(state: state),
                          _palette(state),
                          const SizedBox(height: 12),
                          _Actions(state: state, onUndo: _ctrl.undo, onSkip: _skip, onVerify: _verify, showKeys: true),
                        ],
                      ),
                      Positioned(left: 0, right: 0, bottom: 0, child: _sheet(state)),
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

String _subtitle(BuildContext context, GameState s, int? points) {
  final l = context.l10n;
  final parts = [
    s.mode.label(l).toLowerCase(),
    s.level.label(l).toLowerCase(),
    if (points != null) l.pointsShort(points),
  ];
  return parts.join(' · ');
}

class _GameHeader extends ConsumerWidget {
  const _GameHeader({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = Theme.of(context).textTheme;
    final points = ref.watch(profileProvider).value?.totalPoints;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${context.l10n.infoNumber} ${state.number}',
                  style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
              Text(_subtitle(context, state, points), style: t.bodySmall?.copyWith(color: context.bp.muted)),
            ],
          ),
        ),
        const SoundToggle(),
      ],
    );
  }
}

class _DesktopHeader extends ConsumerWidget {
  const _DesktopHeader({required this.state, required this.onPause});
  final GameState state;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final points = ref.watch(profileProvider).value?.totalPoints;
    Widget cell(String label, String value) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(border: Border(left: BorderSide(color: bp.lineSoft))),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Eyebrow(label, opacity: 0.6),
            Text(value, style: t.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
          ]),
        );
    return Row(
      children: [
        Text('EMPLAKE', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 4)),
        const SizedBox(width: 16),
        cell(l.infoNumber, state.number),
        cell(l.infoDigits, state.board.digits.join(' · ')),
        cell(l.infoMode, state.mode.label(l).toUpperCase()),
        cell(l.infoLevel, state.level.label(l).toUpperCase()),
        const SizedBox(width: 16),
        Expanded(child: _TimerBar(state: state, onPause: onPause)),
        const SizedBox(width: 16),
        if (points != null) Text(l.pointsShort(points), style: t.labelLarge),
        const SizedBox(width: 12),
        const SoundToggle(),
      ],
    );
  }
}

class _TimerBar extends StatelessWidget {
  const _TimerBar({required this.state, required this.onPause});
  final GameState state;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final frac = (state.secondsLeft / state.level.seconds).clamp(0.0, 1.0);
    final low = state.secondsLeft <= 10;
    final canPause = !state.pauseUsed && state.phase == GamePhase.playing && !state.timeUp;
    return Row(
      children: [
        Icon(state.timeUp ? Icons.timer_off_outlined : Icons.timer_outlined, size: 18),
        const SizedBox(width: 8),
        Expanded(
          child: Container(
            height: 4,
            color: bp.lineSoft,
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: const Duration(milliseconds: 900),
              widthFactor: frac,
              child: Container(color: low ? bp.accent : bp.ink),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(state.timeUp ? l.timeUp : '${state.secondsLeft}s',
            style: t.labelMedium?.copyWith(color: state.timeUp ? bp.accent : bp.ink)),
        const SizedBox(width: 8),
        Tooltip(
          message: l.pause,
          child: InkWell(
            onTap: canPause ? onPause : null,
            child: Opacity(
              opacity: canPause || state.paused ? 1 : 0.4,
              child: Container(
                height: 32,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                decoration: BoxDecoration(border: Border.all(color: bp.line)),
                child: Row(children: [
                  Icon(Icons.pause, size: 16, semanticLabel: l.pause),
                  const SizedBox(width: 4),
                  Text('${state.paused ? (state.pauseLeft ?? Level.pauseSeconds) : Level.pauseSeconds}s',
                      style: t.labelMedium),
                ]),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DigitsStrip extends StatelessWidget {
  const _DigitsStrip({required this.digits});
  final List<int> digits;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: bp.ink.withValues(alpha: 0.7))),
      child: Row(
        children: [
          for (var i = 0; i < digits.length; i++)
            Expanded(
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(border: i == 3 ? null : Border(right: BorderSide(color: bp.lineSoft))),
                child: Text('${digits[i]}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600)),
              ),
            ),
        ],
      ),
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final v = state.verdict;
    final sep = context.decimalSeparator;

    Widget banner(IconData icon, String title, String body, Color color) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(border: Border.all(color: color), color: color.withValues(alpha: 0.12)),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (title.isNotEmpty)
                        Text(title, style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: color)),
                      Text(body, style: t.bodySmall?.copyWith(height: 1.4)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );

    if (state.phase != GamePhase.playing) return const SizedBox.shrink();
    final error = v.result.error;
    if (error != null) {
      final (title, body) = evalErrorText(error, state.level, l, sep);
      return banner(Icons.error_outline, title, body, bp.danger);
    }
    if (state.wrongAttempt && v.left != null && v.right != null) {
      return banner(Icons.close, l.wrongTitle,
          l.wrongBody(v.left!.display(decimalSeparator: sep), v.right!.display(decimalSeparator: sep)), bp.danger);
    }
    if (state.alreadySolved && state.board.linksMade == 0) {
      return banner(Icons.info_outline, '', l.alreadySolved, bp.accent);
    }
    if (state.board.linksMade == 0 && state.selection == null) {
      return banner(Icons.touch_app_outlined, '', l.hintStart, bp.ink);
    }
    return const SizedBox.shrink();
  }
}

class _Actions extends StatelessWidget {
  const _Actions({
    required this.state,
    required this.onUndo,
    required this.onSkip,
    required this.onVerify,
    this.showKeys = false,
  });

  final GameState state;
  final VoidCallback onUndo;
  final VoidCallback onSkip;
  final VoidCallback onVerify;
  final bool showKeys;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final v = state.verdict;
    final playing = state.phase == GamePhase.playing && !state.paused;
    final String verifyLabel;
    final bool canVerify;
    if (!state.board.isComplete) {
      verifyLabel = l.linksLeft(state.board.linksLeft);
      canVerify = false;
    } else if (!v.result.ok) {
      verifyLabel = l.fixError;
      canVerify = false;
    } else {
      verifyLabel = showKeys ? '${l.verify} · Enter' : l.verify;
      canVerify = playing;
    }
    return Row(
      children: [
        BoxIconButton(icon: Icons.undo, tooltip: l.undo, size: 48, onPressed: playing && state.canUndo ? onUndo : null),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
            onPressed: state.phase == GamePhase.playing ? onSkip : null,
            child: FittedBox(child: Text(showKeys ? '${l.skip} · Esc' : l.skip)),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: FilledButton(
            onPressed: canVerify ? onVerify : null,
            child: FittedBox(child: Text(verifyLabel)),
          ),
        ),
      ],
    );
  }
}

class _PausedCard extends StatelessWidget {
  const _PausedCard({required this.onResume, required this.left});
  final VoidCallback onResume;
  final int? left;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bp.panel, border: Border.all(color: bp.line)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(left == null ? l.pausedTitle : '${l.pausedTitle} · ${left}s',
              style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 2)),
          const SizedBox(height: 4),
          Text(l.pausedBody, style: t.bodySmall?.copyWith(color: bp.muted)),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: onResume, icon: const Icon(Icons.play_arrow), label: Text(l.resume)),
        ],
      ),
    );
  }
}
