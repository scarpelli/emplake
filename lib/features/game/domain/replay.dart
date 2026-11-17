import 'board.dart';
import 'expr.dart';
import 'solution_codec.dart';

class ReplayStep {
  const ReplayStep(this.board, {this.op, this.gap, this.equals = false});

  final Board board;

  final Enum? op;

  final int? gap;

  final bool equals;
}

List<ReplayStep> replaySolution(String number, String solution) {
  final target = SolutionCodec.decode(number, solution);
  var board = Board.start(number);
  final steps = [ReplayStep(board)];

  void build(Node n) {
    switch (n) {
      case Leaf():
        return;
      case Binary(:final op, :final left, :final right):
        build(left);
        build(right);
        board = board.link(board.blockGapAt(n.digitGap)!, op);
        if (n.parens) board = board.toggleParens(board.binaryAt(n.digitGap)!.id);
        steps.add(ReplayStep(board, op: op, gap: n.digitGap));
      case Unary(:final op, :final child):
        build(child);
        final i = board.blocks.indexWhere((b) => b.firstIndex == child.firstIndex && b.lastIndex == child.lastIndex);
        board = board.applyUnary(board.blocks[i].id, op);
        steps.add(ReplayStep(board, op: op));
    }
  }

  build(target.blocks[0]);
  build(target.blocks[1]);
  final eq = target.eqDigitGap!;
  board = board.placeEquals(board.blockGapAt(eq)!);
  steps.add(ReplayStep(board, gap: eq, equals: true));
  return steps;
}
