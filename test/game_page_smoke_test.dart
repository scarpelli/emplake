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
  testWidgets('help opens on the scoring tab and explains hints and the blind bonus', (tester) async {
    await tester.pumpWidget(_app(const HelpPage(initialTab: 2)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Bônus de tempo'), findsOneWidget);
    expect(find.textContaining('Às cegas'), findsOneWidget);
    await tester.tap(find.text('OPERADORES'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Fatorial'), findsWidgets);
  });

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

    Future<ProviderContainer> pumpGame(WidgetTester tester, {bool tutorialDone = false}) async {
      tester.view.physicalSize = const Size(420, 900);
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
