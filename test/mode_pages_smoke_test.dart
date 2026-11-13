import 'dart:io';

import 'package:emplake/core/prefs.dart';
import 'package:emplake/core/theme/blueprint.dart';
import 'package:emplake/data/firestore_repository.dart';
import 'package:emplake/features/adventure/adventure_page.dart';
import 'package:emplake/features/challenges/challenges_page.dart';
import 'package:emplake/features/game/application/catalog_provider.dart';
import 'package:emplake/features/game/application/game_controller.dart';
import 'package:emplake/features/game/domain/catalog.dart';
import 'package:emplake/features/game/domain/challenge.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/domain/rules.dart';
import 'package:emplake/features/game/presentation/game_page.dart';
import 'package:emplake/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _catalog = Catalog.fromJsonString(File('assets/catalog.json').readAsStringSync());

Future<Widget> _app(Widget home, {Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final p = await SharedPreferences.getInstance();
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(p),
      repositoryProvider.overrideWithValue(null),
      catalogProvider.overrideWith((ref) async => _catalog),
    ],
    child: MaterialApp(
      theme: ThemeData(extensions: [Blueprint.fromSeed(const Color(0xFF2460B7), Brightness.dark)]),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
      home: Scaffold(body: home),
    ),
  );
}

void main() {
  for (final size in const [Size(390, 844), Size(1600, 960)]) {
    testWidgets('adventure trail shows the whole collection (${size.width.toInt()} px)', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final easy = _catalog.entriesFor(Level.easy);
      await tester.pumpWidget(await _app(const AdventurePage(), prefs: {PrefKeys.adventure: '{"${easy[0].id}": 3}'}));
      await tester.pumpAndSettle();
      expect(find.text('1 / ${_catalog.length}'), findsOneWidget);
      expect(find.text('1/${easy.length}'), findsOneWidget);
      expect(find.text('atual'), findsWidgets);
      expect(find.text('CONTINUAR FASE 2'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('challenge cards show records and runs (${size.width.toInt()} px)', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        await _app(const ChallengesPage(), prefs: {PrefKeys.challenges: '{"clock": {"best": 11, "plays": 34}}'}),
      );
      await tester.pumpAndSettle();
      expect(find.text('Contra o relógio'), findsOneWidget);
      expect(find.text('Com restrição'), findsOneWidget);
      expect(find.text('11'), findsOneWidget);
      expect(find.text('34'), findsOneWidget);
      expect(find.text('JOGAR'), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('a restricted plate shows its rule and strikes the forbidden operator', (tester) async {
    tester.view.physicalSize = const Size(390, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final app = await _app(const GamePage(), prefs: {'settings.v1': '{"hintsVisible": false}'});
    await tester.pumpWidget(app);
    final container = ProviderScope.containerOf(tester.element(find.byType(GamePage)));
    container
        .read(gameControllerProvider.notifier)
        .start(
          mode: GameMode.challenges,
          level: Level.hard,
          number: '7107',
          run: const ChallengeRun(kind: ChallengeKind.restricted),
          restriction: const Restriction.forbid(BinOp.mul),
          solution: _catalog.lookup(Level.hard, '7107')!.variants.first.solution,
        );
    await tester.pump();
    expect(find.text('REGRA DA PLACA'), findsOneWidget);
    expect(find.textContaining('o × não pode ser usado'), findsOneWidget);
    expect(find.text('PULAR −♥'), findsOneWidget);
  });
}
