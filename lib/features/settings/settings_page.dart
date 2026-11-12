import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_helpers.dart';
import '../../core/prefs.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../data/firestore_repository.dart';
import '../game/application/game_controller.dart';
import 'settings_controller.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final ctrl = ref.read(settingsProvider.notifier);
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;

    Widget section(String title, List<Widget> children) => Padding(
          padding: const EdgeInsets.only(bottom: 22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [Eyebrow(title), const SizedBox(height: 8), ...children],
          ),
        );

    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          PageTitle(eyebrow: l.settingsEyebrow, title: l.settingsTitle),
          const SizedBox(height: 20),
          section(l.theme, [
            Row(
              children: [
                for (final (mode, icon, label) in [
                  (ThemeMode.system, Icons.smartphone, l.themeSystem),
                  (ThemeMode.light, Icons.light_mode_outlined, l.themeLight),
                  (ThemeMode.dark, Icons.dark_mode_outlined, l.themeDark),
                ])
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: mode == ThemeMode.dark ? 0 : 6),
                      child: SelectTile(
                        selected: s.themeMode == mode,
                        onTap: () => ctrl.setThemeMode(mode),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        child: Column(children: [Icon(icon, size: 20), const SizedBox(height: 4), Text(label)]),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            Text(l.themeHint, style: t.bodySmall?.copyWith(color: bp.muted)),
          ]),
          section(l.presets, [
            Row(
              children: [
                for (final p in ThemePreset.values)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(right: p == ThemePreset.values.last ? 0 : 6),
                      child: _PresetCard(
                        preset: p,
                        selected: s.preset == p,
                        onTap: () => ctrl.setSeed(p.seed),
                      ),
                    ),
                  ),
              ],
            ),
          ]),
          section(l.seedColor, [
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final c in seedSwatches)
                  _Swatch(color: c, selected: s.seed.toARGB32() == c.toARGB32(), onTap: () => ctrl.setSeed(c)),
                Tooltip(
                  message: l.pickColor,
                  child: InkWell(
                    onTap: () async {
                      final picked = await showColorPickerDialog(
                        context,
                        s.seed,
                        title: Text(l.pickColor, style: t.titleMedium),
                        pickersEnabled: const {
                          ColorPickerType.primary: true,
                          ColorPickerType.accent: false,
                          ColorPickerType.wheel: true,
                        },
                        enableShadesSelection: false,
                        actionButtons: const ColorPickerActionButtons(dialogActionButtons: true),
                        copyPasteBehavior: const ColorPickerCopyPasteBehavior(),
                      );
                      ctrl.setSeed(picked);
                    },
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(border: Border.all(color: bp.line)),
                      child: const Icon(Icons.colorize, size: 20),
                    ),
                  ),
                ),
              ],
            ),
          ]),
          section(l.fontSize, [
            Row(
              children: [
                Text('A', style: t.bodySmall),
                Expanded(
                  child: Slider(
                    value: s.fontScale,
                    min: 0.8,
                    max: 1.4,
                    divisions: 6,
                    label: '${(s.fontScale * 100).round()}%',
                    semanticFormatterCallback: (v) => '${(v * 100).round()}%',
                    onChanged: ctrl.setFontScale,
                  ),
                ),
                Text('A', style: t.titleLarge),
                const SizedBox(width: 10),
                SizedBox(width: 48, child: Text('${(s.fontScale * 100).round()}%', textAlign: TextAlign.end)),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(border: Border.all(color: bp.lineSoft)),
              child: Text(l.fontSample, style: t.bodyLarge),
            ),
          ]),
          section(l.fontFamily, [
            for (final f in AppFont.values)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: SelectTile(
                  selected: s.font == f,
                  onTap: () => ctrl.setFont(f),
                  child: Builder(builder: (context) {
                    final fg = s.font == f ? bp.onInk : bp.ink;
                    final family = fontFamilyOf(f);
                    return Row(children: [
                      Expanded(child: Text(f.label, style: TextStyle(fontFamily: family, color: fg))),
                      Text('9 − 2 = 7', style: TextStyle(fontFamily: family, color: fg, fontSize: 16)),
                    ]);
                  }),
                ),
              ),
          ]),
          section(l.sound, [
            _SwitchRow(label: l.soundEffects, value: s.sfx, onChanged: ctrl.setSfx),
            _SwitchRow(label: l.music, value: s.music, onChanged: ctrl.setMusic),
          ]),
          section(l.languageSection, [const LanguagePicker(showNames: true)]),
          section(l.account, [const _AccountRow()]),
        ],
      ),
    );
  }
}

class _PresetCard extends StatelessWidget {
  const _PresetCard({required this.preset, required this.selected, required this.onTap});
  final ThemePreset preset;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final brightness = Theme.of(context).brightness;
    final look = Blueprint.fromSeed(preset.seed, brightness);
    final name = switch (preset) {
      ThemePreset.blueprint => l.presetBlueprint,
      ThemePreset.graphite => l.presetGraphite,
      ThemePreset.sepia => l.presetSepia,
      ThemePreset.forest => l.presetForest,
    };
    return Semantics(
      button: true,
      selected: selected,
      label: name,
      child: InkWell(
        onTap: onTap,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: look.paper,
                border: Border.all(color: selected ? context.bp.accent : look.line, width: selected ? 2.5 : 1),
              ),
              child: Text('9+2', style: TextStyle(color: look.ink, fontWeight: FontWeight.w600, fontSize: 16)),
            ),
            const SizedBox(height: 4),
            Text(name, style: Theme.of(context).textTheme.labelSmall, overflow: TextOverflow.ellipsis),
          ],
        ),
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.selected, required this.onTap});
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: selected ? context.bp.ink : Colors.transparent, width: 3),
            ),
            child: selected ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
          ),
        ),
      );
}

class _SwitchRow extends StatelessWidget {
  const _SwitchRow({required this.label, required this.value, required this.onChanged});
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.only(left: 12, right: 4),
        decoration: BoxDecoration(border: Border.all(color: context.bp.lineSoft)),
        child: SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(label),
          value: value,
          onChanged: onChanged,
        ),
      );
}

class _AccountRow extends ConsumerWidget {
  const _AccountRow();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final user = ref.watch(authStateProvider).value;
    final isGoogle = user?.providerData.any((p) => p.providerId == 'google.com') ?? false;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: bp.line)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(user?.displayName?.isNotEmpty == true ? user!.displayName! : l.player,
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text('${user?.email ?? ''} · ${isGoogle ? l.providerGoogle : l.providerEmail}',
                    style: t.bodySmall?.copyWith(color: bp.muted)),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: () async {
              ref.read(gameControllerProvider.notifier).clear();
              await ref.read(sharedPreferencesProvider).remove(PrefKeys.lastLocation);
              await ref.read(firebaseAuthProvider).signOut();
            },
            icon: const Icon(Icons.logout, size: 18),
            label: Text(l.signOut),
          ),
        ],
      ),
    );
  }
}
