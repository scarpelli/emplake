import 'package:flutter/material.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../game/domain/level.dart';

Future<void> showHelpDialog(BuildContext context) => showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (_) => const HelpDialog(),
    );

class HelpDialog extends StatelessWidget {
  const HelpDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final steps = [l.help1, l.help2, l.help3, l.help4];

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(l.helpTitle,
                        style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5)),
                  ),
                  BoxIconButton(
                    icon: Icons.close,
                    tooltip: l.helpGotIt,
                    size: 40,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              for (var i = 0; i < steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: bp.ink)),
                        child: Text('${i + 1}', style: t.labelMedium),
                      ),
                      const SizedBox(width: 12),
                      Expanded(child: Text(steps[i], style: t.bodyMedium?.copyWith(height: 1.45))),
                    ],
                  ),
                ),
              const SizedBox(height: 4),
              Container(
                decoration: BoxDecoration(border: Border.all(color: bp.lineSoft)),
                child: Column(
                  children: [
                    for (final level in Level.values)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: level == Level.values.last
                              ? null
                              : Border(bottom: BorderSide(color: bp.lineSoft)),
                        ),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 118,
                              child: Text(level.label(l), style: t.labelLarge?.copyWith(fontWeight: FontWeight.w600)),
                            ),
                            Expanded(
                              child: Text(
                                level == Level.easy ? l.helpEasyOps : level.operatorLabels.join(' '),
                                style: t.bodySmall?.copyWith(color: bp.muted),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(l.helpFraction, style: t.bodySmall?.copyWith(color: bp.muted)),
              const SizedBox(height: 16),
              FilledButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.helpGotIt)),
            ],
          ),
        ),
      ),
    );
  }
}
