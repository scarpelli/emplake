import 'package:flutter/material.dart';

@immutable
class Blueprint extends ThemeExtension<Blueprint> {
  const Blueprint({
    required this.paper,
    required this.deep,
    required this.ink,
    required this.onInk,
    required this.accent,
    required this.onAccent,
    required this.ok,
    required this.danger,
  });

  factory Blueprint.fromSeed(Color seed, Brightness brightness) {
    final hsl = HSLColor.fromColor(seed);
    final h = hsl.hue;
    final s = hsl.saturation.clamp(0.0, 1.0);
    Color c(double sat, double light) => HSLColor.fromAHSL(1, h, sat.clamp(0.0, 1.0), light).toColor();

    if (brightness == Brightness.dark) {
      return Blueprint(
        paper: c(s * 1.05, 0.28),
        deep: c(s * 1.2, 0.17),
        ink: c(s * 1.5, 0.97),
        onInk: c(s * 1.3, 0.20),
        accent: const Color(0xFFF2D76C),
        onAccent: c(s * 1.3, 0.20),
        ok: const Color(0xFF90E9A3),
        danger: const Color(0xFFF66E5C),
      );
    }
    return Blueprint(
      paper: c(s * 0.55, 0.955),
      deep: c(s * 0.5, 0.89),
      ink: c(s * 0.9, 0.24),
      onInk: c(s * 0.55, 0.97),
      accent: const Color(0xFFBB7400),
      onAccent: Colors.white,
      ok: const Color(0xFF298646),
      danger: const Color(0xFFC93029),
    );
  }

  final Color paper;

  final Color deep;

  final Color ink;

  final Color onInk;

  final Color accent;
  final Color onAccent;

  final Color ok;
  final Color danger;

  Color get line => ink.withValues(alpha: 0.6);
  Color get lineSoft => ink.withValues(alpha: 0.3);
  Color get grid => ink.withValues(alpha: 0.07);
  Color get muted => ink.withValues(alpha: 0.7);
  Color get faint => ink.withValues(alpha: 0.45);
  Color get panel => Color.alphaBlend(deep.withValues(alpha: 0.55), paper);

  @override
  Blueprint copyWith({
    Color? paper,
    Color? deep,
    Color? ink,
    Color? onInk,
    Color? accent,
    Color? onAccent,
    Color? ok,
    Color? danger,
  }) =>
      Blueprint(
        paper: paper ?? this.paper,
        deep: deep ?? this.deep,
        ink: ink ?? this.ink,
        onInk: onInk ?? this.onInk,
        accent: accent ?? this.accent,
        onAccent: onAccent ?? this.onAccent,
        ok: ok ?? this.ok,
        danger: danger ?? this.danger,
      );

  @override
  Blueprint lerp(Blueprint? other, double t) {
    if (other == null) return this;
    return Blueprint(
      paper: Color.lerp(paper, other.paper, t)!,
      deep: Color.lerp(deep, other.deep, t)!,
      ink: Color.lerp(ink, other.ink, t)!,
      onInk: Color.lerp(onInk, other.onInk, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      onAccent: Color.lerp(onAccent, other.onAccent, t)!,
      ok: Color.lerp(ok, other.ok, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
    );
  }
}

extension BlueprintContext on BuildContext {
  Blueprint get bp => Theme.of(this).extension<Blueprint>()!;
}

class GridBackground extends StatelessWidget {
  const GridBackground({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    return ColoredBox(
      color: bp.paper,
      child: CustomPaint(
        painter: _GridPainter(bp.grid),
        child: child,
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  _GridPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = color
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 20) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 20) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.color != color;
}
