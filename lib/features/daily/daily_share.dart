import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/l10n_helpers.dart';
import '../../l10n/app_localizations.dart';
import 'daily.dart';
import 'native_share_stub.dart' if (dart.library.js_interop) 'native_share_web.dart';

DailyShareLabels dailyShareLabels(AppLocalizations l, {required int hints, required int streak}) => DailyShareLabels(
  title: l.modeDaily.toLowerCase(),
  hints: l.hintsCount(hints),
  blind: l.blindShort,
  streak: l.dailyStreakDays(streak),
  missed: l.dailyShareMissed,
);

/// Where the app is published; goes at the end of the shared scoreboard.
const dailyShareLink = 'https://emplake.web.app';

/// Opens the system share sheet; copies to the clipboard where there is none.
Future<void> shareDailyText(BuildContext context, String text) async {
  if (hasNativeShare) {
    try {
      final box = context.findRenderObject() as RenderBox?;
      await SharePlus.instance.share(
        ShareParams(text: text, sharePositionOrigin: box == null ? null : box.localToGlobal(Offset.zero) & box.size),
      );
      return;
    } catch (_) {
      // Fall through to the clipboard.
    }
  }
  if (!context.mounted) return;
  await copyDailyText(context, text);
}

Future<void> copyDailyText(BuildContext context, String text) async {
  await Clipboard.setData(ClipboardData(text: text));
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.copied)));
  }
}
