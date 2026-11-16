import 'package:emplake/features/game/domain/board.dart';
import 'package:emplake/features/game/domain/evaluator.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/format.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/solution_codec.dart';
import 'package:emplake/features/game/domain/solver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('codec', () {
    test('round trip keeps the formula and the game accepts it', () {
      final b = SolutionCodec.decode('1236', '=(*(*(1,2),3),6)');
      expect(linearText(b), '1 × 2 × 3 = 6');
      expect(Evaluator(Level.hard).isSolution(b), isTrue);
      expect(SolutionCodec.encodeBoard(b), '=(*(*(1,2),3),6)');
    });

    test('rejects digits out of order and malformed text', () {
      expect(() => SolutionCodec.decode('1236', '=(*(*(2,1),3),6)'), throwsFormatException);
      expect(() => SolutionCodec.decode('1236', '=(*(1,2),3'), throwsFormatException);
    });

    test('board built from sides is complete', () {
      final b = SolutionCodec.decode('9227', '=(-(9,s(+(2,2))),7)');
      expect(b.isComplete, isTrue);
      expect(b, isA<Board>());
      expect(b.blocks[0], isA<Binary>());
    });
  });

  group('solver', () {
    test('finds a verified solution for 1236 on every level', () {
      for (final level in Level.values) {
        final r = Solver(level).solve('1236');
        expect(r.solvable, isTrue, reason: level.name);
        expect(Evaluator(level).isSolution(r.board()), isTrue, reason: level.name);
      }
    });

    test('1119 has no solution on Hard', () {
      expect(Solver(Level.hard).solve('1119').solvable, isFalse);
    });

    test('a number that needs a unary operator rates harder', () {
      final plain = Solver(Level.easy).solve('1236');
      expect(plain.size, 6, reason: '1 × 2 × 3 = 6 needs no unary operator');
      expect(plain.stars, lessThanOrEqualTo(2));
      final solver = Solver(Level.advanced);
      final needsUnary = [for (var i = 0; i < 300; i++) solver.solve((i * 37 % 10000).toString().padLeft(4, '0'))]
          .firstWhere((r) => r.solvable && r.size > 6 && !r.number.contains('0'));
      expect(needsUnary.stars, greaterThan(1));
      expect(needsUnary.difficulty, greaterThan(plain.difficulty));
    });

    test('a mirrored number rates as the easiest', () {
      final r = Solver(Level.hard).solve('5885');
      expect(r.mirrored, isTrue);
      expect(r.difficulty, 0);
      expect(r.stars, 1);
    });

    test('rating follows the effort of the simplest solution', () {
      final solver = Solver(Level.hard);
      expect(solver.solve('8897').stars, 1, reason: '8 + 8 = 9 + 7');
      expect(solver.solve('5938').stars, 2, reason: '5 + 9 ÷ 3 = 8');
      expect(solver.solve('2647').stars, 3, reason: '2 = 6 ÷ (−4 + 7)');
    });

    test('keeps the simplest solution instead of the shortest', () {
      expect(linearText(Solver(Level.easy).solve('3585').board()), '3 × 5 × 8 = 5!');
    });

    test('is fast enough to run on demand and Hard leaves many numbers unsolved', () {
      final sw = Stopwatch()..start();
      final solvable = <Level, int>{};
      const sample = 100;
      for (final level in Level.values) {
        final solver = Solver(level);
        for (var i = 0; i < sample; i++) {
          if (solver.solve((i * 97 % 10000).toString().padLeft(4, '0')).solvable) {
            solvable[level] = (solvable[level] ?? 0) + 1;
          }
        }
      }
      expect(sw.elapsedMilliseconds, lessThan(5000), reason: '${4 * sample} solves');
      expect(solvable[Level.easy], greaterThan(90));
      expect(solvable[Level.hard], lessThan(70));
    });
  });
}
