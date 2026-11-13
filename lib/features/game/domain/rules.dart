import 'board.dart';
import 'expr.dart';
import 'solution_codec.dart';

abstract interface class OpRules {
  Set<BinOp> get binary;
  Set<UnOp> get unary;
  bool get allowsFractionalDivision;
}

class _Rules implements OpRules {
  const _Rules(this.binary, this.unary, this.allowsFractionalDivision);

  @override
  final Set<BinOp> binary;
  @override
  final Set<UnOp> unary;
  @override
  final bool allowsFractionalDivision;
}

enum RestrictionKind {
  forbid,

  require,

  equalsAt,
}

class Restriction {
  const Restriction.forbid(Enum this.op) : kind = RestrictionKind.forbid, gap = null;
  const Restriction.require(Enum this.op) : kind = RestrictionKind.require, gap = null;
  const Restriction.equalsAt(int this.gap) : kind = RestrictionKind.equalsAt, op = null;

  final RestrictionKind kind;

  final Enum? op;

  final int? gap;

  OpRules rulesFor(OpRules base) {
    if (kind != RestrictionKind.forbid) return base;
    return _Rules({...base.binary}..remove(op), {...base.unary}..remove(op), base.allowsFractionalDivision);
  }

  bool allows(Board board) {
    switch (kind) {
      case RestrictionKind.forbid:
        return !board.blocks.any((b) => _uses(b, op!));
      case RestrictionKind.require:
        return board.blocks.any((b) => _uses(b, op!));
      case RestrictionKind.equalsAt:
        return board.eqDigitGap == gap;
    }
  }

  static bool _uses(Node root, Enum op) =>
      root.descendants.any((n) => (n is Binary && n.op == op) || (n is Unary && n.op == op));

  String encode() => switch (kind) {
    RestrictionKind.forbid => '-${SolutionCodec.letterOf(op!)}',
    RestrictionKind.require => '+${SolutionCodec.letterOf(op!)}',
    RestrictionKind.equalsAt => '=$gap',
  };

  static Restriction decode(String text) {
    if (text.length != 2) throw FormatException('bad restriction', text);
    final body = text.substring(1);
    switch (text[0]) {
      case '-':
        return Restriction.forbid(SolutionCodec.opOf(body));
      case '+':
        return Restriction.require(SolutionCodec.opOf(body));
      case '=':
        final g = int.tryParse(body);
        if (g == null || g < 0 || g > 2) throw FormatException('bad gap', text);
        return Restriction.equalsAt(g);
    }
    throw FormatException('bad restriction', text);
  }

  @override
  bool operator ==(Object other) => other is Restriction && other.kind == kind && other.op == op && other.gap == gap;

  @override
  int get hashCode => Object.hash(kind, op, gap);

  @override
  String toString() => encode();
}
