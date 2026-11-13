import 'package:emplake/features/game/domain/board.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/format.dart';
import 'package:flutter_test/flutter_test.dart';

String signs(Board b) =>
    [for (var g = 0; g < 3; g++) b.eqDigitGap == g ? '=' : (b.binaryAt(g)?.op.symbol ?? '·')].join();

void main() {
  group('signs live in digit gaps', () {
    test('digit gaps of binaries and of the "="', () {
      var b = Board.start('1234').link(0, BinOp.add);
      b = b.placeEquals(1);
      expect(b.binaryAt(0)?.op, BinOp.add);
      expect(b.eqDigitGap, 2);
      expect(b.blockGapAt(1), 0);
      expect(b.blockGapAt(0), isNull);
      expect(signs(b), '+·=');
    });
  });

  group('unlink', () {
    test('a root operator splits its block in two', () {
      final b = Board.start('1234').link(0, BinOp.add).unlink(4);
      expect(b.blocks.length, 4);
      expect(signs(b), '···');
    });

    test('an inner operator keeps every other operator in place', () {
      var b = Board.start('1234').link(0, BinOp.add).link(0, BinOp.mul).placeEquals(0);
      final plus = b.binaryAt(0)!.id;
      b = b.unlink(plus);
      expect(signs(b), '·×=');
      expect(b.blocks.length, 3);
      expect(b.eqGap, 1, reason: 'the "=" block gap shifts right after the split');
      expect(linearText(b).replaceAll(' ', ''), '12×3=4');
    });

    test('splitting right of the "=" keeps its block gap', () {
      var b = Board.start('1234').placeEquals(0).link(1, BinOp.add).link(1, BinOp.mul);
      b = b.unlink(b.binaryAt(2)!.id);
      expect(signs(b), '=+·');
      expect(b.eqGap, 0);
    });

    test('unary operators wrapping the cut are dropped, others stay', () {
      var b = Board.start('1234').link(0, BinOp.add);
      b = b.applyUnary(b.blocks[0].id, UnOp.sqrt);
      b = b.applyUnary(b.blocks[1].id, UnOp.fact);
      b = b.unlink(b.binaryAt(0)!.id);
      expect(b.blocks.length, 4);
      expect(b.blocks[2], isA<Unary>(), reason: '3! keeps its factorial');
      expect(b.blocks.take(2).every((n) => n is Leaf), isTrue);
    });

    test('board survives a JSON round trip after unlinking', () {
      var b = Board.start('1234').link(0, BinOp.add).link(0, BinOp.mul).placeEquals(0);
      b = b.unlink(b.binaryAt(0)!.id);
      final again = Board.fromJson(b.toJson());
      expect(signs(again), signs(b));
      expect(linearText(again), linearText(b));
    });
  });

  group('moving signs', () {
    test('the "=" moves to an open gap', () {
      final b = Board.start('1234').placeEquals(0).moveEquals(2);
      expect(signs(b), '··=');
    });

    test('the "=" swaps places with an operator', () {
      var b = Board.start('1234').link(1, BinOp.add).placeEquals(0);
      b = b.moveEquals(1);
      expect(signs(b), '+=·');
    });

    test('an operator moves to an open gap', () {
      var b = Board.start('1234').link(0, BinOp.mul);
      b = b.moveBinary(b.binaryAt(0)!.id, 2);
      expect(signs(b), '··×');
    });

    test('two operators swap symbols, the tree shape stays', () {
      var b = Board.start('1234').link(0, BinOp.add).link(0, BinOp.mul);
      final before = b.blocks.length;
      b = b.moveBinary(b.binaryAt(0)!.id, 1);
      expect(signs(b), '×+·');
      expect(b.blocks.length, before);
    });

    test('an operator swaps places with the "="', () {
      var b = Board.start('1234').link(0, BinOp.sub).placeEquals(1);
      b = b.moveBinary(b.binaryAt(0)!.id, 2);
      expect(signs(b), '=·−');
    });

    test('moving an operator does not touch an "=" elsewhere', () {
      var b = Board.start('1234').link(0, BinOp.add).placeEquals(0);
      b = b.moveBinary(b.binaryAt(0)!.id, 2);
      expect(signs(b), '·=+');
    });
  });

  group('dropping from the palette', () {
    test('an operator on an open gap links it; on an operator it changes it', () {
      var b = Board.start('1234').dropBinary(BinOp.add, 1);
      expect(signs(b), '·+·');
      b = b.dropBinary(BinOp.mul, 1);
      expect(signs(b), '·×·');
    });

    test('an operator on the "=" replaces it', () {
      final b = Board.start('1234').placeEquals(1).dropBinary(BinOp.add, 1);
      expect(signs(b), '·+·');
      expect(b.eqGap, isNull);
    });

    test('the "=" on an operator replaces it and moves if already placed', () {
      var b = Board.start('1234').link(1, BinOp.add).placeEquals(0);
      b = b.dropEquals(1);
      expect(signs(b), '·=·');
    });

    test('clearGap removes whatever is there', () {
      var b = Board.start('1234').link(0, BinOp.add).placeEquals(0);
      expect(signs(b.clearGap(0)), '·=·');
      expect(signs(b.clearGap(1)), '+··');
      expect(signs(b.clearGap(2)), '+=·');
    });
  });
}
