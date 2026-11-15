import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/theme/blueprint.dart';

enum BalloonAt {
  auto,

  below,

  above,
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
            Positioned.fill(
              child: CustomSingleChildLayout(
                delegate: BalloonLayout(target: at, prefer: widget.step.balloon),
                child: balloon,
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Places the balloon next to the target without ever covering it (or its
/// ring). It measures the balloon first, so it holds for any text length,
/// font size, language and screen: it tries the preferred side, then the
/// other one, then left/right of the target, and only as a last resort the
/// side with the most room.
class BalloonLayout extends SingleChildLayoutDelegate {
  BalloonLayout({required this.target, required this.prefer});

  final Offset? target;
  final BalloonAt prefer;

  static const maxWidth = 280.0;
  static const margin = 8.0;

  /// Distance kept from the target's centre: ring radius plus a gap.
  static const clearance = 40.0;

  @override
  BoxConstraints getConstraintsForChild(BoxConstraints constraints) => BoxConstraints(
    maxWidth: (constraints.maxWidth - 2 * margin).clamp(0, maxWidth),
    maxHeight: (constraints.maxHeight - 2 * margin).clamp(0, double.infinity),
  );

  @override
  Offset getPositionForChild(Size size, Size childSize) {
    final child = childSize;
    double clampX(double x) => x.clamp(margin, math.max(margin, size.width - child.width - margin));
    double clampY(double y) => y.clamp(margin, math.max(margin, size.height - child.height - margin));

    final at = target;
    if (at == null) return Offset(clampX((size.width - child.width) / 2), margin);

    final x = clampX(at.dx - child.width / 2);
    final roomBelow = size.height - margin - (at.dy + clearance);
    final roomAbove = at.dy - clearance - margin;
    final below = Offset(x, at.dy + clearance);
    final above = Offset(x, at.dy - clearance - child.height);

    final order = switch (prefer) {
      BalloonAt.below => [true, false],
      BalloonAt.above => [false, true],
      BalloonAt.auto => roomBelow >= roomAbove ? [true, false] : [false, true],
    };
    for (final b in order) {
      if (b && roomBelow >= child.height) return below;
      if (!b && roomAbove >= child.height) return above;
    }

    // Not enough height on either side (short landscape screens): go beside.
    final y = clampY(at.dy - child.height / 2);
    if (size.width - margin - (at.dx + clearance) >= child.width) return Offset(at.dx + clearance, y);
    if (at.dx - clearance - margin >= child.width) return Offset(at.dx - clearance - child.width, y);

    return roomBelow >= roomAbove ? Offset(x, clampY(below.dy)) : Offset(x, clampY(above.dy));
  }

  @override
  bool shouldRelayout(BalloonLayout old) => old.target != target || old.prefer != prefer;
}
