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
  const EmplakeLogoPainter(this.colors, {this.grid = true, this.maskable = false, this.cornerRadius = 0.2});

  final Blueprint colors;

  final bool grid;

  final bool maskable;

  final double cornerRadius;

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
        ..color = colors.ink.withValues(alpha: 0.1)
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
      canvas.drawRect(u(0.12, 0.12, 0.88, 0.88), frame);
    }

    final ink = Paint()..color = colors.ink;
    final accent = Paint()..color = colors.accent;
    canvas.drawRect(u(0.25, 0.22, 0.41, 0.78), ink);
    canvas.drawRect(u(0.25, 0.22, 0.75, 0.355), ink);
    canvas.drawRect(u(0.25, 0.645, 0.75, 0.78), ink);
    canvas.drawRect(u(0.48, 0.405, 0.75, 0.475), accent);
    canvas.drawRect(u(0.48, 0.525, 0.75, 0.595), accent);
  }

  @override
  bool shouldRepaint(EmplakeLogoPainter old) =>
      old.colors != colors || old.grid != grid || old.maskable != maskable || old.cornerRadius != cornerRadius;
}
