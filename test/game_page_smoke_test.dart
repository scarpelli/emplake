import 'package:emplake/core/prefs.dart';
import 'package:emplake/core/theme/blueprint.dart';
import 'package:emplake/data/firestore_repository.dart';
import 'package:emplake/features/achievements/achievement_toast.dart';
import 'package:emplake/features/achievements/achievements.dart';
import 'package:emplake/features/game/application/game_controller.dart';
import 'package:emplake/features/game/domain/expr.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/game/presentation/coach_overlay.dart';
import 'package:emplake/features/game/presentation/game_page.dart';
import 'package:emplake/features/help/help_page.dart';
import 'package:emplake/features/settings/settings_controller.dart';
import 'package:emplake/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _app(Widget home, {List overrides = const []}) => ProviderScope(
  overrides: [...overrides],
  child: MaterialApp(
    theme: ThemeData(extensions: [Blueprint.fromSeed(const Color(0xFF2460B7), Brightness.light)]),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: Scaffold(body: home),
  ),
);

void main() {
  for (final (label, size) in [('phone', const Size(390, 844)), ('desktop', const Size(1280, 800))]) {
    testWidgets('help dialog ($label) opens on the scoring tab and closes with GOT IT', (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        _app(
          Builder(
            builder: (context) => Center(
              child: TextButton(
                onPressed: () => showHelp(context, tab: HelpTab.scoring),
                child: const Text('help'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('help'));
      await tester.pumpAndSettle();
      expect(find.text('Como jogar'), findsOneWidget);
      expect(find.textContaining('Bônus de tempo'), findsOneWidget);
      expect(find.textContaining('Às cegas'), findsOneWidget);
      await tester.tap(find.text('OPERADORES'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Fatorial'), findsWidgets);
      await tester.tap(find.text('ENTENDI'));
      await tester.pumpAndSettle();
      expect(find.text('Como jogar'), findsNothing);
    });
  }

  testWidgets('achievements show at the top of the screen and leave by themselves', (tester) async {
    await tester.pumpWidget(
      _app(
        Builder(
          builder: (context) => Align(
            alignment: Alignment.bottomCenter,
            child: TextButton(
              onPressed: () => showAchievementToasts(context, [Achievement.firstSolve, Achievement.blind]),
              child: const Text('unlock'),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('unlock'));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('CONQUISTA DESBLOQUEADA'), findsOneWidget);
    expect(find.text('Primeira placa'), findsOneWidget);
    final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
    expect(tester.getTopLeft(find.text('Primeira placa')).dy, lessThan(screen.height / 3));
    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Primeira placa'), findsNothing);
    expect(find.text('Às cegas'), findsOneWidget);
    await tester.pump(const Duration(seconds: 5));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('CONQUISTA DESBLOQUEADA'), findsNothing);
  });

  group('game page', () {
    late SharedPreferences prefs;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      prefs = await SharedPreferences.getInstance();
    });

    Future<ProviderContainer> pumpGame(
      WidgetTester tester, {
      bool tutorialDone = false,
      Size size = const Size(420, 900),
    }) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final container = ProviderContainer(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
          profileProvider.overrideWith((ref) async => null),
        ],
      );
      if (tutorialDone) container.read(settingsProvider.notifier).markTutorialDone();
      container.read(gameControllerProvider.notifier).start(mode: GameMode.random, level: Level.easy, number: '1236');
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            theme: ThemeData(extensions: [Blueprint.fromSeed(const Color(0xFF2460B7), Brightness.light)]),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            locale: const Locale('pt'),
            home: const Scaffold(body: GamePage()),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 600));
      return container;
    }

    testWidgets('the first game shows the tutorial and it follows the board', (tester) async {
      final container = await pumpGame(tester);
      expect(find.byType(CoachOverlay), findsOneWidget);
      expect(find.textContaining('Toque no vão entre o 1 e o 2'), findsOneWidget);

      final c = container.read(gameControllerProvider.notifier);
      c.selectGap(0);
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.textContaining('escolha ×'), findsOneWidget);

      c.applyBinary(BinOp.mul);
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.textContaining('A árvore cresceu'), findsOneWidget);

      await tester.tap(find.text('PULAR TUTORIAL'));
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.byType(CoachOverlay), findsNothing);
      expect(container.read(settingsProvider).tutorialDone, isTrue);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
    });

    for (final (label, size) in [
      ('small phone', const Size(360, 640)),
      ('phone', const Size(390, 844)),
      ('tablet', const Size(768, 1024)),
      ('desktop', const Size(1280, 800)),
    ]) {
      testWidgets('tutorial balloon never covers what it points at ($label)', (tester) async {
        final container = await pumpGame(tester, size: size);
        final c = container.read(gameControllerProvider.notifier);

        Future<void> expectClear(String step) async {
          await tester.pump(const Duration(milliseconds: 600));
          final overlay = find.byType(CoachOverlay);
          // The balloon: the outermost balloon-sized Material around its skip button.
          final balloon = find
              .ancestor(of: find.text('PULAR TUTORIAL'), matching: find.byType(Material))
              .evaluate()
              .map((e) => tester.getRect(find.byWidget(e.widget)))
              .where((r) => r.width <= 300)
              .reduce((a, b) => a.height >= b.height ? a : b);
          final ring = find.descendant(of: overlay, matching: find.byType(IgnorePointer));
          expect(ring, findsWidgets, reason: '$step has no target ring');
          final target = tester.getRect(ring.last);
          final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
          expect(balloon.overlaps(target), isFalse, reason: '$step: balloon $balloon covers target $target');
          expect(balloon.left >= 0 && balloon.right <= screen.width, isTrue, reason: '$step: off screen');
          expect(balloon.top >= 0 && balloon.bottom <= screen.height, isTrue, reason: '$step: off screen');
        }

        await expectClear('tap first gap');
        c.selectGap(0);
        await expectClear('pick × (1st)');
        c.applyBinary(BinOp.mul);
        await expectClear('link the 3');
        c.selectGap(0);
        await expectClear('pick × (2nd)');
        c.applyBinary(BinOp.mul);
        await expectClear('equals gap');
        c.selectGap(0);
        await expectClear('pick =');
        c.placeEquals();
        await expectClear('verify');
        await tester.pumpWidget(const SizedBox());
        container.dispose();
      });
    }

    testWidgets('no tutorial after it is done; hint button and its banner work', (tester) async {
      final container = await pumpGame(tester, tutorialDone: true);
      expect(find.byType(CoachOverlay), findsNothing);
      container.read(gameControllerProvider.notifier).useHint('=(*(*(1,2),3),6)');
      await tester.pump(const Duration(milliseconds: 600));
      expect(find.text('DICA 1 DE 3'), findsOneWidget);
      expect(find.textContaining('O = fica entre o 3 e o 6'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      container.dispose();
    });
  });
}
