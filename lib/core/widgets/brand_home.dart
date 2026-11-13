import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../l10n_helpers.dart';
import '../theme/blueprint.dart';
import 'bp_widgets.dart';
import 'emplake_logo.dart';

class BrandHome extends StatelessWidget {
  const BrandHome({super.key, this.logoSize = 36, this.wordmark = true});

  final double logoSize;
  final bool wordmark;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Semantics(
      button: true,
      label: context.l10n.homePage,
      excludeSemantics: true,
      child: Tooltip(
        message: context.l10n.homePage,
        child: MouseRegion(
          cursor: SystemMouseCursors.click,
          child: InkWell(
            onTap: () => context.go('/play'),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  EmplakeLogo(size: logoSize),
                  if (wordmark) ...[
                    const SizedBox(width: 10),
                    Text('EMPLAKE', style: t.titleLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 4)),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class ModeHeader extends StatelessWidget {
  const ModeHeader({super.key, required this.title, this.trailing, this.helpScoring = false});

  final String title;
  final Widget? trailing;

  final bool helpScoring;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, c) {
        final wide = c.maxWidth >= 560;
        return Container(
          padding: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: bp.lineSoft)),
          ),
          child: Row(
            children: [
              BrandHome(logoSize: wide ? 36 : 30, wordmark: wide),
              Container(width: 1, height: 40, margin: const EdgeInsets.symmetric(horizontal: 16), color: bp.lineSoft),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Eyebrow(context.l10n.infoMode, opacity: 0.6),
                    Text(
                      title.toUpperCase(),
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              ?trailing,
              const SizedBox(width: 12),
              HelpButton(scoring: helpScoring),
              const SizedBox(width: 8),
              const SoundToggle(),
            ],
          ),
        );
      },
    );
  }
}
