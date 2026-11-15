import 'package:emplake/features/game/presentation/coach_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The ring drawn around a tutorial target.
Rect _ring(Offset at) => Rect.fromCircle(center: at, radius: 32);

void main() {
  const screens = [
    Size(360, 640), // small phone
    Size(390, 844), // phone
    Size(844, 390), // phone, landscape
    Size(768, 1024), // tablet
    Size(1280, 800), // desktop
    Size(1920, 1080), // large desktop
  ];
  const balloons = [Size(280, 90), Size(280, 140), Size(280, 200)];

  for (final screen in screens) {
    test('balloon never covers its target on ${screen.width.toInt()}×${screen.height.toInt()}', () {
      for (final prefer in BalloonAt.values) {
        for (final requested in balloons) {
          for (var fx = 0.05; fx < 1; fx += 0.15) {
            for (var fy = 0.08; fy < 1; fy += 0.12) {
              final at = Offset(screen.width * fx, screen.height * fy);
              final layout = BalloonLayout(target: at, prefer: prefer);
              final c = layout.getConstraintsForChild(BoxConstraints.loose(screen));
              final child = c.constrain(requested);
              final pos = layout.getPositionForChild(screen, child);
              final rect = pos & child;

              final fitsSomewhere =
                  at.dy - 40 - 8 >= child.height ||
                  screen.height - 8 - at.dy - 40 >= child.height ||
                  at.dx - 40 - 8 >= child.width ||
                  screen.width - 8 - at.dx - 40 >= child.width;
              if (fitsSomewhere) {
                expect(
                  rect.overlaps(_ring(at)),
                  isFalse,
                  reason: 'prefer=$prefer target=$at balloon=$rect',
                );
              }
              expect(rect.left, greaterThanOrEqualTo(0), reason: 'off screen: $rect');
              expect(rect.right, lessThanOrEqualTo(screen.width), reason: 'off screen: $rect');
            }
          }
        }
      }
    });
  }

  test('respects the preferred side when it fits', () {
    const screen = Size(390, 844);
    const child = Size(280, 120);
    final at = const Offset(195, 420);
    expect(BalloonLayout(target: at, prefer: BalloonAt.above).getPositionForChild(screen, child).dy, lessThan(at.dy));
    expect(BalloonLayout(target: at, prefer: BalloonAt.below).getPositionForChild(screen, child).dy, greaterThan(at.dy));
  });
}
