import 'dart:io';
import 'dart:math';

import 'package:emplake/features/game/application/catalog_provider.dart';
import 'package:emplake/features/game/domain/catalog.dart';
import 'package:emplake/features/game/domain/evaluator.dart';
import 'package:emplake/features/game/domain/format.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/replay.dart';
import 'package:flutter_test/flutter_test.dart';

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
