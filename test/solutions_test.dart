import 'dart:io';

import 'package:emplake/features/game/domain/catalog.dart';
import 'package:emplake/features/game/domain/evaluator.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/format.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/solver.dart';
import 'package:flutter_test/flutter_test.dart';

int _unaries(Iterable<Node> blocks) => blocks.expand((b) => b.descendants).whereType<Unary>().length;

void main() {
  final catalog = Catalog.fromJsonString(File('assets/catalog.json').readAsStringSync());

  test('every solution found is true, uses at most one unary and appears once', () {
    for (final level in Level.values) {
      for (final entry in catalog.entriesFor(level)) {
        final found = SolutionFinder(level).find(entry.number);
        final ideas = {for (final b in found) SolutionFinder.sameIdea(b)};
        expect(ideas.length, found.length, reason: entry.number);
        for (final b in found) {
          expect(Evaluator(level).isSolution(b), isTrue, reason: '${entry.number}: ${linearText(b)}');
          expect(_unaries(b.blocks), lessThanOrEqualTo(SolutionFinder.maxUnary));
        }
        final reference = entry.board();
        if (_unaries(reference.blocks) <= SolutionFinder.maxUnary) {
          expect(ideas, contains(SolutionFinder.sameIdea(reference)), reason: '${entry.number} ${entry.level}');
        }
      }
    }
  });

  test('simplest first: no unary before one unary', () {
    final found = SolutionFinder(Level.easy).find('4242');
    expect(found, isNotEmpty);
    expect(linearText(found.first), '4 + 2 = 4 + 2');
    final firstUnary = found.indexWhere((b) => _unaries(b.blocks) > 0);
    if (firstUnary >= 0) {
      expect(found.skip(firstUnary).every((b) => _unaries(b.blocks) > 0), isTrue);
    }
  });

  test('x + (−y) and x − (−y) are left out, they only restate x − y and x + y', () {
    final texts = SolutionFinder(Level.intermediate).find('6359').map(linearText);
    expect(texts, contains('6 = 3 × 5 − 9'));
    expect(texts.where((t) => t.contains('+ (−') || t.contains('− (−')), isEmpty);
  });

  test('the Hard level only uses its own operators', () {
    for (final b in SolutionFinder(Level.hard).find('2598')) {
      for (final n in b.blocks.expand((x) => x.descendants)) {
        if (n is Binary) expect(Level.hard.binary, contains(n.op));
        if (n is Unary) expect(Level.hard.unary, contains(n.op));
      }
    }
  });
}
