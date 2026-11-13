import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';

enum BalloonAt {
  auto,

  below,

  top,
}

class CoachStep {
  const CoachStep({required this.text, this.target, this.balloon = BalloonAt.auto});

  final String text;
  final BalloonAt balloon;

  final Offset? Function()? target;
}

class CoachOverlay extends StatefulWidget {
  const CoachOverlay({super.key, required this.step, required this.onSkip});

  final CoachStep step;
  final VoidCallback onSkip;

  @override
  State<CoachOverlay> createState() => _CoachOverlayState();
}

class _CoachOverlayState extends State<CoachOverlay> with SingleTickerProviderStateMixin {
  late final Ticker _ticker = createTicker((elapsed) {
    _t = elapsed.inMilliseconds / 1000;
    if (mounted) setState(() {});
  })..start();
  double _t = 0;

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final box = context.findRenderObject() as RenderBox?;
    final global = widget.step.target?.call();
    final Offset? at = (box != null && box.hasSize && global != null) ? box.globalToLocal(global) : null;
    final reduce = MediaQuery.disableAnimationsOf(context);
    final pulse = reduce ? 0.5 : (0.5 + 0.5 * ((_t * 2) % 1));

    return LayoutBuilder(
      builder: (context, c) {
        const balloonW = 280.0;
        final place = widget.step.balloon;
        final below =
            at == null ||
            (place == BalloonAt.below && at.dy + 180 < c.maxHeight) ||
            (place == BalloonAt.auto && at.dy < c.maxHeight / 2);
        const topSlot = 112.0;
        final left = ((at?.dx ?? c.maxWidth / 2) - balloonW / 2).clamp(8.0, c.maxWidth - balloonW - 8);
        final balloon = Material(
          color: bp.ink,
          elevation: 6,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 6, 6),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Semantics(
                  liveRegion: true,
                  child: Text(widget.step.text, style: t.bodyMedium?.copyWith(color: bp.onInk, height: 1.4)),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: widget.onSkip,
                    style: TextButton.styleFrom(foregroundColor: bp.onInk),
                    child: Text(l.tutorialSkip),
                  ),
                ),
              ],
            ),
          ),
        );
        return Stack(
          children: [
            if (at != null)
              Positioned(
                left: at.dx - 32,
                top: at.dy - 32,
                child: IgnorePointer(
                  child: Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: bp.accent.withValues(alpha: 1 - pulse * 0.6),
                        width: 3 + 3 * pulse,
                      ),
                    ),
                  ),
                ),
              ),
            Positioned(
              left: left,
              width: balloonW,
              top: at == null
                  ? 12
                  : place == BalloonAt.top
                  ? topSlot
                  : (below ? at.dy + 40 : null),
              bottom: at != null && place != BalloonAt.top && !below ? c.maxHeight - at.dy + 40 : null,
              child: balloon,
            ),
          ],
        );
      },
    );
  }
}
