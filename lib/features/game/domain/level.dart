import 'expr.dart';

enum Level {
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

  final Set<BinOp> binary;
  final Set<UnOp> unary;

  final bool allowsFractionalDivision;

  final int seconds;

  final int basePoints;

  static const pauseSeconds = 10;

  int pointsFor({required int secondsLeft, required bool inTime}) =>
      inTime ? basePoints + (secondsLeft ~/ 5) : 0;

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
