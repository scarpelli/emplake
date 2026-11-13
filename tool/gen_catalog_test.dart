import 'dart:io';
import 'dart:math';

import 'package:emplake/features/game/domain/board.dart';
import 'package:emplake/features/game/domain/catalog.dart';
import 'package:emplake/features/game/domain/evaluator.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/solution_codec.dart';
import 'package:emplake/features/game/domain/solver.dart';
import 'package:flutter_test/flutter_test.dart';

const tutorialNumber = '1236';

const pool = 600;

void main() {
  test('generate catalog', () {
    final used = <String>{tutorialNumber};
    final entries = <CatalogEntry>[];

    for (final level in Level.values) {
      final quota = Catalog.quota[level]!;
      final solver = Solver(level);
      final order = [for (var i = 0; i < 10000; i++) i.toString().padLeft(4, '0')]..shuffle(Random(2026 + level.index));

      final found = <SolveResult>[];
      for (final number in order) {
        if (found.length >= pool) break;
        if (used.contains(number)) continue;
        final r = solver.solve(number);
        if (r.solvable) found.add(r);
      }
      found.sort((a, b) {
        final c = a.difficulty.compareTo(b.difficulty);
        return c != 0 ? c : a.number.compareTo(b.number);
      });

      final n3 = (quota * 0.15).round();
      final n2 = (quota * 0.35).round();
      final n1 = quota - n2 - n3;
      final bands = [(1, 0.0, 0.5, n1), (2, 0.5, 0.85, n2), (3, 0.85, 1.0, n3)];
      for (final (stars, from, to, count) in bands) {
        final band = found.sublist((found.length * from).floor(), (found.length * to).floor());
        final step = band.length / count;
        for (var i = 0; i < count; i++) {
          final r = band[(i * step).floor()];
          used.add(r.number);
          entries.add(CatalogEntry(number: r.number, level: level, stars: stars, solution: r.solution!));
        }
      }
    }

    final lessons = <Lesson>[];
    final found = <Enum, List<CatalogEntry>>{};
    for (final level in [Level.easy, Level.hard]) {
      final solver = Solver(level);
      final order = [for (var i = 0; i < 10000; i++) i.toString().padLeft(4, '0')]..shuffle(Random(7 + level.index));
      for (final number in order) {
        if (Lesson.order.every((op) => (found[op]?.length ?? 0) >= 2)) break;
        if (used.contains(number)) continue;
        final r = solver.solve(number);
        if (!r.solvable || r.size > 8) continue;
        final board = r.board();
        final ops = opsIn(board);
        for (final op in Lesson.order) {
          final list = found[op] ??= [];
          final basics = op is UnOp
              ? const {BinOp.add, BinOp.sub, BinOp.mul, BinOp.div}
              : const {BinOp.add, BinOp.sub, BinOp.mul};
          if (list.length < 2 && ops.contains(op) && ops.every((o) => o == op || basics.contains(o))) {
            list.add(CatalogEntry(number: number, level: level, stars: r.stars, solution: r.solution!));
            used.add(number);
            break;
          }
        }
      }
    }
    if ((found[UnOp.abs]?.length ?? 0) < 2) {
      final solver = Solver(Level.hard);
      for (var i = 0; i < 10000 && (found[UnOp.abs]?.length ?? 0) < 2; i++) {
        final number = ((i * 7919) % 10000).toString().padLeft(4, '0');
        if (used.contains(number)) continue;
        final r = solver.solve(number);
        if (!r.solvable) continue;
        final text = absVariant(number, r.solution!);
        if (text == null) continue;
        (found[UnOp.abs] ??= []).add(CatalogEntry(number: number, level: Level.hard, stars: 3, solution: text));
        used.add(number);
      }
    }
    for (final op in Lesson.order) {
      final list = found[op] ?? const [];
      if (list.length == 2) lessons.add(Lesson(op: op, example: list[0], practice: list[1]));
    }

    for (final e in [
      ...entries,
      for (final lesson in lessons) ...[lesson.example, lesson.practice],
    ]) {
      expect(Evaluator(e.level).isSolution(e.board()), isTrue, reason: '${e.level.name} ${e.number} ${e.solution}');
    }
    final catalog = Catalog(entries, lessons: lessons);
    expect(catalog.length, 150);
    // ignore: avoid_print
    print('lessons: ${lessons.map((l) => l.op.name).join(', ')}');
    File('assets/catalog.json').writeAsStringSync('${catalog.toJsonString()}\n');
  });
}

int _closing(String s, int open) {
  var depth = 0;
  for (var i = open; i < s.length; i++) {
    if (s[i] == '(') depth++;
    if (s[i] == ')' && --depth == 0) return i + 1;
  }
  return s.length;
}

String? absVariant(String number, String solution) {
  final evaluator = Evaluator(Level.hard);
  final subs = [
    for (var i = 0; i + 1 < solution.length; i++)
      if (solution.startsWith('-(', i)) i,
  ];
  for (final at in subs) {
    final end = _closing(solution, at + 1);
    final wrapped = '${solution.substring(0, at)}a(${solution.substring(at, end)})${solution.substring(end)}';
    final negs = [
      for (var i = 0; i + 1 < wrapped.length; i++)
        if (wrapped.startsWith('n(', i)) i,
    ];
    final candidates = [
      wrapped,
      for (final n in negs)
        '${wrapped.substring(0, n)}${wrapped.substring(n + 2, _closing(wrapped, n + 1) - 1)}'
            '${wrapped.substring(_closing(wrapped, n + 1))}',
    ];
    for (final text in candidates) {
      final Board board;
      try {
        board = SolutionCodec.decode(number, text);
      } on FormatException {
        continue;
      }
      if (!evaluator.isSolution(board)) continue;
      final abs = board.blocks.expand((b) => b.descendants).whereType<Unary>().firstWhere((u) => u.op == UnOp.abs);
      final inner = evaluator.evaluate(abs.child).values[abs.child.id];
      if (inner != null && inner.isNegative()) return text;
    }
  }
  return null;
}

Set<Enum> opsIn(Board board) => {
  for (final b in board.blocks)
    for (final n in b.descendants)
      if (n is Binary) n.op else if (n is Unary) n.op,
};
