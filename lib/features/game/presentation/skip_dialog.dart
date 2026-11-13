import 'package:flutter/material.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';

Future<bool?> showSkipDialog(BuildContext context) => showDialog<bool>(
  context: context,
  builder: (context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    return AlertDialog(
      title: Text(l.skipTitle, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
      content: Text(l.skipBody, style: t.bodyMedium?.copyWith(height: 1.45, color: context.bp.muted)),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: Text(l.cancel)),
        OutlinedButton(onPressed: () => Navigator.of(context).pop(false), child: Text(l.skipNo)),
        FilledButton(onPressed: () => Navigator.of(context).pop(true), child: Text(l.skipYes)),
      ],
    );
  },
);
