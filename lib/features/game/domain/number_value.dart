import 'dart:math' as math;

class Rational implements Comparable<Rational> {
  Rational._(this.num, this.den);

  factory Rational(BigInt num, [BigInt? den]) {
    den ??= BigInt.one;
    if (den == BigInt.zero) {
      throw ArgumentError('denominator must not be zero');
    }
    if (den.isNegative) {
      num = -num;
      den = -den;
    }
    final g = num.gcd(den);
    if (g > BigInt.one) {
      num = num ~/ g;
      den = den ~/ g;
    }
    return Rational._(num, den);
  }

  factory Rational.fromInt(int value) => Rational(BigInt.from(value));

  final BigInt num;
  final BigInt den;

  bool get isInteger => den == BigInt.one;
  bool get isZero => num == BigInt.zero;
  bool get isNegative => num.isNegative;

  Rational operator +(Rational o) => Rational(num * o.den + o.num * den, den * o.den);
  Rational operator -(Rational o) => Rational(num * o.den - o.num * den, den * o.den);
  Rational operator *(Rational o) => Rational(num * o.num, den * o.den);
  Rational operator /(Rational o) => Rational(num * o.den, den * o.num);
  Rational operator -() => Rational._(-num, den);
  Rational abs() => isNegative ? -this : this;

  BigInt floor() {
    if (isInteger) return num;
    final q = num ~/ den;
    return isNegative ? q - BigInt.one : q;
  }

  BigInt ceil() {
    if (isInteger) return num;
    final q = num ~/ den;
    return isNegative ? q : q + BigInt.one;
  }

  double toDouble() => num.toDouble() / den.toDouble();

  int get bitLength => math.max(num.bitLength, den.bitLength);

  @override
  int compareTo(Rational o) => (num * o.den).compareTo(o.num * den);

  @override
  bool operator ==(Object other) => other is Rational && other.num == num && other.den == den;

  @override
  int get hashCode => Object.hash(num, den);

  @override
  String toString() => isInteger ? '$num' : '$num/$den';
}

class NumValue {
  const NumValue.exact(Rational this.exact) : approx = null;
  const NumValue.approx(double this.approx) : exact = null;

  factory NumValue.int(int v) => NumValue.exact(Rational.fromInt(v));

  final Rational? exact;
  final double? approx;

  bool get isExact => exact != null;
  double get asDouble => exact?.toDouble() ?? approx!;

  bool get isIntegral {
    if (exact != null) return exact!.isInteger;
    final d = approx!;
    return d.isFinite && (d - d.roundToDouble()).abs() < 1e-9;
  }

  BigInt? get asInteger {
    if (!isIntegral) return null;
    if (exact != null) return exact!.num;
    return BigInt.from(approx!.round());
  }

  bool isNegative() => exact?.isNegative ?? approx! < 0;
  bool isZero() => exact?.isZero ?? approx!.abs() < 1e-12;

  bool equals(NumValue other) {
    if (exact != null && other.exact != null) return exact == other.exact;
    final a = asDouble, b = other.asDouble;
    if (!a.isFinite || !b.isFinite) return false;
    final scale = math.max(1.0, math.max(a.abs(), b.abs()));
    return (a - b).abs() <= 1e-9 * scale;
  }

  String display({String decimalSeparator = ','}) {
    if (exact != null) {
      final r = exact!;
      if (r.isInteger) {
        final s = r.num.toString();
        return s.length > 12 ? _sci(r.toDouble(), decimalSeparator) : s.replaceFirst('-', '−');
      }
      if (_isTerminating(r.den) && r.den <= BigInt.from(10000)) {
        return _decimal(r.toDouble(), decimalSeparator);
      }
      return '${r.num}/${r.den}'.replaceFirst('-', '−');
    }
    final d = approx!;
    if (isIntegral) return '≈${d.round()}'.replaceFirst('-', '−');
    return '≈${_decimal(d, decimalSeparator)}';
  }

  static bool _isTerminating(BigInt den) {
    var d = den;
    final two = BigInt.two, five = BigInt.from(5);
    while (d % two == BigInt.zero) {
      d = d ~/ two;
    }
    while (d % five == BigInt.zero) {
      d = d ~/ five;
    }
    return d == BigInt.one;
  }

  static String _decimal(double d, String sep) {
    if (d.abs() >= 1e12) return _sci(d, sep);
    var s = d.toStringAsFixed(4);
    s = s.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
    return s.replaceFirst('.', sep).replaceFirst('-', '−');
  }

  static String _sci(double d, String sep) =>
      d.toStringAsExponential(3).replaceFirst('.', sep).replaceFirst('-', '−');

  @override
  String toString() => display(decimalSeparator: '.');
}
