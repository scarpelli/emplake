import 'dart:convert';

import 'board.dart';
import 'expr.dart';
import 'level.dart';
import 'rules.dart';
import 'solution_codec.dart';

class RestrictedVariant {
  const RestrictedVariant(this.rule, this.solution);

  final Restriction rule;

  final String solution;

  Map<String, dynamic> toJson() => {'r': rule.encode(), 'x': solution};

  factory RestrictedVariant.fromJson(Map<String, dynamic> j) =>
      RestrictedVariant(Restriction.decode(j['r'] as String), j['x'] as String);
}

class CatalogEntry {
  const CatalogEntry({
    required this.number,
    required this.level,
    required this.stars,
    required this.solution,
    this.trivial = false,
    this.variants = const [],
  });

  final String number;
  final Level level;

  final int stars;

  final String solution;

  final bool trivial;

  final List<RestrictedVariant> variants;

  String get id => '${level.name}_$number';

  Board board() => SolutionCodec.decode(number, solution);

  CatalogEntry copyWith({bool? trivial, List<RestrictedVariant>? variants}) => CatalogEntry(
    number: number,
    level: level,
    stars: stars,
    solution: solution,
    trivial: trivial ?? this.trivial,
    variants: variants ?? this.variants,
  );

  Map<String, dynamic> toJson() => {
    'n': number,
    'l': level.name,
    's': stars,
    'x': solution,
    if (trivial) 't': true,
    if (variants.isNotEmpty) 'r': [for (final v in variants) v.toJson()],
  };

  factory CatalogEntry.fromJson(Map<String, dynamic> j) => CatalogEntry(
    number: j['n'] as String,
    level: Level.values.byName(j['l'] as String),
    stars: j['s'] as int,
    solution: j['x'] as String,
    trivial: j['t'] as bool? ?? false,
    variants: [
      for (final v in (j['r'] as List? ?? const [])) RestrictedVariant.fromJson((v as Map).cast<String, dynamic>()),
    ],
  );
}

class Lesson {
  const Lesson({required this.op, required this.example, required this.practice});

  final Enum op;
  final CatalogEntry example;
  final CatalogEntry practice;

  static final order = <Enum>[
    ...BinOp.values,
    UnOp.sqrt,
    UnOp.cbrt,
    UnOp.fact,
    UnOp.abs,
    UnOp.floor,
    UnOp.ceil,
    UnOp.neg,
  ];

  static Enum opByName(String name) => order.firstWhere((op) => op.name == name);

  static bool uses(Board board, Enum op) =>
      board.blocks.any((b) => b.descendants.any((n) => (n is Binary && n.op == op) || (n is Unary && n.op == op)));

  Map<String, dynamic> toJson() => {'op': op.name, 'example': example.toJson(), 'try': practice.toJson()};

  factory Lesson.fromJson(Map<String, dynamic> j) => Lesson(
    op: opByName(j['op'] as String),
    example: CatalogEntry.fromJson((j['example'] as Map).cast<String, dynamic>()),
    practice: CatalogEntry.fromJson((j['try'] as Map).cast<String, dynamic>()),
  );
}

class Catalog {
  Catalog(List<CatalogEntry> entries, {this.lessons = const []})
    : _byLevel = {
        for (final level in Level.values)
          level: [
            for (final e in entries)
              if (e.level == level) e,
          ],
      };

  factory Catalog.fromJsonString(String text) {
    final j = jsonDecode(text) as Map<String, dynamic>;
    return Catalog(
      [for (final e in j['entries'] as List) CatalogEntry.fromJson((e as Map).cast<String, dynamic>())],
      lessons: [
        for (final e in (j['lessons'] as List? ?? const [])) Lesson.fromJson((e as Map).cast<String, dynamic>()),
      ],
    );
  }

  static const quota = {Level.easy: 40, Level.intermediate: 40, Level.advanced: 35, Level.hard: 35};

  final Map<Level, List<CatalogEntry>> _byLevel;

  final List<Lesson> lessons;

  List<CatalogEntry> entriesFor(Level level) => _byLevel[level]!;

  Iterable<CatalogEntry> get all => Level.values.expand(entriesFor);

  int countFor(Level level) => _byLevel[level]!.length;

  int get length => _byLevel.values.fold(0, (a, l) => a + l.length);

  CatalogEntry? lookup(Level level, String number) => _byLevel[level]!.where((e) => e.number == number).firstOrNull;

  String toJsonString({int version = 2}) => const JsonEncoder.withIndent(' ').convert({
    'version': version,
    'entries': [
      for (final level in Level.values)
        for (final e in _byLevel[level]!) e.toJson(),
    ],
    'lessons': [for (final lesson in lessons) lesson.toJson()],
  });
}
