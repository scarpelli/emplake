import 'package:emplake/core/prefs.dart';
import 'package:emplake/core/theme/blueprint.dart';
import 'package:emplake/data/firestore_repository.dart';
import 'package:emplake/features/avatar/avatar_page.dart';
import 'package:emplake/features/avatar/robot_avatar.dart';
import 'package:emplake/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('every combination draws, and the seeded robot is stable', () {
    final a = RobotAvatar.fromSeed('abc');
    expect(RobotAvatar.fromSeed('abc'), a);
    expect(RobotAvatar.fromMap(a.toMap()), a);
    for (final p in RobotPart.values) {
      for (final v in robotOptions[p]!) {
        final svg = robotSvg(a.withPart(p, v), bg: Colors.blue, ink: Colors.white);
        expect(svg, isNot(contains('NaN')));
      }
    }
  });

  testWidgets('creator picks a part and shows its name', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({});
    final p = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(p),
          repositoryProvider.overrideWithValue(null),
          profileProvider.overrideWith((ref) async => null),
          authStateProvider.overrideWith((ref) => Stream.value(null)),
        ],
        child: MaterialApp(
          theme: ThemeData(extensions: [Blueprint.fromSeed(const Color(0xFF2460B7), Brightness.dark)]),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: const Scaffold(body: AvatarPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Seu robô'), findsOneWidget);
    expect(find.text('CABEÇA'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('cabeça: octógono'));
    await tester.pumpAndSettle();
    expect(find.text('octógono'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
