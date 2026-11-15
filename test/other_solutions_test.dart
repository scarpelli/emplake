import 'dart:io';

import 'package:emplake/core/theme/blueprint.dart';
import 'package:emplake/features/game/domain/catalog.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/solution_codec.dart';
import 'package:emplake/features/game/domain/solver.dart';
import 'package:emplake/features/game/presentation/other_solutions.dart';
import 'package:emplake/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) => ProviderScope(
  child: MaterialApp(
    theme: ThemeData(extensions: [Blueprint.fromSeed(const Color(0xFF2460B7), Brightness.light)]),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  ),
);

void main() {
  testWidgets('shows how many other solutions there are and lists the simplest when opened', (tester) async {
    final mine = SolutionCodec.decode('6359', '=(6,-(*(3,5),9))');
    await tester.pumpWidget(_app(OtherSolutions(level: Level.intermediate, board: mine)));
    expect(find.textContaining('SOLUÇ'), findsNothing);

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    final header = find.textContaining('OUTRAS');
    expect(header, findsOneWidget);
    expect(find.bySemanticsLabel('6 = 3 × 5 − 9'), findsNothing);

    await tester.tap(header);
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('6 = 3 × (5 − √9)'), findsOneWidget);
  });

  testWidgets('stays hidden when the player found the only solution', (tester) async {
    final catalog = Catalog.fromJsonString(File('assets/catalog.json').readAsStringSync());
    final only = [
      for (final level in Level.values)
        for (final e in catalog.entriesFor(level))
          if (SolutionFinder(level).find(e.number) case [final single]) (level, single),
    ].first;
    await tester.pumpWidget(_app(OtherSolutions(level: only.$1, board: only.$2)));
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();
    expect(find.byType(InkWell), findsNothing);
  });
}
