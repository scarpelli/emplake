import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../features/settings/settings_controller.dart';
import '../l10n_helpers.dart';
import '../theme/blueprint.dart';

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.text, {super.key, this.opacity = 0.7, this.color});

  final String text;
  final double opacity;
  final Color? color;

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: Theme.of(context).textTheme.labelSmall
        ?.copyWith(letterSpacing: 1.5, color: (color ?? context.bp.ink).withValues(alpha: opacity)),
  );
}

class PageTitle extends StatelessWidget {
  const PageTitle({super.key, required this.eyebrow, required this.title, this.trailing, this.leading});

  final String eyebrow;
  final String title;
  final Widget? trailing;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (leading != null) ...[leading!, const SizedBox(width: 8)],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Eyebrow(eyebrow),
              const SizedBox(height: 4),
              Text(title, style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}

class BoxIconButton extends StatelessWidget {
  const BoxIconButton({super.key, required this.icon, required this.onPressed, required this.tooltip, this.size = 44});

  final IconData icon;
  final VoidCallback? onPressed;
  final String tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    return Tooltip(
      message: tooltip,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(border: Border.all(color: bp.line)),
            alignment: Alignment.center,
            child: Icon(icon, size: 20, color: onPressed == null ? bp.faint : bp.ink),
          ),
        ),
      ),
    );
  }
}

class SoundToggle extends ConsumerWidget {
  const SoundToggle({super.key, this.size = 44});
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(settingsProvider.select((s) => s.anySound));
    final l = context.l10n;
    return BoxIconButton(
      icon: on ? Icons.volume_up_outlined : Icons.volume_off_outlined,
      tooltip: on ? l.soundOn : l.soundOff,
      size: size,
      onPressed: () => ref.read(settingsProvider.notifier).toggleSound(),
    );
  }
}

class LiveValuesToggle extends ConsumerWidget {
  const LiveValuesToggle({super.key, this.size = 44});
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final on = ref.watch(settingsProvider.select((s) => s.showLiveValues));
    final l = context.l10n;
    return BoxIconButton(
      icon: on ? Icons.visibility_outlined : Icons.visibility_off_outlined,
      tooltip: on ? l.liveValuesHide : l.liveValuesShow,
      size: size,
      onPressed: () => ref.read(settingsProvider.notifier).toggleLiveValues(),
    );
  }
}

class SelectTile extends StatelessWidget {
  const SelectTile({
    super.key,
    required this.selected,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(12),
    this.enabled = true,
  });

  final bool selected;
  final bool enabled;
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final fg = selected ? bp.onInk : bp.ink;
    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: selected ? bp.ink : Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: padding,
            decoration: BoxDecoration(border: Border.all(color: selected ? bp.ink : bp.line)),
            child: DefaultTextStyle.merge(
              style: TextStyle(color: fg),
              child: IconTheme.merge(
                data: IconThemeData(color: fg),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BpLoader extends StatelessWidget {
  const BpLoader({super.key, this.label, this.size = 44});

  final String? label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          LoadingAnimationWidget.hexagonDots(color: bp.ink, size: size),
          if (label != null) ...[const SizedBox(height: 16), Eyebrow(label!)],
        ],
      ),
    );
  }
}

class LanguageFlag extends StatelessWidget {
  const LanguageFlag(this.languageCode, {super.key, this.width = 28, this.height = 20});

  final String languageCode;
  final double width;
  final double height;

  static String countryFor(String lang) => switch (lang) {
    'pt' => 'BR',
    'es' => 'ES',
    _ => 'US',
  };

  static String nativeName(String lang) => switch (lang) {
    'pt' => 'Português',
    'es' => 'Español',
    _ => 'English',
  };

  @override
  Widget build(BuildContext context) => CountryFlag.fromCountryCode(
    countryFor(languageCode),
    theme: ImageTheme(width: width, height: height, shape: const Rectangle()),
  );
}

class LanguagePicker extends ConsumerWidget {
  const LanguagePicker({super.key, this.showNames = false});

  final bool showNames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = Localizations.localeOf(context).languageCode;
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final locale in supportedLocales)
          Semantics(
            button: true,
            selected: current == locale.languageCode,
            label: LanguageFlag.nativeName(locale.languageCode),
            child: SelectTile(
              selected: current == locale.languageCode,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              onTap: () => ref.read(settingsProvider.notifier).setLocale(locale),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LanguageFlag(locale.languageCode),
                  const SizedBox(width: 8),
                  Text(showNames ? LanguageFlag.nativeName(locale.languageCode) : locale.languageCode.toUpperCase()),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 560});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) => Align(
    alignment: Alignment.topCenter,
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: child,
    ),
  );
}
