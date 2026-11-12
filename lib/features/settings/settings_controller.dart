import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/prefs.dart';

enum ThemePreset {
  blueprint(Color(0xFF2460B7)),
  graphite(Color(0xFF4E5661)),
  sepia(Color(0xFF8A5A2B)),
  forest(Color(0xFF008966));

  const ThemePreset(this.seed);
  final Color seed;
}

enum AppFont {
  plexMono('IBM Plex Mono'),
  roboto('Roboto'),
  garamond('EB Garamond'),
  helvetica('Helvetica');

  const AppFont(this.label);
  final String label;
}

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
    this.font = AppFont.plexMono,
    this.sfx = false,
    this.music = false,
    this.locale,
  });

  final ThemeMode themeMode;
  final Color seed;
  final double fontScale;
  final AppFont font;

  final bool sfx;
  final bool music;

  final Locale? locale;

  bool get anySound => sfx || music;

  ThemePreset? get preset {
    for (final p in ThemePreset.values) {
      if (p.seed.toARGB32() == seed.toARGB32()) return p;
    }
    return null;
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    Color? seed,
    double? fontScale,
    AppFont? font,
    bool? sfx,
    bool? music,
    Locale? locale,
  }) =>
      AppSettings(
        themeMode: themeMode ?? this.themeMode,
        seed: seed ?? this.seed,
        fontScale: fontScale ?? this.fontScale,
        font: font ?? this.font,
        sfx: sfx ?? this.sfx,
        music: music ?? this.music,
        locale: locale ?? this.locale,
      );

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.name,
        'seed': seed.toARGB32(),
        'fontScale': fontScale,
        'font': font.name,
        'sfx': sfx,
        'music': music,
        if (locale != null) 'locale': locale!.languageCode,
      };

  factory AppSettings.fromJson(Map<String, dynamic> j) {
    T byName<T extends Enum>(List<T> values, Object? name, T fallback) =>
        values.where((v) => v.name == name).firstOrNull ?? fallback;
    return AppSettings(
      themeMode: byName(ThemeMode.values, j['themeMode'], ThemeMode.system),
      seed: Color(j['seed'] as int? ?? 0xFF2460B7),
      fontScale: (j['fontScale'] as num?)?.toDouble() ?? 1.0,
      font: byName(AppFont.values, j['font'], AppFont.plexMono),
      sfx: j['sfx'] as bool? ?? false,
      music: j['music'] as bool? ?? false,
      locale: j['locale'] == null ? null : Locale(j['locale'] as String),
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
  void setFont(AppFont font) => _set(state.copyWith(font: font));
  void setSfx(bool on) => _set(state.copyWith(sfx: on));
  void setMusic(bool on) => _set(state.copyWith(music: on));
  void setLocale(Locale locale) => _set(state.copyWith(locale: locale));

  void toggleSound() {
    if (state.anySound) {
      _set(state.copyWith(sfx: false, music: false));
    } else {
      _set(state.copyWith(sfx: true));
    }
  }
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(SettingsController.new);
