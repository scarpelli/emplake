import 'expr.dart';
import 'solution_codec.dart';

class HintInfo {
  const HintInfo({required this.equalsGap, required this.linkGap, required this.linkOp});

  final int equalsGap;

  final int linkGap;
  final BinOp linkOp;

  static HintInfo from(String number, String solution) {
    final board = SolutionCodec.decode(number, solution);
    Binary? best;
    var bestLeaves = 99;
    for (final block in board.blocks) {
      for (final n in block.descendants) {
        if (n is! Binary) continue;
        final leaves = n.lastIndex - n.firstIndex + 1;
        if (leaves < bestLeaves || (leaves == bestLeaves && n.digitGap < best!.digitGap)) {
          best = n;
          bestLeaves = leaves;
        }
      }
    }
    final eq = board.eqDigitGap!;
    return HintInfo(equalsGap: eq, linkGap: best?.digitGap ?? eq, linkOp: best?.op ?? BinOp.add);
  }
}
