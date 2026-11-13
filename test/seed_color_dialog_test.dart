import 'package:emplake/core/theme/blueprint.dart';
import 'package:emplake/features/settings/seed_color_dialog.dart';
import 'package:emplake/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Color? result;

  Future<void> Function() open(WidgetTester tester) {
    result = null;
    return () async {
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [Blueprint.fromSeed(const Color(0xFF2460B7), Brightness.light)]),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: const Locale('pt'),
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () async {
                result = await showSeedColorDialog(context, const Color(0xFF2460B7));
              },
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
    };
  }

  testWidgets('hex field + OK returns the typed color', (tester) async {
    await open(tester)();
    expect(find.byType(SeedColorDialog), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'c85b32');
    await tester.pump();
    await tester.tap(find.byType(FilledButton));
    await tester.pumpAndSettle();
    expect(find.byType(SeedColorDialog), findsNothing);
    expect(result?.toARGB32(), 0xFFC85B32);
  });

  testWidgets('closing without OK returns null', (tester) async {
    await open(tester)();
    await tester.tap(find.byType(OutlinedButton));
    await tester.pumpAndSettle();
    expect(result, isNull);
  });

  testWidgets('dragging on the square and hue bar changes the hex', (tester) async {
    await open(tester)();
    final field = tester.widget<TextField>(find.byType(TextField));
    final before = field.controller!.text;
    await tester.tapAt(tester.getCenter(find.byType(AspectRatio)) + const Offset(40, 40));
    await tester.pump();
    final afterSquare = field.controller!.text;
    expect(afterSquare, isNot(before));
    final bar = find.byWidgetPredicate((w) => w is SizedBox && w.height == 28);
    await tester.tapAt(tester.getTopLeft(bar) + const Offset(20, 14));
    await tester.pump();
    expect(field.controller!.text, isNot(afterSquare));
  });
}
