import 'package:emplake/core/prefs.dart';
import 'package:emplake/features/game/domain/level.dart';
import 'package:emplake/features/settings/settings_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('restore defaults resets preferences but keeps progress', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(c.dispose);
    final ctrl = c.read(settingsProvider.notifier)
      ..setThemeMode(ThemeMode.dark)
      ..setSeed(const Color(0xFF008966))
      ..setFontScale(1.3)
      ..setSfx(true)
      ..setLocale(const Locale('es'))
      ..setShowLiveValues(false)
      ..markTutorialDone()
      ..markLessonDone('add')
      ..setLastLevel(Level.hard);

    ctrl.resetToDefaults();

    final s = c.read(settingsProvider);
    expect(s.themeMode, ThemeMode.system);
    expect(s.seed, const AppSettings().seed);
    expect(s.fontScale, 1.0);
    expect(s.sfx, isFalse);
    expect(s.locale, isNull);
    expect(s.showLiveValues, isTrue);
    expect(s.tutorialDone, isTrue);
    expect(s.lessonsDone, {'add'});
    expect(s.lastLevel, Level.hard);
    final fresh = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(fresh.dispose);
    expect(fresh.read(settingsProvider).themeMode, ThemeMode.system);
  });

  test('the sound button turns effects and music on together, and both off', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final c = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(c.dispose);
    final ctrl = c.read(settingsProvider.notifier);
    expect(c.read(settingsProvider).anySound, isFalse);

    ctrl.toggleSound();
    expect(c.read(settingsProvider).sfx, isTrue);
    expect(c.read(settingsProvider).music, isTrue);

    ctrl.toggleSound();
    expect(c.read(settingsProvider).sfx, isFalse);
    expect(c.read(settingsProvider).music, isFalse);
  });
}
