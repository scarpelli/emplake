import 'dart:math' as math;

import 'board.dart';
import 'expr.dart';
import 'level.dart';
import 'number_value.dart';

enum EvalErrorKind {
  divisionByZero,
  nonIntegerDivision,
  factorialDomain,
  factorialTooLarge,
  evenRootOfNegative,
  zeroToNegativePower,
  complexPower,
  tooLarge,
  operatorNotAllowed,
}

class EvalError {
  const EvalError(this.kind, this.nodeId, {this.left, this.right, this.result});

  final EvalErrorKind kind;
  final int nodeId;

  final NumValue? left;
  final NumValue? right;
  final NumValue? result;
}

class EvalResult {
  const EvalResult(this.values, this.error);

  final Map<int, NumValue> values;

  final EvalError? error;

  bool get ok => error == null;
}

class _Fail implements Exception {
  _Fail(this.error);
  final EvalError error;
}

class Evaluator {
  const Evaluator(this.level);

  final Level level;

  static const maxFactorial = 20;
  static const maxBits = 3400;

  EvalResult evaluateBoard(Board board) {
    final values = <int, NumValue>{};
    EvalError? first;
    for (final block in board.blocks) {
      try {
        _eval(block, values);
      } on _Fail catch (f) {
        first ??= f.error;
      }
    }
    return EvalResult(values, first);
  }

  EvalResult evaluate(Node node) {
    final values = <int, NumValue>{};
    try {
      _eval(node, values);
      return EvalResult(values, null);
    } on _Fail catch (f) {
      return EvalResult(values, f.error);
    }
  }

  bool isSolution(Board board) => board.verdict(level).isTrue;

  NumValue _eval(Node node, Map<int, NumValue> values) {
    final NumValue v;
    switch (node) {
      case Leaf(:final digit):
        v = NumValue.int(digit);
      case Binary(:final op, :final left, :final right):
        NumValue? a, b;
        _Fail? fail;
        try {
          a = _eval(left, values);
        } on _Fail catch (f) {
          fail = f;
        }
        try {
          b = _eval(right, values);
        } on _Fail catch (f) {
          fail ??= f;
        }
        if (fail != null) throw fail;
        if (!level.binary.contains(op)) {
          throw _Fail(EvalError(EvalErrorKind.operatorNotAllowed, node.id));
        }
        v = _binary(node.id, op, a!, b!);
      case Unary(:final op, :final child):
        final c = _eval(child, values);
        if (!level.unary.contains(op)) {
          throw _Fail(EvalError(EvalErrorKind.operatorNotAllowed, node.id));
        }
        v = _unary(node.id, op, c);
    }
    _checkSize(node.id, v);
    values[node.id] = v;
    return v;
  }

  void _checkSize(int id, NumValue v) {
    if (v.exact != null && v.exact!.bitLength > maxBits) {
      throw _Fail(EvalError(EvalErrorKind.tooLarge, id));
    }
    if (v.approx != null && !v.approx!.isFinite) {
      throw _Fail(EvalError(EvalErrorKind.tooLarge, id));
    }
  }

  NumValue _binary(int id, BinOp op, NumValue a, NumValue b) {
    final ea = a.exact, eb = b.exact;
    switch (op) {
      case BinOp.add:
        return ea != null && eb != null ? NumValue.exact(ea + eb) : NumValue.approx(a.asDouble + b.asDouble);
      case BinOp.sub:
        return ea != null && eb != null ? NumValue.exact(ea - eb) : NumValue.approx(a.asDouble - b.asDouble);
      case BinOp.mul:
        return ea != null && eb != null ? NumValue.exact(ea * eb) : NumValue.approx(a.asDouble * b.asDouble);
      case BinOp.div:
        if (b.isZero()) throw _Fail(EvalError(EvalErrorKind.divisionByZero, id, left: a, right: b));
        final result = ea != null && eb != null ? NumValue.exact(ea / eb) : NumValue.approx(a.asDouble / b.asDouble);
        if (!level.allowsFractionalDivision && !result.isIntegral) {
          throw _Fail(EvalError(EvalErrorKind.nonIntegerDivision, id, left: a, right: b, result: result));
        }
        return result;
      case BinOp.pow:
        return _pow(id, a, b);
    }
  }

  NumValue _pow(int id, NumValue a, NumValue b) {
    final exp = b.exact;
    if (a.exact != null && exp != null && exp.isInteger) {
      final base = a.exact!;
      final e = exp.num;
      if (base.isZero && e.isNegative) {
        throw _Fail(EvalError(EvalErrorKind.zeroToNegativePower, id));
      }
      if (base.isZero) return NumValue.exact(e == BigInt.zero ? Rational.fromInt(1) : base);
      final bits = math.max(base.num.abs().bitLength, base.den.bitLength);
      final absBase = base.abs();
      final trivial = absBase == Rational.fromInt(1);
      if (!trivial && e.abs() * BigInt.from(bits) > BigInt.from(maxBits)) {
        throw _Fail(EvalError(EvalErrorKind.tooLarge, id));
      }
      final n = e.abs().toInt();
      var r = Rational(base.num.pow(n), base.den.pow(n));
      if (e.isNegative) r = Rational.fromInt(1) / r;
      return NumValue.exact(r);
    }
    final x = a.asDouble, y = b.asDouble;
    if (x == 0 && y < 0) throw _Fail(EvalError(EvalErrorKind.zeroToNegativePower, id));
    if (x < 0 && !b.isIntegral) throw _Fail(EvalError(EvalErrorKind.complexPower, id));
    final r = math.pow(x, y).toDouble();
    if (!r.isFinite) throw _Fail(EvalError(EvalErrorKind.tooLarge, id));
    return NumValue.approx(r);
  }

  NumValue _unary(int id, UnOp op, NumValue c) {
    final e = c.exact;
    switch (op) {
      case UnOp.neg:
        return e != null ? NumValue.exact(-e) : NumValue.approx(-c.asDouble);
      case UnOp.abs:
        return e != null ? NumValue.exact(e.abs()) : NumValue.approx(c.asDouble.abs());
      case UnOp.floor:
        return NumValue.exact(Rational(e != null ? e.floor() : _floorApprox(c.asDouble)));
      case UnOp.ceil:
        return NumValue.exact(Rational(e != null ? e.ceil() : -_floorApprox(-c.asDouble)));
      case UnOp.sqrt:
        if (c.isNegative() && !c.isZero()) {
          throw _Fail(EvalError(EvalErrorKind.evenRootOfNegative, id));
        }
        if (e != null) {
          final n = _iroot(e.num, 2), d = _iroot(e.den, 2);
          if (n != null && d != null) return NumValue.exact(Rational(n, d));
        }
        return NumValue.approx(math.sqrt(c.asDouble));
      case UnOp.cbrt:
        if (e != null) {
          final neg = e.isNegative;
          final n = _iroot(e.num.abs(), 3), d = _iroot(e.den, 3);
          if (n != null && d != null) return NumValue.exact(Rational(neg ? -n : n, d));
        }
        final x = c.asDouble;
        final r = math.pow(x.abs(), 1 / 3).toDouble();
        return NumValue.approx(x < 0 ? -r : r);
      case UnOp.fact:
        final n = c.asInteger;
        if (n == null || n.isNegative) throw _Fail(EvalError(EvalErrorKind.factorialDomain, id));
        if (n > BigInt.from(maxFactorial)) throw _Fail(EvalError(EvalErrorKind.factorialTooLarge, id));
        var r = BigInt.one;
        for (var i = 2; i <= n.toInt(); i++) {
          r *= BigInt.from(i);
        }
        return NumValue.exact(Rational(r));
    }
  }

  static BigInt _floorApprox(double x) {
    final r = x.roundToDouble();
    if ((x - r).abs() < 1e-9) return BigInt.from(r);
    return BigInt.from(x.floorToDouble());
  }

  static BigInt? _iroot(BigInt n, int k) {
    if (n.isNegative) return null;
    if (n < BigInt.two) return n;
    var x = BigInt.one << ((n.bitLength + k - 1) ~/ k);
    final bk = BigInt.from(k);
    while (true) {
      final y = ((bk - BigInt.one) * x + n ~/ x.pow(k - 1)) ~/ bk;
      if (y >= x) break;
      x = y;
    }
    return x.pow(k) == n ? x : null;
  }
}

class Verdict {
  const Verdict({required this.result, this.left, this.right});

  final EvalResult result;
  final NumValue? left;
  final NumValue? right;

  bool get isTrue => result.ok && left != null && right != null && left!.equals(right!);
}

extension BoardVerdict on Board {
  Verdict verdict(Level level) {
    final result = Evaluator(level).evaluateBoard(this);
    if (!isComplete) return Verdict(result: result);
    return Verdict(result: result, left: result.values[blocks[0].id], right: result.values[blocks[1].id]);
  }
}
