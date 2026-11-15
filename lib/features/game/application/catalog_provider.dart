import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/catalog.dart';
import '../domain/level.dart';
import '../domain/solver.dart';

Future<String?> findSolution(Ref ref, Level level, String number) async {
  final catalog = await ref.read(catalogProvider.future);
  return catalog.lookup(level, number)?.solution ?? Solver(level).solve(number).solution;
}

final solutionProvider = FutureProvider.family<String?, (Level, String)>(
  (ref, key) => findSolution(ref, key.$1, key.$2),
);

final catalogProvider = FutureProvider<Catalog>((ref) async {
  final text = await rootBundle.loadString('assets/catalog.json');
  return Catalog.fromJsonString(text);
});

abstract final class DrawPolicy {
  static const warmUp = 5;

  static const gentleShare = 0.7;

  static CatalogEntry? pick(Catalog catalog, Level level, Set<String> solved, {String? exclude, Random? random}) {
    final r = random ?? Random();
    final all = catalog.entriesFor(level);
    final free = [
      for (final e in all)
        if (!solved.contains(e.number) && e.number != exclude) e,
    ];
    if (free.isEmpty) return null;

    final solvedHere = all.where((e) => solved.contains(e.number)).length;
    List<CatalogEntry> band(bool Function(int stars) test) => [
      for (final e in free)
        if (test(e.stars)) e,
    ];

    final List<CatalogEntry> preferred;
    if (solvedHere < warmUp) {
      preferred = band((s) => s == 1);
    } else if (r.nextDouble() < gentleShare) {
      preferred = band((s) => s <= 2);
    } else {
      preferred = band((s) => s == 3);
    }
    final from = preferred.isEmpty ? free : preferred;
    return from[r.nextInt(from.length)];
  }
}
