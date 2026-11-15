import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/prefs.dart';
import '../domain/adventure.dart';
import '../domain/board.dart';
import '../domain/challenge.dart';
import '../domain/evaluator.dart';
import '../domain/expr.dart';
import '../domain/level.dart';
import '../domain/rules.dart';
import '../domain/solution_codec.dart';

enum GameMode { educational, random, specific, challenges, adventure, daily }

enum GamePhase { playing, solved, revealed }

enum SaveStatus { none, saving, savedNew, savedReplay, failed }

sealed class Selection {
  const Selection();
}

class GapSelection extends Selection {
  const GapSelection(this.gap);
  final int gap;

  @override
  bool operator ==(Object other) => other is GapSelection && other.gap == gap;
  @override
  int get hashCode => gap.hashCode;
}

class NodeSelection extends Selection {
  const NodeSelection(this.nodeId, {this.picked = false});
  final int nodeId;

  final bool picked;

  @override
  bool operator ==(Object other) => other is NodeSelection && other.nodeId == nodeId;
  @override
  int get hashCode => nodeId.hashCode;
}

class EqualsSelection extends Selection {
  const EqualsSelection();

  @override
  bool operator ==(Object other) => other is EqualsSelection;
  @override
  int get hashCode => 0;
}

sealed class SignDrag {
  const SignDrag();
}

class PaletteBinaryDrag extends SignDrag {
  const PaletteBinaryDrag(this.op);
  final BinOp op;
}

class PaletteEqualsDrag extends SignDrag {
  const PaletteEqualsDrag();
}

class PaletteUnaryDrag extends SignDrag {
  const PaletteUnaryDrag(this.op);
  final UnOp op;
}

class PaletteParensDrag extends SignDrag {
  const PaletteParensDrag();
}

extension SignDragKind on SignDrag {
  bool get goesOnNode => this is PaletteUnaryDrag || this is PaletteParensDrag;
}

class MoveBinaryDrag extends SignDrag {
  const MoveBinaryDrag(this.nodeId, this.fromGap);
  final int nodeId;
  final int fromGap;
}

class MoveEqualsDrag extends SignDrag {
  const MoveEqualsDrag(this.fromGap);
  final int fromGap;
}

class CarrySelection extends Selection {
  const CarrySelection(this.drag);
  final SignDrag drag;

  BinOp? get op => switch (drag) {
    PaletteBinaryDrag(:final op) => op,
    _ => null,
  };

  UnOp? get unary => switch (drag) {
    PaletteUnaryDrag(:final op) => op,
    _ => null,
  };

  bool get isEquals => drag is PaletteEqualsDrag;
  bool get isParens => drag is PaletteParensDrag;

  @override
  bool operator ==(Object other) =>
      other is CarrySelection &&
      other.op == op &&
      other.unary == unary &&
      other.isEquals == isEquals &&
      other.isParens == isParens;
  @override
  int get hashCode => Object.hash(op, unary, isEquals, isParens);
}

class GameState {
  const GameState({
    required this.mode,
    required this.level,
    required this.board,
    this.history = const [],
    this.selection,
    required this.secondsLeft,
    this.elapsed = 0,
    this.pauseUsed = false,
    this.paused = false,
    this.pauseLeft,
    this.phase = GamePhase.playing,
    this.wrongAttempt = false,
    this.alreadySolved = false,
    this.solvedInTime = true,
    this.pointsEarned = 0,
    this.totalPoints,
    this.saveStatus = SaveStatus.none,
    this.solution,
    this.hintsUsed = 0,
    this.sawLiveValues = true,
    this.streakUsed = 0,
    this.practice = false,
    this.run,
    this.restriction,
    this.stage,
    this.totalSeconds,
    this.ruleBroken = false,
  });

  final GameMode mode;
  final Level level;
  final Board board;
  final List<Board> history;
  final Selection? selection;

  final int secondsLeft;
  final int elapsed;

  final bool pauseUsed;
  final bool paused;

  final int? pauseLeft;

  final GamePhase phase;

  final bool wrongAttempt;

  final bool alreadySolved;

  final bool solvedInTime;
  final int pointsEarned;
  final int? totalPoints;
  final SaveStatus saveStatus;

  final String? solution;

  final int hintsUsed;

  final bool sawLiveValues;

  final int streakUsed;

  final bool practice;

  final ChallengeRun? run;

  final Restriction? restriction;

  final int? stage;

  final int? totalSeconds;

  final bool ruleBroken;

  bool get isChallenge => run != null;

  OpRules get rules => restriction?.rulesFor(level) ?? level;

  int get clockLength => totalSeconds ?? level.seconds;

  /// Practice, the plate of the day and the first stages of the Adventure run
  /// a stopwatch instead of a countdown: the time is measured but never runs out.
  bool get untimed => practice || mode == GameMode.daily || (mode == GameMode.adventure && AdventureProgress.isUntimed(stage));

  /// Seconds left as far as scoring goes. Untimed plates still reward speed:
  /// the bonus shrinks against the level clock but the plate never expires.
  int get scoringSecondsLeft => untimed ? (clockLength - elapsed).clamp(0, clockLength) : secondsLeft;

  bool get canHint => phase == GamePhase.playing && !paused && hintsUsed < 3 && !isChallenge;
  bool get canPause => !isChallenge && !untimed;

  Score get score => level.score(
    secondsLeft: scoringSecondsLeft,
    inTime: solvedInTime,
    hints: hintsUsed,
    blind: !sawLiveValues,
    streak: streakUsed,
  );

  String get number => board.number;
  bool get timeUp => !untimed && secondsLeft <= 0;
  bool get canUndo => history.isNotEmpty && phase == GamePhase.playing;

  Verdict get verdict => board.verdict(rules);

  GameState copyWith({
    Board? board,
    List<Board>? history,
    Selection? selection,
    bool clearSelection = false,
    int? secondsLeft,
    int? elapsed,
    bool? pauseUsed,
    bool? paused,
    int? pauseLeft,
    bool clearPauseLeft = false,
    GamePhase? phase,
    bool? wrongAttempt,
    bool? solvedInTime,
    int? pointsEarned,
    int? totalPoints,
    SaveStatus? saveStatus,
    int? hintsUsed,
    bool? sawLiveValues,
    int? streakUsed,
    String? solution,
    ChallengeRun? run,
    bool? ruleBroken,
  }) => GameState(
    mode: mode,
    level: level,
    board: board ?? this.board,
    history: history ?? this.history,
    selection: clearSelection ? null : (selection ?? this.selection),
    secondsLeft: secondsLeft ?? this.secondsLeft,
    elapsed: elapsed ?? this.elapsed,
    pauseUsed: pauseUsed ?? this.pauseUsed,
    paused: paused ?? this.paused,
    pauseLeft: clearPauseLeft ? null : (pauseLeft ?? this.pauseLeft),
    phase: phase ?? this.phase,
    wrongAttempt: wrongAttempt ?? this.wrongAttempt,
    alreadySolved: alreadySolved,
    solvedInTime: solvedInTime ?? this.solvedInTime,
    pointsEarned: pointsEarned ?? this.pointsEarned,
    totalPoints: totalPoints ?? this.totalPoints,
    saveStatus: saveStatus ?? this.saveStatus,
    solution: solution ?? this.solution,
    hintsUsed: hintsUsed ?? this.hintsUsed,
    sawLiveValues: sawLiveValues ?? this.sawLiveValues,
    streakUsed: streakUsed ?? this.streakUsed,
    practice: practice,
    run: run ?? this.run,
    restriction: restriction,
    stage: stage,
    totalSeconds: totalSeconds,
    ruleBroken: ruleBroken ?? this.ruleBroken,
  );

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'level': level.name,
    'board': board.toJson(),
    'history': [for (final b in history.take(30)) b.toJson()],
    'secondsLeft': secondsLeft,
    'elapsed': elapsed,
    'pauseUsed': pauseUsed,
    'phase': phase.name,
    'alreadySolved': alreadySolved,
    'solvedInTime': solvedInTime,
    'pointsEarned': pointsEarned,
    if (totalPoints != null) 'totalPoints': totalPoints,
    'saveStatus': saveStatus.name,
    'solution': ?solution,
    'hints': hintsUsed,
    'sawLive': sawLiveValues,
    'streakUsed': streakUsed,
    'practice': practice,
    if (run != null) 'run': run!.toJson(),
    if (restriction != null) 'rule': restriction!.encode(),
    'stage': ?stage,
    'total': ?totalSeconds,
  };

  factory GameState.fromJson(Map<String, dynamic> j) {
    var phase = GamePhase.values.byName(j['phase'] as String);
    var run = j['run'] == null ? null : ChallengeRun.fromJson((j['run'] as Map).cast<String, dynamic>());
    if (run != null && !run.over) {
      run = run.abandon();
      if (phase == GamePhase.playing) phase = GamePhase.revealed;
    }
    var save = SaveStatus.values.byName(j['saveStatus'] as String? ?? 'none');
    if (save == SaveStatus.saving) save = SaveStatus.failed;
    return GameState(
      mode: GameMode.values.byName(j['mode'] as String),
      level: Level.values.byName(j['level'] as String),
      board: Board.fromJson((j['board'] as Map).cast<String, dynamic>()),
      history: [
        for (final b in (j['history'] as List? ?? const [])) Board.fromJson((b as Map).cast<String, dynamic>()),
      ],
      secondsLeft: j['secondsLeft'] as int,
      elapsed: j['elapsed'] as int? ?? 0,
      pauseUsed: j['pauseUsed'] as bool? ?? false,
      paused: phase == GamePhase.playing,
      phase: phase,
      alreadySolved: j['alreadySolved'] as bool? ?? false,
      solvedInTime: j['solvedInTime'] as bool? ?? true,
      pointsEarned: j['pointsEarned'] as int? ?? 0,
      totalPoints: j['totalPoints'] as int?,
      saveStatus: save,
      solution: j['solution'] as String?,
      hintsUsed: j['hints'] as int? ?? 0,
      sawLiveValues: j['sawLive'] as bool? ?? true,
      streakUsed: j['streakUsed'] as int? ?? 0,
      practice: j['practice'] as bool? ?? false,
      run: run,
      restriction: j['rule'] == null ? null : Restriction.decode(j['rule'] as String),
      stage: j['stage'] as int?,
      totalSeconds: j['total'] as int?,
    );
  }
}

enum CheckResult { notReady, error, wrong, ruleBroken, right }

class GameController extends Notifier<GameState?> {
  Timer? _timer;

  @override
  GameState? build() {
    ref.onDispose(() => _timer?.cancel());
    final raw = ref.read(sharedPreferencesProvider).getString(PrefKeys.game);
    GameState? restored;
    if (raw != null) {
      try {
        restored = GameState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
      } catch (_) {
        restored = null;
      }
    }
    _ensureTimer();
    return restored;
  }

  @override
  set state(GameState? value) {
    super.state = value;
    final prefs = ref.read(sharedPreferencesProvider);
    if (value == null) {
      prefs.remove(PrefKeys.game);
    } else {
      prefs.setString(PrefKeys.game, jsonEncode(value.toJson()));
    }
  }

  void _ensureTimer() {
    _timer ??= Timer.periodic(const Duration(seconds: 1), (_) => _tick());
  }

  int _holds = 0;

  bool _away = false;

  Future<T> whileHeld<T>(Future<T> Function() show) async {
    _holds++;
    try {
      return await show();
    } finally {
      _holds--;
    }
  }

  void setAway(bool away) => _away = away;

  void _tick() {
    final s = state;
    if (s == null || s.phase != GamePhase.playing || _holds > 0 || _away) return;
    if (s.paused) {
      if (s.pauseLeft == null) return;
      final left = s.pauseLeft! - 1;
      state = left <= 0 ? s.copyWith(paused: false, clearPauseLeft: true) : s.copyWith(pauseLeft: left);
      return;
    }
    final next = s.copyWith(
      elapsed: s.elapsed + 1,
      secondsLeft: s.untimed ? s.secondsLeft : (s.secondsLeft > 0 ? s.secondsLeft - 1 : 0),
    );
    if (next.run != null && next.secondsLeft <= 0) {
      _losePlate(next, next.run!.timeUp());
      return;
    }
    state = next;
  }

  void start({
    required GameMode mode,
    required Level level,
    required String number,
    bool alreadySolved = false,
    bool liveValues = true,
    bool practice = false,
    int? stage,
    ChallengeRun? run,
    Restriction? restriction,
    String? solution,
  }) {
    _ensureTimer();
    final clock = run?.kind == ChallengeKind.clock;
    state = GameState(
      mode: mode,
      level: level,
      board: Board.start(number),
      secondsLeft: clock ? run!.clock : level.seconds,
      totalSeconds: clock ? ChallengeRun.clockStart : null,
      alreadySolved: alreadySolved,
      sawLiveValues: liveValues,
      practice: practice,
      stage: stage,
      run: run,
      restriction: restriction,
      solution: solution,
    );
  }

  void _losePlate(GameState s, ChallengeRun run) {
    var board = s.board;
    if (s.solution != null) {
      try {
        board = SolutionCodec.decode(s.number, s.solution!);
      } on FormatException {
        board = s.board;
      }
    }
    state = s.copyWith(
      board: board,
      history: identical(board, s.board) ? null : [...s.history, s.board],
      phase: GamePhase.revealed,
      clearSelection: true,
      wrongAttempt: false,
      ruleBroken: false,
      run: run,
    );
  }

  void skipChallenge() {
    final s = _editable;
    if (s == null || s.run == null) return;
    _losePlate(s, s.run!.skip(secondsLeft: s.secondsLeft));
  }

  void markRunRecorded() {
    final s = state;
    if (s?.run == null) return;
    state = s!.copyWith(run: s.run!.markRecorded());
  }

  void noteLiveValuesShown() {
    final s = state;
    if (s == null || s.sawLiveValues || s.phase != GamePhase.playing) return;
    state = s.copyWith(sawLiveValues: true);
  }

  void useHint(String solution) {
    final s = state;
    if (s == null || !s.canHint) return;
    final next = s.hintsUsed + 1;
    state = s.copyWith(hintsUsed: next, solution: solution, wrongAttempt: false);
    if (next >= 3) reveal(solution);
  }

  void clear() => state = null;

  SignDrag? _inHand(GameState s) {
    switch (s.selection) {
      case CarrySelection(:final drag):
        return drag;
      case EqualsSelection() when s.board.eqDigitGap != null:
        return MoveEqualsDrag(s.board.eqDigitGap!);
      case NodeSelection(:final nodeId, picked: true):
        final node = s.board.find(nodeId);
        return node is Binary ? MoveBinaryDrag(nodeId, node.digitGap) : null;
      default:
        return null;
    }
  }

  bool _dropHere(GameState s, SignDrag drag, int gap) {
    final next = _dropped(s.board, drag, gap);
    if (identical(next, s.board)) return false;
    _commit(s, next);
    return true;
  }

  void selectGap(int gap) {
    final s = _editable;
    if (s == null) return;
    final hand = _inHand(s);
    if (hand != null && _dropHere(s, hand, s.board.digitGapOf(gap))) return;
    state = s.copyWith(selection: GapSelection(gap));
  }

  void selectEquals() {
    final s = _editable;
    if (s == null || s.board.eqGap == null) return;
    if (s.selection case CarrySelection(:final drag) when _dropHere(s, drag, s.board.eqDigitGap!)) return;
    final already = s.selection is EqualsSelection;
    state = already ? s.copyWith(clearSelection: true) : s.copyWith(selection: const EqualsSelection());
  }

  void selectNode(int nodeId) {
    final s = _editable;
    if (s == null) return;
    final node = s.board.find(nodeId);
    if (s.selection case CarrySelection(:final drag) when drag.goesOnNode) {
      if (dropOnNode(drag, nodeId)) return;
    }
    if (s.selection case CarrySelection(:final drag) when node is Binary) {
      if (_dropHere(s, drag, node.digitGap)) return;
    }
    final already = s.selection == NodeSelection(nodeId);
    state = already ? s.copyWith(clearSelection: true) : s.copyWith(selection: NodeSelection(nodeId, picked: true));
  }

  void _carry(GameState s, SignDrag drag) {
    final carry = CarrySelection(drag);
    state = s.selection == carry ? s.copyWith(clearSelection: true) : s.copyWith(selection: carry);
  }

  void cycleSelection({bool backwards = false}) {
    final s = _editable;
    if (s == null) return;
    final targets = <Selection>[
      for (var g = 0; g < s.board.gapCount; g++)
        if (s.board.canLink(g) || s.board.canPlaceEquals(g)) GapSelection(g),
      if (s.board.eqGap != null) const EqualsSelection(),
      for (final b in s.board.blocks)
        for (final n in b.descendants) NodeSelection(n.id),
    ];
    if (targets.isEmpty) return;
    final i = s.selection == null ? -1 : targets.indexOf(s.selection!);
    final next = backwards ? (i <= 0 ? targets.length - 1 : i - 1) : (i + 1) % targets.length;
    state = s.copyWith(selection: targets[next]);
  }

  GameState? get _editable {
    final s = state;
    if (s == null || s.phase != GamePhase.playing || s.paused) return null;
    return s;
  }

  void _commit(GameState s, Board next, {Selection? select}) {
    state = s.copyWith(
      board: next,
      history: [...s.history, s.board],
      selection: select,
      clearSelection: select == null,
      wrongAttempt: false,
      ruleBroken: false,
    );
  }

  void applyBinary(BinOp op) {
    final s = _editable;
    if (s == null) return;
    switch (s.selection) {
      case GapSelection(:final gap) when s.board.canLink(gap):
        final next = s.board.link(gap, op);
        _commit(s, next, select: NodeSelection(next.nextId - 1));
      case NodeSelection(:final nodeId) when s.board.find(nodeId) is Binary:
        final node = s.board.find(nodeId)! as Binary;
        if (node.op == op) return;
        _commit(s, s.board.changeBinary(nodeId, op), select: NodeSelection(nodeId));
      case EqualsSelection() when s.board.eqDigitGap != null:
        _dropHere(s, PaletteBinaryDrag(op), s.board.eqDigitGap!);
      default:
        _carry(s, PaletteBinaryDrag(op));
    }
  }

  void placeEquals() {
    final s = _editable;
    if (s == null) return;
    switch (s.selection) {
      case GapSelection(:final gap):
        _dropHere(s, const PaletteEqualsDrag(), s.board.digitGapOf(gap));
      case NodeSelection(:final nodeId) when s.board.find(nodeId) is Binary:
        _dropHere(s, const PaletteEqualsDrag(), (s.board.find(nodeId)! as Binary).digitGap);
      case EqualsSelection():
        return;
      default:
        _carry(s, const PaletteEqualsDrag());
    }
  }

  void applyUnary(UnOp op) {
    final s = _editable;
    if (s == null) return;
    final sel = s.selection;
    if (sel is NodeSelection) {
      dropOnNode(PaletteUnaryDrag(op), sel.nodeId);
    } else {
      _carry(s, PaletteUnaryDrag(op));
    }
  }

  bool dropOnNode(SignDrag drag, int nodeId) {
    final s = _editable;
    if (s == null || s.board.find(nodeId) == null) return false;
    switch (drag) {
      case PaletteUnaryDrag(:final op) when s.rules.unary.contains(op):
        final next = s.board.applyUnary(nodeId, op);
        _commit(s, next, select: NodeSelection(next.nextId - 1));
        return true;
      case PaletteParensDrag():
        _commit(s, s.board.toggleParens(nodeId), select: NodeSelection(nodeId));
        return true;
      default:
        return false;
    }
  }

  void removeUnary() {
    final s = _editable;
    final sel = s?.selection;
    if (s == null || sel is! NodeSelection) return;
    final node = s.board.find(sel.nodeId);
    if (node is! Unary) return;
    _commit(s, s.board.unwrap(sel.nodeId), select: NodeSelection(node.child.id));
  }

  bool removeSelected() {
    final s = _editable;
    if (s == null) return false;
    switch (s.selection) {
      case EqualsSelection() when s.board.eqGap != null:
        _commit(s, s.board.removeEquals());
        return true;
      case NodeSelection(:final nodeId):
        final node = s.board.find(nodeId);
        if (node is Unary) {
          _commit(s, s.board.unwrap(nodeId), select: NodeSelection(node.child.id));
          return true;
        }
        if (node is Binary) {
          _commit(s, s.board.unlink(nodeId));
          return true;
        }
        return false;
      default:
        return false;
    }
  }

  bool canDrop(SignDrag drag, int gap) {
    final s = _editable;
    if (s == null || gap < 0 || gap >= s.board.digits.length - 1) return false;
    return !identical(_dropped(s.board, drag, gap), s.board);
  }

  bool drop(SignDrag drag, int gap) {
    final s = _editable;
    if (s == null) return false;
    final next = _dropped(s.board, drag, gap);
    if (identical(next, s.board)) return false;
    _commit(s, next);
    return true;
  }

  void dropOutside(SignDrag drag) {
    final s = _editable;
    if (s == null) return;
    final from = switch (drag) {
      MoveBinaryDrag(:final fromGap) => fromGap,
      MoveEqualsDrag(:final fromGap) => fromGap,
      _ => null,
    };
    if (from == null) return;
    final next = s.board.clearGap(from);
    if (!identical(next, s.board)) _commit(s, next);
  }

  Board _dropped(Board b, SignDrag drag, int gap) {
    try {
      return switch (drag) {
        PaletteBinaryDrag(:final op) => b.dropBinary(op, gap),
        PaletteEqualsDrag() => b.dropEquals(gap),
        MoveBinaryDrag(:final nodeId) => b.moveBinary(nodeId, gap),
        MoveEqualsDrag() => b.moveEquals(gap),
        PaletteUnaryDrag() || PaletteParensDrag() => b,
      };
    } on StateError {
      return b;
    }
  }

  void toggleParens() {
    final s = _editable;
    if (s == null) return;
    final sel = s.selection;
    if (sel is NodeSelection) {
      dropOnNode(const PaletteParensDrag(), sel.nodeId);
    } else {
      _carry(s, const PaletteParensDrag());
    }
  }

  void undo() {
    final s = _editable;
    if (s == null || s.history.isEmpty) return;
    state = s.copyWith(
      board: s.history.last,
      history: s.history.sublist(0, s.history.length - 1),
      clearSelection: true,
      wrongAttempt: false,
    );
  }

  void pause() {
    final s = _editable;
    if (s == null || s.pauseUsed || !s.canPause) return;
    state = s.copyWith(paused: true, pauseUsed: true, pauseLeft: Level.pauseSeconds);
  }

  void resume() {
    final s = state;
    if (s == null || !s.paused) return;
    state = s.copyWith(paused: false, clearPauseLeft: true);
  }

  CheckResult check({int streak = 0}) {
    final s = _editable;
    if (s == null || !s.board.isComplete) return CheckResult.notReady;
    final v = s.verdict;
    if (!v.result.ok) return CheckResult.error;
    if (!v.isTrue) {
      state = s.copyWith(wrongAttempt: true);
      return CheckResult.wrong;
    }
    if (s.restriction != null && !s.restriction!.allows(s.board)) {
      state = s.copyWith(ruleBroken: true);
      return CheckResult.ruleBroken;
    }
    if (s.run != null) {
      state = s.copyWith(
        phase: GamePhase.solved,
        clearSelection: true,
        run: s.run!.solve(secondsLeft: s.secondsLeft),
      );
      return CheckResult.right;
    }
    final inTime = !s.timeUp;
    final points = s.alreadySolved || s.practice
        ? 0
        : s.level.pointsFor(
            secondsLeft: s.scoringSecondsLeft,
            inTime: inTime,
            hints: s.hintsUsed,
            blind: !s.sawLiveValues,
            streak: streak,
          );
    state = s.copyWith(
      phase: GamePhase.solved,
      clearSelection: true,
      solvedInTime: inTime,
      pointsEarned: points,
      streakUsed: streak,
      saveStatus: SaveStatus.saving,
    );
    return CheckResult.right;
  }

  void reveal(String solution) {
    final s = state;
    if (s == null || s.phase != GamePhase.playing) return;
    Board board;
    try {
      board = SolutionCodec.decode(s.number, solution);
    } on FormatException {
      return;
    }
    state = s.copyWith(
      board: board,
      history: [...s.history, s.board],
      phase: GamePhase.revealed,
      paused: false,
      clearSelection: true,
      wrongAttempt: false,
      solution: solution,
    );
  }

  void setSaveResult(SaveStatus status, {int? totalPoints, int? pointsEarned}) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(saveStatus: status, totalPoints: totalPoints, pointsEarned: pointsEarned);
  }
}

final gameControllerProvider = NotifierProvider<GameController, GameState?>(GameController.new);
