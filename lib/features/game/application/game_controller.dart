import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/prefs.dart';
import '../domain/board.dart';
import '../domain/evaluator.dart';
import '../domain/expr.dart';
import '../domain/level.dart';

enum GameMode { educational, random, specific, challenges, adventure }

enum GamePhase { playing, solved }

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
  const NodeSelection(this.nodeId);
  final int nodeId;

  @override
  bool operator ==(Object other) => other is NodeSelection && other.nodeId == nodeId;
  @override
  int get hashCode => nodeId.hashCode;
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

  String get number => board.number;
  bool get timeUp => secondsLeft <= 0;
  bool get canUndo => history.isNotEmpty && phase == GamePhase.playing;

  Verdict get verdict => board.verdict(level);

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
  }) =>
      GameState(
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
      };

  factory GameState.fromJson(Map<String, dynamic> j) {
    final phase = GamePhase.values.byName(j['phase'] as String);
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
    );
  }
}

enum CheckResult { notReady, error, wrong, right }

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

  void _tick() {
    final s = state;
    if (s == null || s.phase != GamePhase.playing) return;
    if (s.paused) {
      if (s.pauseLeft == null) return;
      final left = s.pauseLeft! - 1;
      state = left <= 0 ? s.copyWith(paused: false, clearPauseLeft: true) : s.copyWith(pauseLeft: left);
      return;
    }
    state = s.copyWith(
      elapsed: s.elapsed + 1,
      secondsLeft: s.secondsLeft > 0 ? s.secondsLeft - 1 : 0,
    );
  }

  void start({
    required GameMode mode,
    required Level level,
    required String number,
    bool alreadySolved = false,
  }) {
    _ensureTimer();
    state = GameState(
      mode: mode,
      level: level,
      board: Board.start(number),
      secondsLeft: level.seconds,
      alreadySolved: alreadySolved,
    );
  }

  void clear() => state = null;

  void selectGap(int gap) {
    final s = _editable;
    if (s == null) return;
    state = s.copyWith(selection: GapSelection(gap));
  }

  void selectNode(int nodeId) {
    final s = _editable;
    if (s == null) return;
    final already = s.selection == NodeSelection(nodeId);
    state = already ? s.copyWith(clearSelection: true) : s.copyWith(selection: NodeSelection(nodeId));
  }

  void cycleSelection({bool backwards = false}) {
    final s = _editable;
    if (s == null) return;
    final targets = <Selection>[
      for (var g = 0; g < s.board.gapCount; g++)
        if (s.board.canLink(g) || s.board.canPlaceEquals(g)) GapSelection(g),
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
      default:
        return;
    }
  }

  void placeEquals() {
    final s = _editable;
    if (s == null) return;
    final sel = s.selection;
    if (sel is GapSelection && s.board.canPlaceEquals(sel.gap)) {
      _commit(s, s.board.placeEquals(sel.gap));
    }
  }

  void applyUnary(UnOp op) {
    final s = _editable;
    final sel = s?.selection;
    if (s == null || sel is! NodeSelection) return;
    final next = s.board.applyUnary(sel.nodeId, op);
    _commit(s, next, select: NodeSelection(next.nextId - 1));
  }

  void removeUnary() {
    final s = _editable;
    final sel = s?.selection;
    if (s == null || sel is! NodeSelection) return;
    final node = s.board.find(sel.nodeId);
    if (node is! Unary) return;
    _commit(s, s.board.unwrap(sel.nodeId), select: NodeSelection(node.child.id));
  }

  void toggleParens() {
    final s = _editable;
    final sel = s?.selection;
    if (s == null || sel is! NodeSelection) return;
    _commit(s, s.board.toggleParens(sel.nodeId), select: sel);
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
    if (s == null || s.pauseUsed) return;
    state = s.copyWith(paused: true, pauseUsed: true, pauseLeft: Level.pauseSeconds);
  }

  void resume() {
    final s = state;
    if (s == null || !s.paused) return;
    state = s.copyWith(paused: false, clearPauseLeft: true);
  }

  CheckResult check() {
    final s = _editable;
    if (s == null || !s.board.isComplete) return CheckResult.notReady;
    final v = s.verdict;
    if (!v.result.ok) return CheckResult.error;
    if (!v.isTrue) {
      state = s.copyWith(wrongAttempt: true);
      return CheckResult.wrong;
    }
    final inTime = !s.timeUp;
    final points = s.alreadySolved ? 0 : s.level.pointsFor(secondsLeft: s.secondsLeft, inTime: inTime);
    state = s.copyWith(
      phase: GamePhase.solved,
      clearSelection: true,
      solvedInTime: inTime,
      pointsEarned: points,
      saveStatus: SaveStatus.saving,
    );
    return CheckResult.right;
  }

  void setSaveResult(SaveStatus status, {int? totalPoints, int? pointsEarned}) {
    final s = state;
    if (s == null) return;
    state = s.copyWith(saveStatus: status, totalPoints: totalPoints, pointsEarned: pointsEarned);
  }
}

final gameControllerProvider = NotifierProvider<GameController, GameState?>(GameController.new);
