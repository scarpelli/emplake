import 'package:flutter/material.dart';

import '../../../core/theme/blueprint.dart';

class FlyItem {
  const FlyItem({required this.label, required this.from, required this.to});
  final String label;
  final Offset from;
  final Offset to;
}

Future<void> runFlyBack(BuildContext context, List<FlyItem> items) async {
  if (items.isEmpty) return;
  final overlay = Overlay.of(context, rootOverlay: true);
  final bp = context.bp;
  final style = Theme.of(context).textTheme.titleMedium?.copyWith(color: bp.onAccent, fontWeight: FontWeight.w600);
  final controller = AnimationController(
    vsync: overlay,
    duration: Duration(milliseconds: 650 + 90 * (items.length - 1)),
  );
  final entry = OverlayEntry(
    builder: (_) => IgnorePointer(
      child: AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final total = controller.duration!.inMilliseconds.toDouble();
          return Stack(
            children: [
              for (var i = 0; i < items.length; i++)
                Builder(builder: (context) {
                  final start = 90 * i / total;
                  final end = (90 * i + 650) / total;
                  final raw = ((controller.value - start) / (end - start)).clamp(0.0, 1.0);
                  final t = Curves.easeInOutCubic.transform(raw);
                  final it = items[i];
                  final mid = Offset.lerp(it.from, it.to, 0.5)! - const Offset(0, 60);
                  final a = Offset.lerp(it.from, mid, t)!;
                  final b = Offset.lerp(mid, it.to, t)!;
                  final p = Offset.lerp(a, b, t)!;
                  final scale = 1.0 - 0.25 * t;
                  return Positioned(
                    left: p.dx - 18,
                    top: p.dy - 18,
                    child: Opacity(
                      opacity: raw >= 1 ? 0 : 1,
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          width: 36,
                          height: 36,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: bp.accent,
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.3), blurRadius: 8)],
                          ),
                          child: Text(it.label, style: style),
                        ),
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    ),
  );
  overlay.insert(entry);
  try {
    await controller.forward();
  } finally {
    entry.remove();
    controller.dispose();
  }
}
