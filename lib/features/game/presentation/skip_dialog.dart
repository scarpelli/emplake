import 'package:flutter/material.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';
import '../application/game_controller.dart';

Future<bool?> showSkipDialog(BuildContext context, GameMode mode) {
  final l = context.l10n;
  return showChoiceDialog(
    context,
    title: l.skipTitle,
    body: switch (mode) {
      GameMode.adventure => l.skipBodyAdventure,
      GameMode.daily => l.skipBodyDaily,
      GameMode.random => l.skipBody,
      _ => l.skipBodyRetry,
    },
    primary: l.skipYes,
    secondary: l.skipNo,
  );
}

Future<bool?> showChoiceDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String primary,
  String? secondary,
}) => showDialog<bool>(
  context: context,
  builder: (context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 12, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    Text(body, style: t.bodyMedium?.copyWith(height: 1.45, color: context.bp.muted)),
                    const SizedBox(height: 24),
                    FilledButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(primary, textAlign: TextAlign.center),
                    ),
                    if (secondary != null) ...[
                      const SizedBox(height: 10),
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: Text(secondary, textAlign: TextAlign.center),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  },
);
