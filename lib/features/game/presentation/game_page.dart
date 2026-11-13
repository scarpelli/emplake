import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/audio/sound_service.dart';
import '../../../core/l10n_helpers.dart';
import '../../../l10n/app_localizations.dart';
import '../../../core/router.dart';
import '../../../core/theme/blueprint.dart';
import '../../../core/widgets/bp_widgets.dart';
import '../../../core/widgets/brand_home.dart';
import '../../../data/firestore_repository.dart';
import '../../achievements/achievement_toast.dart';
import '../../adventure/adventure_store.dart';
import '../../challenges/challenge_store.dart';
import '../../achievements/achievements.dart';
import '../../daily/daily.dart';
import '../../help/help_dialog.dart';
import '../../settings/settings_controller.dart';
import '../application/catalog_provider.dart';
import '../application/game_controller.dart';
import '../domain/adventure.dart';
import '../domain/challenge.dart';
import '../domain/evaluator.dart';
import '../domain/expr.dart';
import '../domain/format.dart';
import '../domain/hints.dart';
import '../domain/level.dart';
import '../domain/board.dart';
import '../domain/rules.dart';
import 'fly_back_overlay.dart';
import 'coach_overlay.dart';
import 'formula_panel.dart';
import 'operator_palette.dart';
import 'result_sheet.dart';
import 'skip_dialog.dart';
import 'tree_view.dart';

const tutorialNumber = '1236';

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

  int? _stars;

  bool? _runRecord;
  int? _runBest;

  Timer? _autoNext;

  GameController get _ctrl => ref.read(gameControllerProvider.notifier);
  SoundService get _sound => ref.read(soundProvider);

  @override
  void initState() {
    super.initState();
    final s = ref.read(gameControllerProvider);
    if (s?.phase == GamePhase.revealed) _sheetVisible = true;
    if (s?.run case final run? when run.over && !run.recorded) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _finishRun());
    }
    if (s?.phase == GamePhase.solved && s?.run != null) {
      _sheetVisible = true;
    } else if (s?.phase == GamePhase.solved) {
      _sheetVisible = true;
      if (s!.saveStatus == SaveStatus.failed) WidgetsBinding.instance.addPostFrameCallback((_) => _save());
    }
  }

  @override
  void dispose() {
    _autoNext?.cancel();
    _focus.dispose();
    super.dispose();
  }

  void _buzz({bool strong = false}) {
    if (!ref.read(settingsProvider).haptics) return;
    strong ? HapticFeedback.heavyImpact() : HapticFeedback.selectionClick();
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
    final s0 = ref.read(gameControllerProvider);
    final streak = s0 == null || s0.practice ? 0 : (ref.read(profileProvider).value?.streak ?? 0);
    switch (_ctrl.check(streak: streak)) {
      case CheckResult.notReady:
        return;
      case CheckResult.error:
      case CheckResult.wrong:
      case CheckResult.ruleBroken:
        _sound.play(Sfx.error);
        _buzz(strong: true);
      case CheckResult.right when s0?.run != null:
        _sound.play(Sfx.success);
        setState(() => _sheetVisible = true);
        _autoNext?.cancel();
        _autoNext = Timer(const Duration(milliseconds: 1100), () {
          final now = ref.read(gameControllerProvider);
          if (mounted && now?.run != null && now!.phase == GamePhase.solved) _goNext(now);
        });
      case CheckResult.right:
        _sound.play(Sfx.success);
        _flying = true;
        final save = _save();
        if (!MediaQuery.disableAnimationsOf(context)) await runFlyBack(context, items);
        _flying = false;
        if (mounted) setState(() => _sheetVisible = true);
        await save;
    }
  }

  Future<void> _save() async {
    final s = ref.read(gameControllerProvider);
    if (s == null) return;
    if (s.mode == GameMode.educational) {
      final catalog = await ref.read(catalogProvider.future);
      final lesson = catalog.lessons.where((x) => x.practice.number == s.number).firstOrNull;
      if (lesson != null) ref.read(settingsProvider.notifier).markLessonDone(lesson.op.name);
    }
    if (s.practice) {
      _ctrl.setSaveResult(SaveStatus.none);
      return;
    }
    if (s.mode == GameMode.adventure && s.stage != null) {
      final stars = AdventureStars.of(
        inTime: s.solvedInTime,
        hints: s.hintsUsed,
        secondsLeft: s.secondsLeft,
        levelSeconds: s.level.seconds,
      );
      if (mounted) setState(() => _stars = stars);
      unawaited(recordAdventureStars(ref, '${s.level.name}_${s.number}', stars));
    }
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
        hints: s.hintsUsed,
        blind: !s.sawLiveValues,
      );
      _ctrl.setSaveResult(
        out.isNew ? SaveStatus.savedNew : SaveStatus.savedReplay,
        totalPoints: out.totalPoints,
        pointsEarned: out.pointsAwarded,
      );
      if (s.mode == GameMode.daily) {
        await repo.finishDaily(
          Daily.keyFor(DateTime.now()),
          solved: true,
          seconds: s.elapsed,
          hints: s.hintsUsed,
          blind: !s.sawLiveValues,
        );
      }
      ref.invalidate(profileProvider);
      if (out.isNew) ref.invalidate(adventureStarsProvider);
      if (out.isNew || s.mode == GameMode.daily) await _checkAchievements(repo, s);
    } catch (_) {
      _ctrl.setSaveResult(SaveStatus.failed);
    }
  }

  Future<void> _checkAchievements(FirestoreRepository repo, GameState s) async {
    try {
      final profile = await ref.read(profileProvider.future);
      if (profile == null) return;
      final catalog = await ref.read(catalogProvider.future);
      final stars = catalog.lookup(s.level, s.number)?.stars;
      final unlocked = Achievement.newlyReached(profile, solvedStars: stars);
      if (unlocked.isEmpty) return;
      await repo.unlockAchievements(unlocked.map((a) => a.name));
      ref.invalidate(profileProvider);
      if (!mounted) return;
      unawaited(showAchievementToasts(context, unlocked));
    } catch (_) {
    }
  }

  Future<void> _finishRun() async {
    final run = ref.read(gameControllerProvider)?.run;
    if (run == null || !run.over || run.recorded) return;
    _ctrl.markRunRecorded();
    final record = await recordChallengeRun(ref, run);
    final stats = await ref.read(challengeStatsProvider.future);
    if (!mounted) return;
    setState(() {
      _runRecord = record;
      _runBest = stats[run.kind]?.best;
    });
  }

  void _failDaily(GameState s) {
    if (s.mode != GameMode.daily) return;
    ref
        .read(repositoryProvider)
        ?.finishDaily(Daily.keyFor(DateTime.now()), solved: false, seconds: s.elapsed, hints: s.hintsUsed, blind: false)
        .then((_) => ref.invalidate(profileProvider))
        .catchError((_) {});
  }

  Future<void> _shareDaily() async {
    final s = ref.read(gameControllerProvider);
    if (s == null) return;
    final l = context.l10n;
    final profile = await ref.read(profileProvider.future);
    final text = Daily.shareText(
      key: Daily.keyFor(DateTime.now()),
      solved: s.phase == GamePhase.solved,
      seconds: s.elapsed,
      hints: s.hintsUsed,
      blind: !s.sawLiveValues,
      streak: profile?.dailyStreak ?? 0,
      hintsLabel: l.hintsCount(s.hintsUsed),
      blindLabel: l.blindShort,
    );
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l.copied)));
  }

  Future<void> _hint() async {
    final s = ref.read(gameControllerProvider);
    if (s == null || !s.canHint) return;
    if (s.hintsUsed == 2) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (context) {
          final l = context.l10n;
          return AlertDialog(
            title: Text(l.hintRevealTitle),
            content: Text(l.hintRevealBody),
            actions: [
              TextButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.cancel)),
              FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l.skipYes)),
            ],
          );
        },
      );
      if (ok != true || !mounted) return;
    }
    final solution = s.solution ?? await ref.read(solutionProvider((s.level, s.number)).future);
    if (!mounted || solution == null) return;
    _sound.play(Sfx.tap);
    final wasLast = s.hintsUsed == 2;
    _ctrl.useHint(solution);
    if (wasLast) {
      ref.read(repositoryProvider)?.recordSkip(s.level, s.number, revealed: true).catchError((_) {});
      _failDaily(s);
      setState(() => _sheetVisible = true);
    }
  }

  Future<void> _skip() async {
    final s = ref.read(gameControllerProvider);
    if (s == null || _flying) return;
    _sound.play(Sfx.tap);
    if (s.phase != GamePhase.playing) {
      _goNext(s);
      return;
    }
    if (s.run != null) {
      _ctrl.skipChallenge();
      final now = ref.read(gameControllerProvider);
      if (now?.run?.kind == ChallengeKind.clock && !(now?.run?.over ?? true)) {
        _goNext(now!);
      } else {
        setState(() => _sheetVisible = true);
      }
      return;
    }
    final show = await showSkipDialog(context);
    if (show == null || !mounted) return;
    ref.read(repositoryProvider)?.recordSkip(s.level, s.number, revealed: show).catchError((_) {});
    _failDaily(s);
    if (show) {
      await _reveal();
    } else {
      _goNext(s);
    }
  }

  Future<void> _reveal() async {
    final s = ref.read(gameControllerProvider);
    if (s == null) return;
    final solution = await ref.read(solutionProvider((s.level, s.number)).future);
    if (!mounted || solution == null) return;
    _ctrl.reveal(solution);
    setState(() => _sheetVisible = true);
  }

  Future<void> _revealAfterTimeUp() async {
    final s = ref.read(gameControllerProvider);
    if (s == null || s.phase != GamePhase.playing) return;
    ref.read(repositoryProvider)?.recordSkip(s.level, s.number, revealed: true).catchError((_) {});
    _failDaily(s);
    await _reveal();
  }

  void _goNext(GameState s) {
    _autoNext?.cancel();
    if (s.run case final run?) {
      setState(() {
        _sheetVisible = false;
        _runRecord = null;
        _runBest = null;
      });
      context.go(challengeLocation(run.kind, nextPlate: !run.over));
      return;
    }
    if (s.mode == GameMode.adventure) {
      setState(() {
        _sheetVisible = false;
        _stars = null;
      });
      unawaited(_nextStage(s));
      return;
    }
    if (s.mode == GameMode.daily) {
      _menu();
      return;
    }
    if (s.mode == GameMode.educational) {
      setState(() => _sheetVisible = false);
      _ctrl.clear();
      context.go('/play/learn');
      return;
    }
    setState(() => _sheetVisible = false);
    if (s.mode == GameMode.specific) {
      _ctrl.clear();
      context.go('/play/level?mode=${GameMode.specific.name}');
      return;
    }
    context.go(newGameLocation(mode: s.mode, level: s.level, exclude: s.number, practice: s.practice));
  }

  Future<void> _nextStage(GameState s) async {
    final progress = await ref.read(adventureProgressProvider.future);
    if (!mounted) return;
    final next = s.stage == null ? progress.focus : progress.nextAfter(s.stage!);
    if (next == null) {
      _ctrl.clear();
      context.go('/play/adventure');
      return;
    }
    context.go(
      newGameLocation(mode: GameMode.adventure, level: next.entry.level, number: next.entry.number, stage: next.number),
    );
  }

  void _menu() {
    _autoNext?.cancel();
    final s = ref.read(gameControllerProvider);
    if (s?.run case final run? when !run.recorded) {
      unawaited(recordChallengeRun(ref, run.abandon()));
    }
    setState(() {
      _sheetVisible = false;
      _stars = null;
    });
    _ctrl.clear();
    context.go(switch (s?.mode) {
      GameMode.adventure => '/play/adventure',
      GameMode.challenges => '/play/challenges',
      _ => '/play',
    });
  }

  void _act(VoidCallback action) {
    final before = ref.read(gameControllerProvider)?.board;
    action();
    final changed = !identical(before, ref.read(gameControllerProvider)?.board);
    _sound.play(changed ? Sfx.link : Sfx.tap);
    if (changed) _buzz();
  }

  void _binary(BinOp op) => _act(() => _ctrl.applyBinary(op));

  void _equals() => _act(_ctrl.placeEquals);

  void _unary(UnOp op) {
    _ctrl.applyUnary(op);
    _sound.play(Sfx.tap);
  }

  void _remove() {
    if (_ctrl.removeSelected()) _sound.play(Sfx.tap);
  }

  void _drop(SignDrag drag, int gap) {
    if (_ctrl.drop(drag, gap)) {
      _sound.play(Sfx.link);
      _buzz();
    }
  }

  void _dropOutside(SignDrag drag) {
    _ctrl.dropOutside(drag);
    _sound.play(Sfx.tap);
  }

  static const _unaryKeys = {
    '!': UnOp.fact,
    'r': UnOp.sqrt,
    'c': UnOp.cbrt,
    'a': UnOp.abs,
    'n': UnOp.neg,
    'f': UnOp.floor,
    'F': UnOp.ceil,
  };

  void _key(String ch) {
    final s = ref.read(gameControllerProvider);
    if (s == null) return;
    switch (ch) {
      case '+' || '-' || '*' || 'x' || '/' || '^':
        final op = switch (ch) {
          '+' => BinOp.add,
          '-' => BinOp.sub,
          '/' => BinOp.div,
          '^' => BinOp.pow,
          _ => BinOp.mul,
        };
        if (s.rules.binary.contains(op)) _binary(op);
      case '=':
        _equals();
      case '!' || 'r' || 'c' || 'a' || 'n' || 'f' || 'F':
        final op = _unaryKeys[ch]!;
        if (s.rules.unary.contains(op)) _unary(op);
      case '(' || ')':
        _ctrl.toggleParens();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(gameControllerProvider);
    ref.listen(gameControllerProvider.select((s) => s?.secondsLeft), (prev, next) {
      if (prev == 1 && next == 0) _sound.play(Sfx.timeUp);
      if (next != null && next > 0 && next <= 5 && prev != next) _sound.play(Sfx.tap);
    });
    ref.listen(settingsProvider.select((s) => s.showLiveValues), (_, on) {
      if (on) _ctrl.noteLiveValuesShown();
    });
    ref.listen(gameControllerProvider.select((s) => (s?.phase, s?.run?.over)), (prev, next) {
      final s = ref.read(gameControllerProvider);
      if (s?.run == null) return;
      if (next.$1 == GamePhase.revealed && prev?.$1 == GamePhase.playing) setState(() => _sheetVisible = true);
      if (next.$2 == true && prev?.$2 != true) _finishRun();
    });
    ref.listen(gameControllerProvider.select((s) => s?.phase), (_, phase) {
      if (phase != null && phase != GamePhase.playing && _inTutorial) {
        ref.read(settingsProvider.notifier).markTutorialDone();
      }
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
      const SingleActivator(LogicalKeyboardKey.keyH): _hint,
      const SingleActivator(LogicalKeyboardKey.backspace): _remove,
      const SingleActivator(LogicalKeyboardKey.delete): _remove,
      for (final ch in ['+', '-', '*', 'x', '/', '^', '=', '(', ')', ..._unaryKeys.keys])
        CharacterActivator(ch): () => _key(ch),
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
          child: Stack(
            children: [
              Positioned.fill(
                child: LayoutBuilder(
                  builder: (context, c) => c.maxWidth >= 1024 ? _desktop(context, state) : _mobile(context, state, c),
                ),
              ),
              if (_tutorialStep(state) case final step?)
                Positioned.fill(
                  child: CoachOverlay(step: step, onSkip: () => ref.read(settingsProvider.notifier).markTutorialDone()),
                ),
            ],
          ),
        ),
      ),
    );
  }

  bool get _inTutorial {
    final s = ref.read(gameControllerProvider);
    return s != null && s.number == tutorialNumber && ref.read(settingsProvider).hintsVisible;
  }

  Offset? _gapCenter(Board board, int digitGap) {
    final blockGap = board.blockGapAt(digitGap);
    return blockGap == null ? null : _geometry.globalCenter(TreeLayout.gapId(blockGap));
  }

  CoachStep? _tutorialStep(GameState s) {
    final settings = ref.watch(settingsProvider);
    if (!settings.hintsVisible || s.number != tutorialNumber || s.phase != GamePhase.playing || s.paused) return null;
    final l = context.l10n;
    final b = s.board;
    final sel = s.selection;
    final mul = BinOp.mul;
    bool selectedGap(int digitGap) => sel is GapSelection && b.digitGapOf(sel.gap) == digitGap;

    final onScript = b.eqGap == null || b.eqDigitGap == 2
        ? [0, 1].every((g) => b.binaryAt(g) == null || b.binaryAt(g)!.op == mul)
        : false;
    if (!onScript || b.binaryAt(2) != null) {
      return CoachStep(text: l.tutorialOffScript);
    }
    if (b.binaryAt(0) == null) {
      return selectedGap(0)
          ? CoachStep(text: l.tutorialPickTimes, target: () => _paletteKeys.globalCenter(mul), balloon: BalloonAt.top)
          : CoachStep(text: l.tutorialTapGap(1, 2), target: () => _gapCenter(b, 0), balloon: BalloonAt.below);
    }
    if (b.binaryAt(1) == null) {
      return selectedGap(1)
          ? CoachStep(text: l.tutorialPickTimes, target: () => _paletteKeys.globalCenter(mul), balloon: BalloonAt.top)
          : CoachStep(text: l.tutorialLinkThree, target: () => _gapCenter(b, 1), balloon: BalloonAt.below);
    }
    if (b.eqGap == null) {
      return selectedGap(2)
          ? CoachStep(text: l.tutorialPickEquals, target: () => _paletteKeys.globalCenter('='), balloon: BalloonAt.top)
          : CoachStep(text: l.tutorialEqualsGap, target: () => _gapCenter(b, 2), balloon: BalloonAt.below);
    }
    return CoachStep(text: l.tutorialVerify, target: () => _globalCenterOf(_verifyKey));
  }

  final _verifyKey = GlobalKey(debugLabel: 'verify');

  static Offset? _globalCenterOf(GlobalKey key) {
    final box = key.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.attached || !box.hasSize) return null;
    return box.localToGlobal(box.size.center(Offset.zero));
  }

  Set<int> _hintGaps(GameState state) {
    final rule = state.restriction;
    if (state.phase == GamePhase.playing && rule != null && rule.kind == RestrictionKind.equalsAt) {
      return {rule.gap!};
    }
    if (state.phase != GamePhase.playing || state.hintsUsed == 0 || state.solution == null) return const {};
    final h = HintInfo.from(state.number, state.solution!);
    return {h.equalsGap, if (state.hintsUsed >= 2) h.linkGap};
  }

  Widget _tree(GameState state) {
    final settings = ref.watch(settingsProvider);
    return Stack(
      children: [
        Positioned.fill(
          child: PausedVeil(
            paused: state.paused,
            child: TreeView(
              state: state,
              geometry: _geometry,
              emptyHint: null,
              showValues: settings.showLiveValues,
              hintGaps: _hintGaps(state),
              onTapNode: (id) => _act(() => _ctrl.selectNode(id)),
              onTapGap: (g) => _act(() => _ctrl.selectGap(g)),
              onTapEquals: () => _act(_ctrl.selectEquals),
              onDrop: _drop,
              canDrop: _ctrl.canDrop,
              onDropOutside: _dropOutside,
            ),
          ),
        ),
        if (state.paused)
          Center(
            child: _PausedCard(onResume: _ctrl.resume, left: state.pauseLeft),
          ),
      ],
    );
  }

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
    onRemove: _remove,
  );

  Widget _formula(GameState state) {
    final sel = state.selection;
    return FormulaPanel(
      tokens: linearTokens(state.board),
      latex: latexOf(state.board),
      highlightNodeId: sel is NodeSelection ? sel.nodeId : null,
      open: ref.watch(settingsProvider.select((s) => s.latexOpen)),
      onOpenChanged: ref.read(settingsProvider.notifier).setLatexOpen,
    );
  }

  Widget _sheet(GameState state) {
    final over = state.phase != GamePhase.playing;
    return IgnorePointer(
      ignoring: !(_sheetVisible && over),
      child: AnimatedSlide(
        offset: _sheetVisible && over ? Offset.zero : const Offset(0, 1.1),
        duration: const Duration(milliseconds: 420),
        curve: Curves.easeOutCubic,
        child: over
            ? ResultSheet(
                state: state,
                onMenu: _menu,
                onNext: () => _goNext(state),
                onShare: state.mode == GameMode.daily ? _shareDaily : null,
                stars: state.mode == GameMode.adventure && state.phase == GamePhase.solved ? _stars : null,
                runRecord: _runRecord,
                runBest: _runBest,
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _mobile(BuildContext context, GameState state, BoxConstraints c) {
    final tall = c.maxHeight >= 720;
    final top = [
      _GameHeader(state: state),
      const SizedBox(height: 14),
      _TimerBar(state: state, onPause: _ctrl.pause),
      const SizedBox(height: 8),
    ];
    final middle = [
      const SizedBox(height: 12),
      _formula(state),
      const SizedBox(height: 14),
      _Feedback(state: state, showHint: false),
      _palette(state),
      const SizedBox(height: 16),
    ];
    final actions = Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: _Actions(
        state: state,
        onUndo: _ctrl.undo,
        onSkip: _skip,
        onVerify: _verify,
        onRevealSolution: _revealAfterTimeUp,
        onHint: _hint,
        verifyKey: _verifyKey,
      ),
    );

    final content = Column(
      children: tall
          ? [...top, Expanded(child: _tree(state)), ...middle, actions]
          : [
              Expanded(
                child: ListView(
                  children: [
                    ...top,
                    SizedBox(height: 230, child: _tree(state)),
                    ...middle,
                  ],
                ),
              ),
              actions,
            ],
    );

    return Stack(
      children: [
        ContentWidth(
          child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 0), child: content),
        ),
        Positioned(left: 0, right: 0, bottom: 0, child: ContentWidth(child: _sheet(state))),
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
                          if (ref.watch(settingsProvider.select((s) => s.showLiveValues)) &&
                              state.board.isComplete &&
                              v.result.ok) ...[
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 12,
                              children: [
                                Text(l.leftSide(v.left!.display(decimalSeparator: sep))),
                                Text(l.rightSide(v.right!.display(decimalSeparator: sep))),
                                Text(
                                  v.isTrue ? l.equalityTrue : l.equalityFalse,
                                  style: TextStyle(color: v.isTrue ? bp.ok : bp.danger),
                                ),
                              ],
                            ),
                          ],
                          const SizedBox(height: 12),
                          _Feedback(state: state, showHint: false),
                          _palette(state),
                          const SizedBox(height: 12),
                          _Actions(
                            state: state,
                            onUndo: _ctrl.undo,
                            onSkip: _skip,
                            onVerify: _verify,
                            onRevealSolution: _revealAfterTimeUp,
                            onHint: _hint,
                            verifyKey: _verifyKey,
                            showKeys: true,
                          ),
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

String _subtitle(BuildContext context, GameState s) {
  final l = context.l10n;
  final parts = [
    if (s.practice) l.practiceShort else s.mode.label(l).toLowerCase(),
    if (s.stage != null) l.adventureStage(s.stage!).toLowerCase(),
    s.level.label(l).toLowerCase(),
    if (s.run case final run?) ...[
      l.runPlates(run.solved),
      if (run.kind == ChallengeKind.clock) l.runStep(run.step + 1) else _hearts(run.lives),
    ],
  ];
  return parts.join(' · ');
}

String _hearts(int lives) => '${'♥' * lives}${'♡' * (ChallengeRun.startLives - lives).clamp(0, 3)}';

String ruleText(Restriction r, List<int> digits, AppLocalizations l) => switch (r.kind) {
  RestrictionKind.forbid => l.ruleForbid(_opLabel(r.op!)),
  RestrictionKind.require => l.ruleRequire(_opLabel(r.op!)),
  RestrictionKind.equalsAt => l.ruleEqualsAt(digits[r.gap!], digits[r.gap! + 1]),
};

String _opLabel(Enum op) => switch (op) {
  BinOp() => op.label,
  UnOp() => op.label,
  _ => op.name,
};

class _GameHeader extends StatelessWidget {
  const _GameHeader({required this.state});
  final GameState state;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      children: [
        const BrandHome(logoSize: 30, wordmark: false),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${context.l10n.infoNumber} ${state.number}',
                style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
              ),
              Text(
                _subtitle(context, state),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall?.copyWith(color: context.bp.muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        const LiveValuesToggle(size: 40),
        const SizedBox(width: 8),
        const HelpButton(size: 40),
        const SizedBox(width: 8),
        const SoundToggle(size: 40),
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
      decoration: BoxDecoration(
        border: Border(left: BorderSide(color: bp.lineSoft)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Eyebrow(label, opacity: 0.6),
          Text(value, style: t.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
    return Row(
      children: [
        const BrandHome(),
        const SizedBox(width: 16),
        cell(l.infoNumber, state.number),
        cell(l.infoDigits, state.board.digits.join(' · ')),
        cell(l.infoMode, state.mode.label(l).toUpperCase()),
        cell(l.infoLevel, state.level.label(l).toUpperCase()),
        if (state.stage != null) cell(l.adventureTrail, l.adventureStage(state.stage!).toUpperCase()),
        if (state.run case final run?)
          cell(
            l.runPlates(run.solved).toUpperCase(),
            run.kind == ChallengeKind.clock ? l.runStep(run.step + 1) : _hearts(run.lives),
          ),
        const SizedBox(width: 16),
        Expanded(
          child: _TimerBar(state: state, onPause: onPause),
        ),
        const SizedBox(width: 16),
        if (points != null && state.run == null)
          Tooltip(
            message: l.helpScoringTitle,
            child: InkWell(
              onTap: () => showHelpDialog(context, scoring: true),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                child: Text(l.pointsShort(points), style: t.labelLarge),
              ),
            ),
          ),
        const SizedBox(width: 12),
        const LiveValuesToggle(),
        const SizedBox(width: 8),
        const HelpButton(),
        const SizedBox(width: 8),
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
    final frac = (state.secondsLeft / state.clockLength).clamp(0.0, 1.0);
    if (state.practice) {
      return Row(
        children: [
          const Icon(Icons.all_inclusive, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(l.practiceTimer, style: t.labelMedium?.copyWith(color: bp.muted)),
          ),
          Text('${state.elapsed}s', style: t.labelMedium),
        ],
      );
    }
    final low = state.secondsLeft <= 10;
    final last = !state.timeUp && state.secondsLeft <= 5;
    final canPause = state.canPause && !state.pauseUsed && state.phase == GamePhase.playing && !state.timeUp;
    final announce = state.secondsLeft == 10 || state.secondsLeft == 5 || state.timeUp;
    return Row(
      children: [
        Icon(
          state.timeUp ? Icons.timer_off_outlined : (low ? Icons.warning_amber_rounded : Icons.timer_outlined),
          size: 18,
          color: low ? bp.accent : bp.ink,
        ),
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
        Semantics(
          liveRegion: announce,
          label: state.timeUp ? l.timeUp : l.secondsLeftA11y(state.secondsLeft),
          child: ExcludeSemantics(
            child: AnimatedScale(
              scale: last && state.secondsLeft.isOdd ? 1.25 : 1,
              duration: MediaQuery.disableAnimationsOf(context) ? Duration.zero : const Duration(milliseconds: 250),
              child: Text(
                state.timeUp
                    ? l.timeUp
                    : (last
                          ? '${state.secondsLeft}…'
                          : state.clockLength > 60
                          ? '${state.secondsLeft ~/ 60}:${(state.secondsLeft % 60).toString().padLeft(2, '0')}'
                          : '${state.secondsLeft}s'),
                style: t.labelMedium?.copyWith(
                  color: state.timeUp || low ? bp.accent : bp.ink,
                  fontWeight: low ? FontWeight.w700 : null,
                ),
              ),
            ),
          ),
        ),
        if (state.canPause) ...[
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
                  child: Row(
                    children: [
                      Icon(Icons.pause, size: 16, semanticLabel: l.pause),
                      const SizedBox(width: 4),
                      Text(
                        '${state.paused ? (state.pauseLeft ?? Level.pauseSeconds) : Level.pauseSeconds}s',
                        style: t.labelMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _Feedback extends StatelessWidget {
  const _Feedback({required this.state, required this.showHint});
  final GameState state;

  final bool showHint;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final v = state.verdict;

    Widget banner(IconData icon, String title, String body, Color color) => Semantics(
      liveRegion: true,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            border: Border.all(color: color),
            color: color.withValues(alpha: 0.12),
          ),
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
                      Text(
                        title,
                        style: t.labelLarge?.copyWith(fontWeight: FontWeight.w700, color: color),
                      ),
                    Text(body, style: t.bodySmall?.copyWith(height: 1.4)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );

    if (state.phase != GamePhase.playing) return const SizedBox.shrink();
    final rule = state.restriction;
    if (rule != null && state.ruleBroken) {
      return _Shake(child: banner(Icons.rule, l.ruleBroken, ruleText(rule, state.board.digits, l), bp.danger));
    }
    final other = _other(context, state, v, banner);
    if (rule == null) return other;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [banner(Icons.rule, l.ruleTitle, ruleText(rule, state.board.digits, l), bp.accent), other],
    );
  }

  Widget _other(
    BuildContext context,
    GameState state,
    Verdict v,
    Widget Function(IconData, String, String, Color) banner,
  ) {
    final l = context.l10n;
    final bp = context.bp;
    final sep = context.decimalSeparator;
    final error = v.result.error;
    if (error != null) {
      final (title, body) = evalErrorText(error, state.level, l, sep);
      return banner(Icons.error_outline, title, body, bp.danger);
    }
    if (state.wrongAttempt && v.left != null && v.right != null) {
      return _Shake(
        child: banner(
          Icons.close,
          l.wrongTitle,
          l.wrongBody(v.left!.display(decimalSeparator: sep), v.right!.display(decimalSeparator: sep)),
          bp.danger,
        ),
      );
    }
    if (state.hintsUsed > 0 && state.solution != null) {
      final h = HintInfo.from(state.number, state.solution!);
      final d = state.board.digits;
      final lines = [
        l.hintEquals(d[h.equalsGap], d[h.equalsGap + 1]),
        if (state.hintsUsed >= 2) l.hintLink(d[h.linkGap], d[h.linkGap + 1], h.linkOp.label),
      ];
      return banner(Icons.lightbulb_outline, l.hintTitle(state.hintsUsed), lines.join('\n'), bp.accent);
    }
    if (state.alreadySolved && state.board.linksMade == 0) {
      return banner(Icons.info_outline, '', l.alreadySolved, bp.accent);
    }
    if (showHint && state.board.linksMade == 0 && state.selection == null) {
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
    required this.onRevealSolution,
    required this.onHint,
    this.verifyKey,
    this.showKeys = false,
  });

  final GameState state;
  final VoidCallback onUndo;
  final VoidCallback onSkip;
  final VoidCallback onVerify;
  final VoidCallback onRevealSolution;
  final VoidCallback onHint;
  final Key? verifyKey;
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
    final timeUp = state.timeUp && playing && state.run == null;
    return Row(
      children: [
        BoxIconButton(icon: Icons.undo, tooltip: l.undo, size: 48, onPressed: playing && state.canUndo ? onUndo : null),
        const SizedBox(width: 8),
        if (!state.isChallenge) ...[
          _HintButton(state: state, onPressed: onHint, showKey: showKeys),
          const SizedBox(width: 8),
        ],
        Expanded(
          flex: 2,
          child: timeUp
              ? OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                  onPressed: onRevealSolution,
                  child: FittedBox(child: Text(l.seeSolutionShort)),
                )
              : OutlinedButton(
                  style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 8)),
                  onPressed: state.phase == GamePhase.playing ? onSkip : null,
                  child: FittedBox(
                    child: Text(switch (state.run?.kind) {
                      ChallengeKind.clock => l.runSkip(ChallengeRun.skipPenalty),
                      ChallengeKind.restricted => l.runSkipLife,
                      null => showKeys ? '${l.skip} · Esc' : l.skip,
                    }),
                  ),
                ),
        ),
        const SizedBox(width: 8),
        Expanded(
          flex: 3,
          child: FilledButton(
            key: verifyKey,
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
      decoration: BoxDecoration(
        color: bp.panel,
        border: Border.all(color: bp.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            left == null ? l.pausedTitle : '${l.pausedTitle} · ${left}s',
            style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 2),
          ),
          const SizedBox(height: 4),
          Text(l.pausedBody, style: t.bodySmall?.copyWith(color: bp.muted)),
          const SizedBox(height: 12),
          FilledButton.icon(onPressed: onResume, icon: const Icon(Icons.play_arrow), label: Text(l.resume)),
        ],
      ),
    );
  }
}

class _HintButton extends StatelessWidget {
  const _HintButton({required this.state, required this.onPressed, this.showKey = false});
  final GameState state;
  final VoidCallback onPressed;
  final bool showKey;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final left = 3 - state.hintsUsed;
    final tooltip = state.hintsUsed == 2 ? l.hintTooltipReveal : l.hintTooltip(state.hintsUsed + 1);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        BoxIconButton(
          icon: Icons.lightbulb_outline,
          tooltip: showKey ? '$tooltip · H' : tooltip,
          size: 48,
          onPressed: state.canHint ? onPressed : null,
        ),
        if (state.phase == GamePhase.playing)
          Positioned(
            right: -4,
            top: -4,
            child: IgnorePointer(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                color: left > 0 ? bp.ink : bp.faint,
                child: Text('$left', style: Theme.of(context).textTheme.labelSmall?.copyWith(color: bp.onInk)),
              ),
            ),
          ),
      ],
    );
  }
}

class _Shake extends StatelessWidget {
  const _Shake({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 420),
      builder: (context, t, child) {
        final dx = math.sin(t * math.pi * 6) * 8 * (1 - t);
        return Transform.translate(offset: Offset(dx, 0), child: child);
      },
      child: child,
    );
  }
}
