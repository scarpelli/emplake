import 'dart:ui';

import 'package:flutter/material.dart';

import '../theme/blueprint.dart';

class EmplakeLogo extends StatelessWidget {
  const EmplakeLogo({super.key, this.size = 48, this.colors});

  final double size;

  final Blueprint? colors;

  @override
  Widget build(BuildContext context) => SizedBox.square(
    dimension: size,
    child: CustomPaint(painter: EmplakeLogoPainter(colors ?? context.bp, grid: size >= 40)),
  );
}

class EmplakeLogoPainter extends CustomPainter {
  const EmplakeLogoPainter(
    this.colors, {
    this.grid = true,
    this.maskable = false,
    this.cornerRadius = 0.2,
    this.progress = 1,
  });

  final Blueprint colors;

  final bool grid;

  final bool maskable;

  final double cornerRadius;

  final double progress;

  double _phase(double from, double to) => ((progress - from) / (to - from)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    final side = size.shortestSide;
    final sheet = Offset.zero & Size.square(side);
    final bg = Paint()..color = colors.paper;
    if (maskable) {
      canvas.drawRect(sheet, bg);
    } else {
      canvas.drawRRect(RRect.fromRectAndRadius(sheet, Radius.circular(side * cornerRadius)), bg);
    }

    final scale = maskable ? 0.8 : 1.0;
    final unit = side * scale;
    final origin = Offset((side - unit) / 2, (side - unit) / 2);
    Rect u(double l, double t, double r, double b) =>
        Rect.fromLTRB(origin.dx + l * unit, origin.dy + t * unit, origin.dx + r * unit, origin.dy + b * unit);

    if (grid) {
      final line = Paint()
        ..color = colors.ink.withValues(alpha: 0.1 * _phase(0, 0.3))
        ..strokeWidth = (side / 256).clamp(0.5, 2.0);
      canvas.save();
      if (!maskable) {
        canvas.clipRRect(RRect.fromRectAndRadius(sheet, Radius.circular(side * cornerRadius)));
      }
      for (var i = 1; i < 8; i++) {
        final d = side * i / 8;
        canvas.drawLine(Offset(d, 0), Offset(d, side), line);
        canvas.drawLine(Offset(0, d), Offset(side, d), line);
      }
      canvas.restore();
      final frame = Paint()
        ..color = colors.ink.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = (side / 128).clamp(0.75, 4.0);
      final box = u(0.12, 0.12, 0.88, 0.88);
      final drawn = _phase(0.05, 0.45);
      if (drawn >= 1) {
        canvas.drawRect(box, frame);
      } else if (drawn > 0) {
        for (final m in (Path()..addRect(box)).computeMetrics()) {
          canvas.drawPath(m.extractPath(0, m.length * drawn), frame);
        }
      }
    }

    final ink = Paint()..color = colors.ink;
    final accent = Paint()..color = colors.accent;
    void bar(Rect r, Paint paint, double grown, {bool down = false}) {
      if (grown <= 0) return;
      canvas.drawRect(
        down
            ? Rect.fromLTRB(r.left, r.top, r.right, lerpDouble(r.top, r.bottom, grown)!)
            : Rect.fromLTRB(r.left, r.top, lerpDouble(r.left, r.right, grown)!, r.bottom),
        paint,
      );
    }

    bar(u(0.25, 0.22, 0.41, 0.78), ink, _phase(0.35, 0.6), down: true);
    bar(u(0.25, 0.22, 0.75, 0.355), ink, _phase(0.5, 0.7));
    bar(u(0.25, 0.645, 0.75, 0.78), ink, _phase(0.6, 0.8));
    bar(u(0.48, 0.405, 0.75, 0.475), accent, _phase(0.8, 0.9));
    bar(u(0.48, 0.525, 0.75, 0.595), accent, _phase(0.88, 1));
  }

  @override
  bool shouldRepaint(EmplakeLogoPainter old) =>
      old.colors != colors ||
      old.grid != grid ||
      old.maskable != maskable ||
      old.cornerRadius != cornerRadius ||
      old.progress != progress;
}
