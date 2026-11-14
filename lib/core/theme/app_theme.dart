import 'package:flutter/material.dart';

import '../../features/settings/settings_controller.dart';
import 'blueprint.dart';

ThemeData buildTheme(AppSettings s, Brightness brightness) {
  final bp = Blueprint.fromSeed(s.seed, brightness);
  final base = ColorScheme.fromSeed(seedColor: s.seed, brightness: brightness);
  final scheme = base.copyWith(
    primary: bp.ink,
    onPrimary: bp.onInk,
    secondary: bp.accent,
    onSecondary: bp.onAccent,
    surface: bp.paper,
    onSurface: bp.ink,
    surfaceContainerHighest: bp.deep,
    surfaceContainerHigh: bp.panel,
    surfaceContainer: bp.panel,
    outline: bp.line,
    outlineVariant: bp.lineSoft,
    error: bp.danger,
  );
  final typography = Typography.material2021(platform: TargetPlatform.android);
  final baseText = brightness == Brightness.dark ? typography.white : typography.black;
  final family = s.font.family;
  final text = baseText.apply(fontFamily: family, bodyColor: bp.ink, displayColor: bp.ink);
  const square = RoundedRectangleBorder(borderRadius: BorderRadius.zero);

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    fontFamily: family,
    colorScheme: scheme,
    scaffoldBackgroundColor: bp.paper,
    textTheme: text,
    extensions: [bp],
    dividerColor: bp.lineSoft,
    iconTheme: IconThemeData(color: bp.ink),
    appBarTheme: AppBarTheme(backgroundColor: bp.paper, foregroundColor: bp.ink, elevation: 0),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: bp.ink,
        foregroundColor: bp.onInk,
        shape: square,
        minimumSize: const Size(48, 48),
        textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: bp.ink,
        side: BorderSide(color: bp.ink),
        shape: square,
        minimumSize: const Size(48, 48),
        textStyle: text.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: bp.ink,
        foregroundColor: bp.onInk,
        shape: square,
        minimumSize: const Size(48, 48),
      ),
    ),
    textButtonTheme: TextButtonThemeData(style: TextButton.styleFrom(foregroundColor: bp.ink)),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: bp.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: bp.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.zero,
        borderSide: BorderSide(color: bp.ink, width: 2),
      ),
      labelStyle: TextStyle(color: bp.muted),
      floatingLabelStyle: TextStyle(color: bp.ink),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: bp.panel,
      shape: RoundedRectangleBorder(side: BorderSide(color: bp.line)),
    ),
    bottomSheetTheme: BottomSheetThemeData(backgroundColor: bp.panel, shape: square),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: bp.ink,
      contentTextStyle: text.bodyMedium?.copyWith(color: bp.onInk),
      behavior: SnackBarBehavior.floating,
      shape: square,
    ),
    sliderTheme: SliderThemeData(
      activeTrackColor: bp.ink,
      inactiveTrackColor: bp.lineSoft,
      thumbColor: bp.ink,
      overlayColor: bp.ink.withValues(alpha: 0.15),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((s) => s.contains(WidgetState.selected) ? bp.onInk : bp.ink),
      trackColor: WidgetStateProperty.resolveWith(
        (s) => s.contains(WidgetState.selected) ? bp.ink : Colors.transparent,
      ),
      trackOutlineColor: WidgetStatePropertyAll(bp.ink),
    ),
    tooltipTheme: TooltipThemeData(
      waitDuration: const Duration(milliseconds: 700),
      decoration: BoxDecoration(color: bp.ink),
      textStyle: text.bodySmall?.copyWith(color: bp.onInk),
    ),
    progressIndicatorTheme: ProgressIndicatorThemeData(color: bp.ink),
  );
}
