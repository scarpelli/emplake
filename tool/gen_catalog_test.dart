import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:emplake/features/game/domain/board.dart';
import 'package:emplake/features/game/domain/catalog.dart';
import 'package:emplake/features/game/domain/evaluator.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/rules.dart';
import 'package:emplake/features/game/domain/solution_codec.dart';
import 'package:emplake/features/game/domain/solver.dart';
import 'package:flutter_test/flutter_test.dart';

import 'catalog_docs.dart';

const tutorialNumber = '1236';

const zeroShare = 0.2;

const maxDifficulty = 7.0;

const maxVariantSize = 9;

final regen = Platform.environment['EMPLAKE_REGEN'] == '1';
final forceReorder = Platform.environment['EMPLAKE_REORDER'] == '1';

void main() {
  test('enrich catalog v2 and write docs', () {
    final text = File('assets/catalog.json').readAsStringSync();
    final version = (jsonDecode(text) as Map)['version'] as int? ?? 1;
    final source = Catalog.fromJsonString(text);

    final entries = <CatalogEntry>[];
    for (final level in Level.values) {
      final enriched = [
        for (final e in source.entriesFor(level)) enrich(e.copyWith(stars: Solver(level).solve(e.number).stars)),
      ];
      entries.addAll(version < 2 || forceReorder ? trailOrder(enriched) : enriched);
    }
    final catalog = Catalog(entries, lessons: source.lessons);

    expect(catalog.length, source.length);
    expect(catalog.all.map((e) => e.id).toSet(), source.all.map((e) => e.id).toSet());
    for (final e in catalog.all) {
      final plain = e.board();
      expect(Evaluator(e.level).isSolution(plain), isTrue, reason: '${e.id} ${e.solution}');
      for (final v in e.variants) {
        final b = SolutionCodec.decode(e.number, v.solution);
        expect(Evaluator(v.rule.rulesFor(e.level)).isSolution(b), isTrue, reason: '${e.id} ${v.rule}');
        expect(v.rule.allows(b), isTrue, reason: '${e.id} ${v.rule}');
        expect(v.rule.allows(plain), isFalse, reason: '${e.id} ${v.rule} must break the plain solution');
      }
    }
    File('assets/catalog.json').writeAsStringSync('${catalog.toJsonString()}\n');
    for (final MapEntry(:key, :value) in renderCatalogDocs(catalog).entries) {
      File(key)
        ..parent.createSync(recursive: true)
        ..writeAsStringSync(value);
    }
    final trivial = catalog.all.where((e) => e.trivial).length;
    final variants = catalog.all.fold(0, (a, e) => a + e.variants.length);
    final withVariant = catalog.all.where((e) => e.variants.isNotEmpty).length;
    // ignore: avoid_print
    print('trivial: $trivial · variants: $variants · entries with a variant: $withVariant');
  });

  test('regenerate catalog entries (EMPLAKE_REGEN=1)', skip: !regen, () {
    final source = Catalog.fromJsonString(File('assets/catalog.json').readAsStringSync());
    final used = <String>{
      tutorialNumber,
      for (final lesson in source.lessons) ...[lesson.example.number, lesson.practice.number],
    };
    final entries = <CatalogEntry>[];

    for (final level in Level.values) {
      final solver = Solver(level);
      final bands = <int, List<SolveResult>>{1: [], 2: [], 3: []};
      for (var i = 0; i < 10000; i++) {
        final number = i.toString().padLeft(4, '0');
        if (used.contains(number) || SolveResult.mirroredNumber(number)) continue;
        final r = solver.solve(number);
        if (!r.solvable || r.difficulty > maxDifficulty) continue;
        bands[r.stars]!.add(r);
      }
      int tie(SolveResult r) => (int.parse(r.number) * 7919 + level.index * 104729) % 10007;
      int byDifficulty(SolveResult a, SolveResult b) {
        final c = a.difficulty.compareTo(b.difficulty);
        return c != 0 ? c : tie(a).compareTo(tie(b));
      }

      for (final (stars, count) in bandSizes(Catalog.quota[level]!)) {
        final band = bands[stars]!;
        final zero = band.where((r) => r.number.contains('0')).toList()..sort(byDifficulty);
        final plain = band.where((r) => !r.number.contains('0')).toList()..sort(byDifficulty);
        final zeros = min((count * zeroShare).round(), zero.length);
        final picked = [...spread(zero, zeros), ...spread(plain, count - zeros)]..sort(byDifficulty);
        expect(picked, hasLength(count), reason: '${level.name} ★$stars');
        for (final r in picked) {
          used.add(r.number);
          entries.add(CatalogEntry(number: r.number, level: level, stars: stars, solution: r.solution!));
        }
      }
    }

    for (final e in entries) {
      expect(Evaluator(e.level).isSolution(e.board()), isTrue, reason: '${e.level.name} ${e.number} ${e.solution}');
    }
    final catalog = Catalog(entries, lessons: source.lessons);
    expect(catalog.length, 150);
    File('assets/catalog.json').writeAsStringSync('${catalog.toJsonString(version: 1)}\n');
  });
}

List<(int, int)> bandSizes(int quota) {
  final n3 = (quota * 0.15).round();
  final n2 = (quota * 0.35).round();
  return [(1, quota - n2 - n3), (2, n2), (3, n3)];
}

List<SolveResult> spread(List<SolveResult> sorted, int count) {
  String shape(SolveResult r) => r.solution!.replaceAll(RegExp(r'[0-9]'), 'd');
  final picked = <int>{};
  final shapes = <String>{};
  final radius = count == 0 ? 0 : sorted.length ~/ (2 * count);
  for (var i = 0; i < count; i++) {
    final at = ((i + 0.5) * sorted.length / count).floor();
    final near = [
      for (var j = 0; j < sorted.length; j++)
        if (!picked.contains(j)) j,
    ]..sort((a, b) => (a - at).abs().compareTo((b - at).abs()));
    final fresh = near.where((j) => (j - at).abs() <= radius && !shapes.contains(shape(sorted[j])));
    final j = fresh.isNotEmpty ? fresh.first : near.first;
    picked.add(j);
    shapes.add(shape(sorted[j]));
  }
  return [for (final j in picked) sorted[j]];
}

bool annihilates(Board board, Level level) {
  final values = Evaluator(level).evaluateBoard(board).values;
  bool zero(Node n) => values[n.id]?.isZero() ?? false;
  for (final b in board.blocks) {
    for (final n in b.descendants) {
      if (n is! Binary || !zero(n)) continue;
      final hit = switch (n.op) {
        BinOp.mul => zero(n.left) || zero(n.right),
        BinOp.div || BinOp.pow => zero(n.left),
        _ => false,
      };
      if (hit) return true;
    }
  }
  return false;
}

CatalogEntry enrich(CatalogEntry e) {
  final board = e.board();
  final trivial = e.number.contains('0') && annihilates(board, e.level);
  return e.copyWith(trivial: trivial, variants: variantsFor(e, board, trivial));
}

List<RestrictedVariant> variantsFor(CatalogEntry e, Board plain, bool trivial) {
  final level = e.level;
  final usedCount = <Enum, int>{};
  for (final b in plain.blocks) {
    for (final n in b.descendants) {
      if (n is Binary) usedCount[n.op] = (usedCount[n.op] ?? 0) + 1;
      if (n is Unary) usedCount[n.op] = (usedCount[n.op] ?? 0) + 1;
    }
  }
  final byUse = usedCount.keys.toList()..sort((a, b) => usedCount[b]!.compareTo(usedCount[a]!));
  final forbids = [if (trivial && usedCount.containsKey(BinOp.mul)) BinOp.mul, ...byUse].map(Restriction.forbid);
  final eqs = [
    for (var g = 0; g < 3; g++)
      if (g != plain.eqDigitGap) Restriction.equalsAt(g),
  ];
  final requires = [
    for (final op in <Enum>[BinOp.mul, BinOp.div, BinOp.pow, BinOp.sub, BinOp.add, UnOp.sqrt, UnOp.fact])
      if (!usedCount.containsKey(op) && (level.binary.contains(op) || level.unary.contains(op)))
        Restriction.require(op),
  ];

  final taken = <String>{};
  RestrictedVariant? firstOf(Iterable<Restriction> rules) {
    for (final rule in rules) {
      if (rule.allows(plain)) continue;
      final r = Solver(level, restriction: rule).solve(e.number);
      if (!r.solvable || r.size > maxVariantSize || taken.contains(r.solution)) continue;
      if (annihilates(r.board(), level)) continue;
      taken.add(r.solution!);
      return RestrictedVariant(rule, r.solution!);
    }
    return null;
  }

  return [?firstOf(forbids), ?firstOf(eqs), ?firstOf(requires)];
}

List<CatalogEntry> trailOrder(List<CatalogEntry> list) {
  final rank = {for (final e in list) e.id: Solver(e.level).solve(e.number).difficulty};
  int byRank(CatalogEntry a, CatalogEntry b) {
    var c = a.stars.compareTo(b.stars);
    if (c == 0) c = rank[a.id]!.compareTo(rank[b.id]!);
    return c != 0 ? c : a.number.compareTo(b.number);
  }

  final trivial = list.where((e) => e.trivial).toList()..sort(byRank);
  final regular = list.where((e) => !e.trivial).toList()..sort(byRank);
  final out = <CatalogEntry>[...trivial.take(2)];
  var t = 2;
  for (var i = 0; i < regular.length; i++) {
    out.add(regular[i]);
    if (i.isOdd && t < trivial.length) out.add(trivial[t++]);
  }
  out.addAll(trivial.skip(t));
  return out;
}
