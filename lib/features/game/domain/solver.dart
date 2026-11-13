import 'dart:math' as math;

import 'board.dart';
import 'evaluator.dart';
import 'expr.dart';
import 'level.dart';
import 'solution_codec.dart';

class SolveResult {
  const SolveResult({
    required this.number,
    required this.level,
    this.solution,
    this.ways = 0,
    this.matches = 0,
    this.size = 0,
  });

  final String number;
  final Level level;

  final String? solution;

  final int ways;

  final int matches;

  final int size;

  bool get solvable => solution != null;

  int get difficulty => (size - 6) * 50 + math.max<int>(0, 30 - matches) - 15 * _count('0') - 5 * _count('1');

  int _count(String digit) => digit.allMatches(number).length;

  int get stars {
    if (!solvable) return 0;
    if (size >= 8) return 3;
    if (size == 7) return _count('0') > 0 ? 1 : 2;
    final many = switch (level) {
      Level.easy => 15,
      Level.intermediate => 12,
      Level.advanced => 10,
      Level.hard => 5,
    };
    return matches >= many || _count('0') > 0 ? 1 : 2;
  }

  Board board() => SolutionCodec.decode(number, solution!);
}

class Solver {
  Solver(this.level);

  final Level level;

  static const _limit = 1000000;
  static const _maxFactorial = 10;
  static const _maxWays = 1000000000;

  late final _binOps = [
    for (final op in BinOp.values)
      if (level.binary.contains(op)) op,
  ];
  late final _unOps = [
    for (final op in UnOp.values)
      if (level.unary.contains(op)) op,
  ];
  late final _evaluator = Evaluator(level);

  SolveResult solve(String number) {
    final digits = number.split('').map(int.parse).toList();
    final n = digits.length;
    final spans = List.generate(n, (_) => List<Map<int, _Entry>?>.filled(n, null));
    for (var i = 0; i < n; i++) {
      final leaf = <int, _Entry>{};
      _add(leaf, _Entry(_Q(digits[i], 1), Leaf(0, digits[i], i), 1, 1));
      _closeUnary(leaf, depth: 2);
      spans[i][i] = leaf;
    }
    for (var len = 2; len <= n - 1; len++) {
      for (var i = 0; i + len - 1 < n; i++) {
        final j = i + len - 1;
        final out = <int, _Entry>{};
        for (var k = i; k < j; k++) {
          _combine(spans[i][k]!, spans[k + 1][j]!, out);
        }
        _closeUnary(out, depth: 1);
        spans[i][j] = out;
      }
    }

    final candidates = <(int, Node, Node)>[];
    var ways = 0;
    final matched = <String>{};
    for (var k = 0; k < n - 1; k++) {
      final left = spans[0][k]!, right = spans[k + 1][n - 1]!;
      for (final e in left.entries) {
        final r = right[e.key];
        if (r == null) continue;
        ways = math.min(_maxWays, ways + e.value.ways * r.ways);
        matched.add('$k:${e.key}');
        candidates.add((e.value.size + r.size, e.value.node, r.node));
      }
    }
    candidates.sort((a, b) => a.$1.compareTo(b.$1));
    for (final (size, l, r) in candidates.take(40)) {
      final text = SolutionCodec.encode(l, r);
      final board = SolutionCodec.decode(number, text);
      if (_evaluator.isSolution(board)) {
        return SolveResult(
          number: number,
          level: level,
          solution: text,
          ways: ways,
          matches: matched.length,
          size: size,
        );
      }
    }
    return SolveResult(number: number, level: level);
  }

  void _add(Map<int, _Entry> map, _Entry e) {
    final key = e.value.key;
    final old = map[key];
    if (old == null) {
      map[key] = e;
    } else {
      old.ways = math.min(_maxWays, old.ways + e.ways);
      if (e.size < old.size) {
        old
          ..node = e.node
          ..size = e.size;
      }
    }
  }

  void _combine(Map<int, _Entry> a, Map<int, _Entry> b, Map<int, _Entry> out) {
    for (final x in a.values) {
      for (final y in b.values) {
        for (final op in _binOps) {
          final v = _binary(op, x.value, y.value);
          if (v == null) continue;
          _add(out, _Entry(v, Binary(0, op, x.node, y.node), x.size + y.size + 1, x.ways * y.ways));
        }
      }
    }
  }

  void _closeUnary(Map<int, _Entry> map, {required int depth}) {
    var frontier = map.values.toList();
    for (var d = 0; d < depth; d++) {
      final next = <_Entry>[];
      for (final e in frontier) {
        for (final op in _unOps) {
          final v = _unary(op, e.value);
          if (v == null || v.key == e.value.key) continue;
          final added = _Entry(v, Unary(0, op, e.node), e.size + 1, e.ways);
          final isNew = !map.containsKey(v.key);
          _add(map, added);
          if (isNew) next.add(map[v.key]!);
        }
      }
      frontier = next;
    }
  }

  _Q? _binary(BinOp op, _Q a, _Q b) {
    switch (op) {
      case BinOp.add:
        return _Q.make(a.n * b.d + b.n * a.d, a.d * b.d);
      case BinOp.sub:
        return _Q.make(a.n * b.d - b.n * a.d, a.d * b.d);
      case BinOp.mul:
        return _Q.make(a.n * b.n, a.d * b.d);
      case BinOp.div:
        if (b.n == 0) return null;
        final r = _Q.make(a.n * b.d, a.d * b.n);
        if (r != null && !level.allowsFractionalDivision && r.d != 1) return null;
        return r;
      case BinOp.pow:
        if (b.d != 1) return null;
        final e = b.n;
        if (a.n == 0) return e < 0 ? null : (e == 0 ? const _Q(1, 1) : const _Q(0, 1));
        if (e.abs() > 20) return (a.n.abs() == 1 && a.d == 1) ? _Q.make(e.isEven ? 1 : a.n, 1) : null;
        final estimate = e.abs() * math.log(math.max(a.n.abs(), a.d)) / math.ln10;
        if (estimate > 6) return null;
        var num = 1, den = 1;
        for (var i = 0; i < e.abs(); i++) {
          num *= a.n;
          den *= a.d;
        }
        return e >= 0 ? _Q.make(num, den) : _Q.make(den, num);
    }
  }

  _Q? _unary(UnOp op, _Q c) {
    switch (op) {
      case UnOp.neg:
        return _Q.make(-c.n, c.d);
      case UnOp.abs:
        return _Q.make(c.n.abs(), c.d);
      case UnOp.floor:
        return _Q.make(_floorDiv(c.n, c.d), 1);
      case UnOp.ceil:
        return _Q.make(-_floorDiv(-c.n, c.d), 1);
      case UnOp.sqrt:
        if (c.n < 0) return null;
        final n = _iroot(c.n, 2), d = _iroot(c.d, 2);
        return n == null || d == null ? null : _Q.make(n, d);
      case UnOp.cbrt:
        final n = _iroot(c.n.abs(), 3), d = _iroot(c.d, 3);
        return n == null || d == null ? null : _Q.make(c.n < 0 ? -n : n, d);
      case UnOp.fact:
        if (c.d != 1 || c.n < 0 || c.n > _maxFactorial) return null;
        var r = 1;
        for (var i = 2; i <= c.n; i++) {
          r *= i;
        }
        return _Q.make(r, 1);
    }
  }

  static int _floorDiv(int a, int b) {
    final q = a ~/ b;
    return (a % b != 0 && (a < 0) != (b < 0)) ? q - 1 : q;
  }

  static int? _iroot(int n, int k) {
    if (n < 0) return null;
    final r = math.pow(n, 1 / k).round();
    for (final c in [r - 1, r, r + 1]) {
      if (c >= 0 && math.pow(c, k) == n) return c;
    }
    return null;
  }
}

class _Entry {
  _Entry(this.value, this.node, this.size, this.ways);

  final _Q value;
  Node node;
  int size;
  int ways;
}

class _Q {
  const _Q(this.n, this.d);

  final int n;
  final int d;

  static _Q? make(int n, int d) {
    if (d == 0) return null;
    if (d < 0) {
      n = -n;
      d = -d;
    }
    final g = _gcd(n.abs(), d);
    if (g > 1) {
      n ~/= g;
      d ~/= g;
    }
    if (n.abs() > Solver._limit || d > Solver._limit) return null;
    return _Q(n, d);
  }

  static int _gcd(int a, int b) {
    while (b != 0) {
      final t = a % b;
      a = b;
      b = t;
    }
    return a == 0 ? 1 : a;
  }

  int get key => (n + Solver._limit) * (Solver._limit + 1) + d;
}
