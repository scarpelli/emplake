import 'package:emplake/features/game/domain/board.dart';
import 'package:emplake/features/game/domain/evaluator.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/format.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:flutter_test/flutter_test.dart';

Board build9227() {
  var b = Board.start('9227');
  b = b.link(1, BinOp.add);
  final sum = b.blocks[1].id;
  b = b.applyUnary(sum, UnOp.sqrt);
  b = b.link(0, BinOp.sub);
  return b.placeEquals(0);
}

void main() {
  group('board', () {
    test('starts with four leaves and three links left', () {
      final b = Board.start('9227');
      expect(b.blocks.length, 4);
      expect(b.linksLeft, 3);
      expect(b.isComplete, isFalse);
      expect(linearText(b), '9   2   2   7');
      expect(latexOf(b), r'9 \quad 2 \quad 2 \quad 7');
    });

    test('equals can be placed first and links cannot cross it', () {
      var b = Board.start('8796').placeEquals(1);
      expect(b.canLink(1), isFalse);
      expect(b.canPlaceEquals(0), isFalse);
      b = b.link(0, BinOp.add);
      expect(b.eqGap, 0);
      b = b.link(1, BinOp.add);
      expect(b.isComplete, isTrue);
      expect(linearText(b), '8 + 7 = 9 + 6');
      expect(b.verdict(Level.hard).isTrue, isTrue);
    });

    test('9 − √(2 + 2) = 7', () {
      final b = build9227();
      expect(b.isComplete, isTrue);
      expect(b.linksLeft, 0);
      expect(linearText(b), '9 − √(2 + 2) = 7');
      expect(latexOf(b), r'9-\sqrt{2+2} = 7');
      expect(b.verdict(Level.intermediate).isTrue, isTrue);
    });

    test('sqrt is rejected on the hard level', () {
      final v = build9227().verdict(Level.hard);
      expect(v.isTrue, isFalse);
      expect(v.result.error?.kind, EvalErrorKind.operatorNotAllowed);
    });

    test('unary operators stack and can be removed', () {
      var b = Board.start('3000');
      b = b.applyUnary(0, UnOp.fact);
      b = b.applyUnary(b.blocks[0].id, UnOp.fact);
      expect(linearText(b), '3!!   0   0   0');
      expect(Evaluator(Level.easy).evaluateBoard(b).values[b.blocks[0].id]!.display(), '720');
      b = b.unwrap(b.blocks[0].id);
      expect(linearText(b), '3!   0   0   0');
    });

    test('change operator and explicit parentheses', () {
      var b = Board.start('1234').link(0, BinOp.add);
      final id = b.blocks[0].id;
      b = b.changeBinary(id, BinOp.mul).toggleParens(id);
      expect(linearText(b), '(1 × 2)   3   4');
      expect(latexOf(b), r'\left(1 \times 2\right) \quad 3 \quad 4');
    });

    test('json round trip', () {
      final b = build9227();
      final back = Board.fromJson(b.toJson());
      expect(linearText(back), linearText(b));
      expect(back.eqGap, b.eqGap);
      expect(back.nextId, b.nextId);
    });
  });

  group('evaluation', () {
    test('non-integer division is an error outside the easy level', () {
      var b = Board.start('9227');
      b = b.link(0, BinOp.div).link(0, BinOp.add).placeEquals(0);
      expect(linearText(b), '9 ÷ 2 + 2 = 7');
      expect(latexOf(b), r'\frac{9}{2}+2 = 7');
      final v = b.verdict(Level.intermediate);
      expect(v.result.error?.kind, EvalErrorKind.nonIntegerDivision);
      expect(v.result.error?.result?.display(), '4,5');
      final easy = b.verdict(Level.easy);
      expect(easy.result.ok, isTrue);
      expect(easy.isTrue, isFalse);
    });

    test('3 = 6 ÷ ⌈9 ÷ 5⌉ on easy', () {
      var b = Board.start('3695').placeEquals(0);
      b = b.link(2, BinOp.div);
      b = b.applyUnary(b.blocks[2].id, UnOp.ceil);
      b = b.link(1, BinOp.div);
      expect(linearText(b), '3 = 6 ÷ ⌈9 ÷ 5⌉');
      expect(latexOf(b), r'3 = \frac{6}{\left\lceil \frac{9}{5} \right\rceil}');
      expect(b.verdict(Level.easy).isTrue, isTrue);
    });

    test('negation recovers the absolute value: 3 = −(2 − 5)', () {
      var b = Board.start('3250').placeEquals(0);
      b = b.link(1, BinOp.sub);
      b = b.applyUnary(b.blocks[1].id, UnOp.neg);
      b = b.link(1, BinOp.add);
      expect(linearText(b), '3 = −(2 − 5) + 0');
      expect(b.verdict(Level.hard).isTrue, isTrue);
    });

    test('irrational roots compare with tolerance', () {
      var b = Board.start('2222');
      b = b.applyUnary(0, UnOp.sqrt).applyUnary(1, UnOp.sqrt);
      b = b.link(0, BinOp.mul).placeEquals(0).link(1, BinOp.mul);
      expect(linearText(b), '√2 × √2 = 2 × 2');
      final v = b.verdict(Level.intermediate);
      expect(v.result.ok, isTrue);
      expect(v.left!.display(), '≈2');
      expect(v.isTrue, isFalse);
    });

    test('division by zero and factorial limits', () {
      var b = Board.start('1000').link(0, BinOp.div);
      expect(Evaluator(Level.easy).evaluateBoard(b).error?.kind, EvalErrorKind.divisionByZero);
      b = Board.start('9000').applyUnary(0, UnOp.fact);
      b = b.applyUnary(b.blocks[0].id, UnOp.fact);
      expect(Evaluator(Level.easy).evaluateBoard(b).error?.kind, EvalErrorKind.factorialTooLarge);
    });

    test('huge powers are rejected', () {
      var b = Board.start('9999').link(2, BinOp.pow).link(1, BinOp.pow);
      expect(Evaluator(Level.easy).evaluateBoard(b).error?.kind, EvalErrorKind.tooLarge);
    });

    test('live values are computed for every node', () {
      final b = build9227();
      final r = Evaluator(Level.intermediate).evaluateBoard(b);
      expect(r.values[b.blocks[0].id]!.display(), '7');
      expect(r.values[4]!.display(), '4');
    });
  });

  group('format precedence', () {
    test('subtraction on the right gets parentheses', () {
      var b = Board.start('1234').link(1, BinOp.sub);
      b = b.toggleParens(b.blocks[1].id).link(0, BinOp.sub);
      expect(linearText(b), '1 − (2 − 3)   4');
    });

    test('power base and factorial', () {
      var b = Board.start('2300').link(0, BinOp.add);
      b = b.applyUnary(b.blocks[0].id, UnOp.fact).link(0, BinOp.pow);
      expect(linearText(b), '((2 + 3)!)^0   0');
      expect(latexOf(b), r'{\left(\left(2+3\right)!\right)}^{0} \quad 0');
    });
  });

  test('levels expose the operators of the brief', () {
    expect(Level.easy.operatorLabels, ['+', '−', '×', '÷', '(', ')', '√', '∛', '!', 'xʸ', '|x|', '⌊x⌋', '⌈x⌉']);
    expect(Level.intermediate.operatorLabels.length, 11);
    expect(Level.advanced.operatorLabels, ['+', '−', '×', '÷', '(', ')', '√', '!', '|x|']);
    expect(Level.hard.operatorLabels, ['+', '−', '×', '÷', '(', ')', '|x|']);
  });
}
