import 'expr.dart';
import 'rules.dart';

enum Level implements OpRules {
  easy(
    binary: {BinOp.add, BinOp.sub, BinOp.mul, BinOp.div, BinOp.pow},
    unary: {UnOp.neg, UnOp.sqrt, UnOp.cbrt, UnOp.fact, UnOp.abs, UnOp.floor, UnOp.ceil},
    allowsFractionalDivision: true,
    seconds: 45,
    basePoints: 5,
  ),
  intermediate(
    binary: {BinOp.add, BinOp.sub, BinOp.mul, BinOp.div, BinOp.pow},
    unary: {UnOp.neg, UnOp.sqrt, UnOp.cbrt, UnOp.fact, UnOp.abs},
    allowsFractionalDivision: false,
    seconds: 45,
    basePoints: 10,
  ),
  advanced(
    binary: {BinOp.add, BinOp.sub, BinOp.mul, BinOp.div},
    unary: {UnOp.neg, UnOp.sqrt, UnOp.fact, UnOp.abs},
    allowsFractionalDivision: false,
    seconds: 60,
    basePoints: 15,
  ),
  hard(
    binary: {BinOp.add, BinOp.sub, BinOp.mul, BinOp.div},
    unary: {UnOp.neg, UnOp.abs},
    allowsFractionalDivision: false,
    seconds: 75,
    basePoints: 20,
  );

  const Level({
    required this.binary,
    required this.unary,
    required this.allowsFractionalDivision,
    required this.seconds,
    required this.basePoints,
  });

  @override
  final Set<BinOp> binary;
  @override
  final Set<UnOp> unary;

  @override
  final bool allowsFractionalDivision;

  final int seconds;

  final int basePoints;

  static const pauseSeconds = 10;

  int pointsFor({required int secondsLeft, required bool inTime, int hints = 0, bool blind = false, int streak = 0}) =>
      score(secondsLeft: secondsLeft, inTime: inTime, hints: hints, blind: blind, streak: streak).total;

  Score score({required int secondsLeft, required bool inTime, int hints = 0, bool blind = false, int streak = 0}) =>
      Score(base: basePoints, timeBonus: secondsLeft ~/ 5, inTime: inTime, hints: hints, blind: blind, streak: streak);

  List<String> get operatorLabels => [
    for (final op in [BinOp.add, BinOp.sub, BinOp.mul, BinOp.div])
      if (binary.contains(op)) op.symbol,
    '(',
    ')',
    if (unary.contains(UnOp.sqrt)) '√',
    if (unary.contains(UnOp.cbrt)) '∛',
    if (unary.contains(UnOp.fact)) '!',
    if (binary.contains(BinOp.pow)) 'xʸ',
    if (unary.contains(UnOp.abs)) '|x|',
    if (unary.contains(UnOp.floor)) '⌊x⌋',
    if (unary.contains(UnOp.ceil)) '⌈x⌉',
  ];
}

class Score {
  const Score({
    required this.base,
    required this.timeBonus,
    required this.inTime,
    this.hints = 0,
    this.blind = false,
    this.streak = 0,
  });

  static const hintFactors = [1.0, 2 / 3, 1 / 3, 0.0];
  static const blindBonus = 1.25;
  static const maxStreakSteps = 5;
  static const streakStep = 0.1;

  final int base;
  final int timeBonus;
  final bool inTime;
  final int hints;
  final bool blind;
  final int streak;

  double get hintFactor => hintFactors[hints.clamp(0, 3)];
  double get blindFactor => blind ? blindBonus : 1.0;
  double get streakFactor => 1 + streakStep * streak.clamp(0, maxStreakSteps);

  int get total {
    if (!inTime) return 0;
    return ((base + timeBonus) * hintFactor * blindFactor * streakFactor + 1e-9).floor();
  }
}
