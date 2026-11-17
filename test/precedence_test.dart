import 'package:emplake/features/game/domain/board.dart';
import 'package:emplake/features/game/domain/evaluator.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/format.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/solution_codec.dart';
import 'package:flutter_test/flutter_test.dart';

Board _unary(Board b, int block, UnOp op) => b.applyUnary(b.blocks[block].id, op);

bool _true(Board b) => b.verdict(Level.easy).isTrue;

void main() {
  group('precedence', () {
    test('1 + 2 × 3 = 7 whatever the order the signs are placed', () {
      final plusFirst = Board.start('1237').link(0, BinOp.add).link(0, BinOp.mul).placeEquals(0);
      final timesFirst = Board.start('1237').link(1, BinOp.mul).link(0, BinOp.add).placeEquals(0);
      for (final b in [plusFirst, timesFirst]) {
        expect(linearText(b), '1 + 2 × 3 = 7');
        expect(_true(b), isTrue);
      }
    });

    test('parentheses placed before linking group the branch', () {
      var b = Board.start('1239').link(0, BinOp.add);
      b = b.toggleParens(b.blocks[0].id).link(0, BinOp.mul).placeEquals(0);
      expect(linearText(b), '(1 + 2) × 3 = 9');
      expect(_true(b), isTrue);
    });

    test('removing parentheses lets precedence regroup the chain', () {
      var b = Board.start('1239').link(0, BinOp.add);
      final plus = b.blocks[0].id;
      b = b.toggleParens(plus).link(0, BinOp.mul).toggleParens(plus);
      expect(linearText(b), '1 + 2 × 3   9');
    });

    test('changing a sign regroups the chain', () {
      var b = Board.start('2347').link(0, BinOp.mul).link(0, BinOp.add);
      expect(linearText(b), '2 × 3 + 4   7');
      b = b.changeBinary(b.binaryAt(0)!.id, BinOp.add).changeBinary(b.binaryAt(1)!.id, BinOp.mul);
      expect(linearText(b), '2 + 3 × 4   7');
    });

    test('a removed root keeps the grouping it gave', () {
      var b = Board.start('1239').link(0, BinOp.add);
      b = _unary(b, 0, UnOp.sqrt).link(0, BinOp.mul);
      expect(linearText(b), '√(1 + 2) × 3   9');
      b = b.unwrap(b.binaryAt(1)!.left.id);
      expect(linearText(b), '(1 + 2) × 3   9');
    });

    test('power is right associative', () {
      final b = Board.start('2322').link(0, BinOp.pow).link(0, BinOp.pow);
      expect(linearText(b), '2^3^2   2');
      expect(Evaluator(Level.easy).evaluate(b.blocks[0]).values[b.blocks[0].id]!.display(), '512');
    });
  });

  group('examples from the course', () {
    test('2 × 3! = 8 + 4', () {
      var b = _unary(Board.start('2384'), 1, UnOp.fact);
      b = b.link(0, BinOp.mul).link(1, BinOp.add).placeEquals(0);
      expect(linearText(b), '2 × 3! = 8 + 4');
      expect(_true(b), isTrue);
    });

    test('−2 + 2 = 0 + 0', () {
      var b = _unary(Board.start('2200'), 0, UnOp.neg);
      b = b.link(0, BinOp.add).link(1, BinOp.add).placeEquals(0);
      expect(linearText(b), '−2 + 2 = 0 + 0');
      expect(_true(b), isTrue);
    });

    test('−−2 + 0! = 3 + 0', () {
      var b = Board.start('2030');
      b = _unary(_unary(b, 0, UnOp.neg), 0, UnOp.neg);
      b = _unary(b, 1, UnOp.fact);
      b = b.link(0, BinOp.add).link(1, BinOp.add).placeEquals(0);
      expect(linearText(b), '−−2 + 0! = 3 + 0');
      expect(_true(b), isTrue);
    });

    test('−(−2 + 5) = 4 − 7', () {
      var b = _unary(Board.start('2547'), 0, UnOp.neg).link(0, BinOp.add);
      b = _unary(b, 0, UnOp.neg).link(1, BinOp.sub).placeEquals(0);
      expect(linearText(b), '−(−2 + 5) = 4 − 7');
      expect(_true(b), isTrue);
    });

    test('signs can be stacked and inserted between other signs', () {
      var b = Board.start('2681').link(0, BinOp.sub);
      b = _unary(b, 0, UnOp.neg);
      b = _unary(b, 0, UnOp.fact);
      b = _unary(b, 0, UnOp.sqrt);
      final inner = b.blocks[0].id;
      b = _unary(b, 0, UnOp.sqrt);
      b = b.applyUnary((b.find(inner)! as Unary).child.id, UnOp.fact);
      b = b.applyUnary(inner, UnOp.fact);
      expect(linearText(b), '√((√((−(2 − 6))!!))!)   8   1');
      b = _unary(b, 1, UnOp.sqrt);
      b = b.toggleParens(b.blocks[1].id);
      b = _unary(b, 2, UnOp.fact).link(1, BinOp.mul);
      expect(linearText(b), '√((√((−(2 − 6))!!))!)   (√8) × 1!');
    });
  });

  group('stored trees keep their value', () {
    test('a solution grouped against precedence gets explicit parentheses', () {
      final b = SolutionCodec.decode('5433', '=(*(-(5,4),3),3)');
      expect(linearText(b), '(5 − 4) × 3 = 3');
      expect(_true(b), isTrue);
    });

    test('a game saved before precedence keeps its grouping', () {
      final json = {
        'digits': [1, 2, 3, 9],
        'blocks': [
          {
            't': 'b',
            'id': 5,
            'op': 'mul',
            'l': {
              't': 'b',
              'id': 4,
              'op': 'add',
              'l': {'t': 'l', 'id': 0, 'd': 1, 'i': 0},
              'r': {'t': 'l', 'id': 1, 'd': 2, 'i': 1},
            },
            'r': {'t': 'l', 'id': 2, 'd': 3, 'i': 2},
          },
          {'t': 'l', 'id': 3, 'd': 9, 'i': 3},
        ],
        'eq': 0,
        'next': 6,
      };
      final b = Board.fromJson(json);
      expect(linearText(b), '(1 + 2) × 3 = 9');
      expect(_true(b), isTrue);
    });
  });
}
