import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/prefs.dart';
import '../game/domain/level.dart';

const seedSwatches = <Color>[
  Color(0xFF2460B7),
  Color(0xFF008966),
  Color(0xFFC85B32),
  Color(0xFFA644A0),
  Color(0xFFA88D10),
  Color(0xFF4E5661),
];

const supportedLocales = [Locale('pt'), Locale('en'), Locale('es')];

@immutable
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.system,
    this.seed = const Color(0xFF2460B7),
    this.fontScale = 1.0,
    this.sfx = false,
    this.music = false,
    this.locale,
    this.showLiveValues = true,
    this.showHints = true,
    this.tutorialDone = false,
    this.latexOpen = false,
    this.lastLevel = Level.easy,
    this.haptics = true,
    this.reduceMotion = false,
    this.lessonsDone = const {},
  });

  final ThemeMode themeMode;
  final Color seed;
  final double fontScale;

  final bool sfx;
  final bool music;

  final Locale? locale;

  final bool showLiveValues;

  final bool showHints;
  final bool tutorialDone;

  final bool latexOpen;

  final Level lastLevel;

  final bool haptics;

  final bool reduceMotion;

  final Set<String> lessonsDone;

  bool get hintsVisible => showHints && !tutorialDone;

  bool get anySound => sfx || music;

  AppSettings copyWith({
    ThemeMode? themeMode,
    Color? seed,
    double? fontScale,
    bool? sfx,
    bool? music,
    Locale? locale,
    bool? showLiveValues,
    bool? showHints,
    bool? tutorialDone,
    bool? latexOpen,
    Level? lastLevel,
    bool? haptics,
    bool? reduceMotion,
    Set<String>? lessonsDone,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    seed: seed ?? this.seed,
    fontScale: fontScale ?? this.fontScale,
    sfx: sfx ?? this.sfx,
    music: music ?? this.music,
    locale: locale ?? this.locale,
    showLiveValues: showLiveValues ?? this.showLiveValues,
    showHints: showHints ?? this.showHints,
    tutorialDone: tutorialDone ?? this.tutorialDone,
    latexOpen: latexOpen ?? this.latexOpen,
    lastLevel: lastLevel ?? this.lastLevel,
    haptics: haptics ?? this.haptics,
    reduceMotion: reduceMotion ?? this.reduceMotion,
    lessonsDone: lessonsDone ?? this.lessonsDone,
  );

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.name,
    'seed': seed.toARGB32(),
    'fontScale': fontScale,
    'sfx': sfx,
    'music': music,
    if (locale != null) 'locale': locale!.languageCode,
    'liveValues': showLiveValues,
    'hints': showHints,
    'tutorialDone': tutorialDone,
    'latexOpen': latexOpen,
    'lastLevel': lastLevel.name,
    'haptics': haptics,
    'reduceMotion': reduceMotion,
    'lessonsDone': lessonsDone.toList(),
  };

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    T byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    return AppSettings(
      themeMode: byName(ThemeMode.values, j['themeMode'], ThemeMode.system),
      seed: Color(j['seed'] as int? ?? 0xFF2460B7),
      fontScale: (j['fontScale'] as num?)?.toDouble() ?? 1.0,
      sfx: j['sfx'] as bool? ?? false,
      music: j['music'] as bool? ?? false,
      locale: j['locale'] == null ? null : Locale(j['locale'] as String),
      showLiveValues: j['liveValues'] as bool? ?? true,
      showHints: j['hints'] as bool? ?? true,
      tutorialDone: j['tutorialDone'] as bool? ?? false,
      latexOpen: j['latexOpen'] as bool? ?? false,
      lastLevel: byName(Level.values, j['lastLevel'], Level.easy),
      haptics: j['haptics'] as bool? ?? true,
      reduceMotion: j['reduceMotion'] as bool? ?? false,
      lessonsDone: {...(j['lessonsDone'] as List? ?? const []).cast<String>()},
    );
  }
}

class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final raw = ref.read(sharedPreferencesProvider).getString(PrefKeys.settings);
    if (raw == null) return const AppSettings();
    try {
      return AppSettings.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const AppSettings();
    }
  }

  void _set(AppSettings value) {
    state = value;
    ref.read(sharedPreferencesProvider).setString(PrefKeys.settings, jsonEncode(value.toJson()));
  }

  void setThemeMode(ThemeMode mode) => _set(state.copyWith(themeMode: mode));
  void setSeed(Color seed) => _set(state.copyWith(seed: seed));
  void setFontScale(double scale) => _set(state.copyWith(fontScale: scale));
  void setSfx(bool on) => _set(state.copyWith(sfx: on));
  void setMusic(bool on) => _set(state.copyWith(music: on));
  void setLocale(Locale locale) => _set(state.copyWith(locale: locale));
  void setShowLiveValues(bool on) => _set(state.copyWith(showLiveValues: on));
  void toggleLiveValues() => setShowLiveValues(!state.showLiveValues);
  void setLatexOpen(bool open) => _set(state.copyWith(latexOpen: open));
  void setHaptics(bool on) => _set(state.copyWith(haptics: on));
  void setReduceMotion(bool on) => _set(state.copyWith(reduceMotion: on));
  void markLessonDone(String op) {
    if (!state.lessonsDone.contains(op)) _set(state.copyWith(lessonsDone: {...state.lessonsDone, op}));
  }

  void setLastLevel(Level level) {
    if (state.lastLevel != level) _set(state.copyWith(lastLevel: level));
  }

  void setShowHints(bool on) => _set(state.copyWith(showHints: on, tutorialDone: on ? false : null));

  void markTutorialDone() {
    if (!state.tutorialDone) _set(state.copyWith(tutorialDone: true));
  }

  void toggleSound() {
    if (state.anySound) {
      _set(state.copyWith(sfx: false, music: false));
    } else {
      _set(state.copyWith(sfx: true));
    }
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
