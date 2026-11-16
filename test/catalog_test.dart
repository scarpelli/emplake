import 'dart:io';
import 'dart:math';

import 'package:emplake/features/game/application/catalog_provider.dart';
import 'package:emplake/features/game/domain/catalog.dart';
import 'package:emplake/features/game/domain/evaluator.dart';
import 'package:emplake/features/game/domain/format.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/replay.dart';
import 'package:emplake/features/game/domain/solution_codec.dart';
import 'package:emplake/features/game/domain/solver.dart';
import 'package:flutter_test/flutter_test.dart';

import '../tool/catalog_docs.dart';

void main() {
  final catalog = Catalog.fromJsonString(File('assets/catalog.json').readAsStringSync());

  test('has the 150 planned operations, split by level', () {
    expect(catalog.length, 150);
    for (final level in Level.values) {
      expect(catalog.countFor(level), Catalog.quota[level], reason: level.name);
    }
  });

  test('every operation is a true equation under its level rules', () {
    for (final level in Level.values) {
      for (final e in catalog.entriesFor(level)) {
        expect(Evaluator(level).isSolution(e.board()), isTrue, reason: '${level.name} ${e.number} ${e.solution}');
      }
    }
  });

  test('stars match the solver rating and no plate is mirrored', () {
    for (final e in catalog.all) {
      final r = Solver(e.level).solve(e.number);
      expect(e.stars, r.stars, reason: e.id);
      expect(r.mirrored, isFalse, reason: e.id);
    }
  });

  test('mixes difficulties and never repeats a number', () {
    for (final level in Level.values) {
      final stars = catalog.entriesFor(level).map((e) => e.stars).toList();
      for (final s in [1, 2, 3]) {
        expect(stars.contains(s), isTrue, reason: '${level.name} has ★$s');
      }
      expect(stars.where((s) => s == 1).length, greaterThanOrEqualTo(stars.length ~/ 2 - 1));
    }
    final numbers = [for (final l in Level.values) ...catalog.entriesFor(l).map((e) => e.number)];
    expect(numbers.toSet().length, numbers.length);
    expect(numbers, isNot(contains('1236')), reason: 'kept for the tutorial');
  });

  group('v2 metadata', () {
    test('restricted variants follow their rule, break the plain solution and avoid the zero trick', () {
      for (final e in catalog.all) {
        final plain = e.board();
        for (final v in e.variants) {
          final b = SolutionCodec.decode(e.number, v.solution);
          expect(Evaluator(v.rule.rulesFor(e.level)).isSolution(b), isTrue, reason: '${e.id} ${v.rule}');
          expect(v.rule.allows(b), isTrue, reason: '${e.id} ${v.rule}');
          expect(v.rule.allows(plain), isFalse, reason: '${e.id} ${v.rule}');
        }
      }
      for (final level in Level.values) {
        expect(catalog.entriesFor(level).where((e) => e.variants.isNotEmpty).length, greaterThan(20));
      }
    });

    test('trivial plates have a zero and are spread as warm-ups on the trail', () {
      for (final level in Level.values) {
        final list = catalog.entriesFor(level);
        for (final e in list.where((e) => e.trivial)) {
          expect(e.number, contains('0'), reason: e.id);
        }
        expect(list.where((e) => e.trivial).length, lessThan(list.length ~/ 3), reason: level.name);
      }
    });

    test('docs/catalogo is up to date with the catalog', () {
      for (final MapEntry(:key, :value) in renderCatalogDocs(catalog).entries) {
        final file = File(key);
        expect(file.existsSync(), isTrue, reason: '$key missing: run flutter test tool/gen_catalog_test.dart');
        expect(
          file.readAsStringSync().replaceAll('\r\n', '\n'),
          value,
          reason: '$key is stale: run flutter test tool/gen_catalog_test.dart',
        );
      }
    });
  });

  group('draw', () {
    test('only draws catalog numbers, skipping solved ones and the excluded one', () {
      final r = Random(1);
      for (final level in Level.values) {
        final all = catalog.entriesFor(level).map((e) => e.number).toSet();
        final solved = all.take(3).toSet();
        for (var i = 0; i < 200; i++) {
          final e = DrawPolicy.pick(catalog, level, solved, exclude: all.last, random: r)!;
          expect(all, contains(e.number));
          expect(solved, isNot(contains(e.number)));
          expect(e.number, isNot(all.last));
        }
      }
    });

    test('warm-up draws the gentlest numbers first', () {
      final r = Random(2);
      for (var i = 0; i < 100; i++) {
        expect(DrawPolicy.pick(catalog, Level.hard, const {}, random: r)!.stars, 1);
      }
    });

    test('returns null when the level is exhausted', () {
      final all = catalog.entriesFor(Level.easy).map((e) => e.number).toSet();
      expect(DrawPolicy.pick(catalog, Level.easy, all), isNull);
    });
  });

  group('lessons', () {
    test('one lesson per operator, each using its operator and accepted by the game', () {
      expect(catalog.lessons.map((l) => l.op).toSet(), Lesson.order.toSet());
      for (final lesson in catalog.lessons) {
        for (final e in [lesson.example, lesson.practice]) {
          final board = e.board();
          expect(Evaluator(e.level).isSolution(board), isTrue, reason: '${lesson.op.name} ${e.number}');
          expect(Lesson.uses(board, lesson.op), isTrue, reason: '${lesson.op.name} ${e.number}');
        }
      }
    });

    test('replaying a solution step by step ends on the same true equation', () {
      for (final lesson in catalog.lessons) {
        final e = lesson.example;
        final steps = replaySolution(e.number, e.solution);
        expect(steps.first.board.linksMade, 0);
        expect(steps.last.equals, isTrue);
        expect(linearText(steps.last.board), linearText(e.board()), reason: lesson.op.name);
        expect(Evaluator(e.level).isSolution(steps.last.board), isTrue, reason: lesson.op.name);
      }
    });
  });
}
