import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../core/theme/blueprint.dart';

/// The groups of parts a robot is built from, in the order the creator lists them.
enum RobotPart { head, top, eyes, mouth, side, acc }

/// Every option of each group. The first one is the fallback for unknown values.
const robotOptions = <RobotPart, List<String>>{
  RobotPart.head: ['rounded', 'square', 'capsule', 'round', 'octagon'],
  RobotPart.top: ['none', 'antenna', 'twoAntennas', 'spring', 'heart', 'propeller', 'dome', 'crown'],
  RobotPart.eyes: ['round', 'lashes', 'hearts', 'wink', 'sleepy', 'glasses', 'visor', 'cyclops'],
  RobotPart.mouth: ['smile', 'teeth', 'open', 'wave', 'grille', 'line'],
  RobotPart.side: ['none', 'bolts', 'headphones', 'gears', 'rods'],
  RobotPart.acc: ['none', 'cheeks', 'bowTie', 'tie', 'medal'],
};

/// A player's robot: one option per [RobotPart].
@immutable
class RobotAvatar {
  const RobotAvatar._(this._parts);

  factory RobotAvatar.random(math.Random random) => RobotAvatar._({
    for (final p in RobotPart.values) p: robotOptions[p]![random.nextInt(robotOptions[p]!.length)],
  });

  /// A stable "random" robot for players who never opened the creator.
  /// Uses its own arithmetic so the result is the same on web and native.
  factory RobotAvatar.fromSeed(String seed) {
    var h = 7;
    for (final c in seed.codeUnits) {
      h = (h * 31 + c) % 2147483647;
    }
    h = h % 2147483646 + 1;
    final parts = <RobotPart, String>{};
    for (final p in RobotPart.values) {
      h = (h * 48271) % 2147483647;
      final opts = robotOptions[p]!;
      parts[p] = opts[h % opts.length];
    }
    return RobotAvatar._(parts);
  }

  static RobotAvatar? fromMap(Object? raw) {
    if (raw is! Map) return null;
    return RobotAvatar._({
      for (final p in RobotPart.values)
        p: robotOptions[p]!.contains(raw[p.name]) ? raw[p.name] as String : robotOptions[p]!.first,
    });
  }

  final Map<RobotPart, String> _parts;

  String operator [](RobotPart p) => _parts[p] ?? robotOptions[p]!.first;

  RobotAvatar withPart(RobotPart p, String value) => RobotAvatar._({..._parts, p: value});

  Map<String, String> toMap() => {for (final p in RobotPart.values) p.name: this[p]};

  @override
  bool operator ==(Object other) =>
      other is RobotAvatar && RobotPart.values.every((p) => this[p] == other[p]);

  @override
  int get hashCode => Object.hashAll(RobotPart.values.map((p) => this[p]));
}

/// Draws [avatar] in the blueprint style: [ink] lines over a [bg] disc with a faint grid.
class RobotAvatarView extends StatelessWidget {
  const RobotAvatarView(this.avatar, {super.key, this.size = 44, this.semanticLabel});

  final RobotAvatar avatar;
  final double size;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    return SvgPicture.string(
      robotSvg(avatar, bg: bp.paper, ink: bp.ink),
      width: size,
      height: size,
      semanticsLabel: semanticLabel,
      excludeFromSemantics: semanticLabel == null,
    );
  }
}

String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

String _f(num x) {
  final s = x.toStringAsFixed(2);
  return s.contains('.') ? s.replaceFirst(RegExp(r'\.?0+$'), '') : s;
}

String _heart(num cx, num cy, num k) =>
    'M${_f(cx)} ${_f(cy + 2.6 * k)} '
    'C${_f(cx - 3.6 * k)} ${_f(cy + .2 * k)} ${_f(cx - 3 * k)} ${_f(cy - 2.8 * k)} ${_f(cx - 1.4 * k)} ${_f(cy - 2.8 * k)} '
    'C${_f(cx - .5 * k)} ${_f(cy - 2.8 * k)} ${_f(cx)} ${_f(cy - 2 * k)} ${_f(cx)} ${_f(cy - 1.5 * k)} '
    'C${_f(cx)} ${_f(cy - 2 * k)} ${_f(cx + .5 * k)} ${_f(cy - 2.8 * k)} ${_f(cx + 1.4 * k)} ${_f(cy - 2.8 * k)} '
    'C${_f(cx + 3 * k)} ${_f(cy - 2.8 * k)} ${_f(cx + 3.6 * k)} ${_f(cy + .2 * k)} ${_f(cx)} ${_f(cy + 2.6 * k)} Z';

String _star(num cx, num cy, num r) {
  final b = StringBuffer();
  for (var k = 0; k < 10; k++) {
    final a = -math.pi / 2 + k * math.pi / 5;
    final rr = k.isOdd ? r * .45 : r;
    b.write('${k == 0 ? 'M' : 'L'}${_f(cx + rr * math.cos(a))} ${_f(cy + rr * math.sin(a))} ');
  }
  return '${b}Z';
}

String _gear(num cx, num cy, num r) {
  final b = StringBuffer();
  for (var k = 0; k < 16; k++) {
    final a = k * math.pi / 8 - math.pi / 16;
    final rr = (k % 4 < 2) ? r : r * .74;
    b.write('${k == 0 ? 'M' : 'L'}${_f(cx + rr * math.cos(a))} ${_f(cy + rr * math.sin(a))} ');
  }
  return '${b}Z';
}

String _bow(num cx, num cy, num k, String fill, String line) {
  final x = _f(cx), y = _f(cy);
  return '<path d="M$x $y L${_f(cx - 4.5 * k)} ${_f(cy - 3.2 * k)} L${_f(cx - 4.5 * k)} ${_f(cy + 3.2 * k)} Z '
      'M$x $y L${_f(cx + 4.5 * k)} ${_f(cy - 3.2 * k)} L${_f(cx + 4.5 * k)} ${_f(cy + 3.2 * k)} Z" '
      'fill="$fill" stroke="$line" stroke-width=".6" stroke-linejoin="round"/>'
      '<circle cx="$x" cy="$y" r="${_f(1.3 * k)}" fill="$line" stroke="$fill" stroke-width=".9"/>';
}

/// SVG for [c] on a 48×48 grid. Every head shares the same anchor points:
/// top centre (24,14), sides at y 25, eyes on y 23.5 (x 19 / 29), cheeks y 28.6,
/// mouth on y 31, neck y 34.5..39.5, chest from y 38.5.
String robotSvg(RobotAvatar c, {required Color bg, required Color ink}) {
  final bgc = _hex(bg), inc = _hex(ink);
  final st = 'stroke="$inc" stroke-width="1.3" stroke-linejoin="round"';
  String ln(num w) => 'stroke="$inc" stroke-width="${_f(w)}" fill="none" stroke-linecap="round" stroke-linejoin="round"';

  // Head outline, its left edge and, for curved tops, the top edge at x.
  final (String headEl, num left, num Function(num) topAt) = switch (c[RobotPart.head]) {
    'square' => ('<rect x="12" y="14" width="24" height="22" rx="2" fill="$bgc" $st/>', 12, (_) => 14),
    'capsule' => (
      '<rect x="12" y="14" width="24" height="22" rx="9" fill="$bgc" $st/>',
      12,
      (x) {
        final d = math.max(0, (x - 24).abs() - 3);
        return 23 - math.sqrt(math.max(0, 81 - d * d));
      },
    ),
    'round' => ('<circle cx="24" cy="25" r="11" fill="$bgc" $st/>', 13, (x) => 25 - math.sqrt(121 - (x - 24) * (x - 24))),
    'octagon' => ('<path d="M17 14 H31 L36 19 V31 L31 36 H17 L12 31 V19 Z" fill="$bgc" $st/>', 12, (_) => 14),
    _ => ('<rect x="12" y="14" width="24" height="22" rx="5" fill="$bgc" $st/>', 12, (_) => 14),
  };
  final right = 48 - left;
  const cy = 25.0, ey = 23.5;

  final back = StringBuffer(), front = StringBuffer(), face = StringBuffer(), chest = StringBuffer();

  // Body
  final o = StringBuffer()
    ..write('<rect x="21" y="34.5" width="6" height="5" fill="$bgc" $st/>')
    ..write('<path d="M8 49 C8 41 14 38 24 38 C34 38 40 41 40 49" fill="$bgc" $st/>');

  // Top
  switch (c[RobotPart.top]) {
    case 'antenna':
      back.write('<path d="M24 15 V8" ${ln(1.3)}/><circle cx="24" cy="6.6" r="2" fill="$inc"/>');
    case 'twoAntennas':
      final a = topAt(17), b = topAt(31);
      back.write('<path d="M17 ${_f(a + 1)} L14.5 8.6 M31 ${_f(b + 1)} L33.5 8.6" ${ln(1.3)}/>'
          '<circle cx="14.2" cy="7.4" r="1.7" fill="$inc"/><circle cx="33.8" cy="7.4" r="1.7" fill="$inc"/>');
    case 'spring':
      back.write('<path d="M24 15 L24 13 L21.8 11.8 L26.2 10.6 L21.8 9.4 L26.2 8.2 L24 7.2" ${ln(1.1)}/>'
          '<circle cx="24" cy="5.4" r="1.9" fill="$inc"/>');
    case 'heart':
      back.write('<path d="M24 15 V9.4" ${ln(1.2)}/><path d="${_heart(24, 6.6, 1.05)}" fill="$inc"/>');
    case 'dome':
      final db = topAt(18) + 1;
      back.write('<path d="M18 ${_f(db)} A6 ${_f(6 + (db - 15.2))} 0 0 1 30 ${_f(db)}" fill="$bgc" $st/>'
          '<path d="M20.6 12.6 A3.6 3.6 0 0 1 22.6 10.8" ${ln(.8)}/><path d="M24 9.2 V6.6" ${ln(1)}/>'
          '<circle cx="24" cy="5.8" r="1" fill="$inc"/>');
    case 'propeller':
      back.write('<path d="M24 15 V9.6" ${ln(1.2)}/>');
      front.write('<path d="M24 9 C20 6.4 16 7 15.4 8.6 C16 10.2 20 10.2 24 9 Z M24 9 C28 11.6 32 11 32.6 9.4 '
          'C32 7.8 28 7.8 24 9 Z" fill="$inc"/><circle cx="24" cy="9" r="1.3" fill="$bgc" stroke="$inc" stroke-width=".9"/>');
    case 'crown':
      final base = _f(math.max(topAt(18.5), topAt(29.5)) + .7);
      front.write('<path d="M18.5 $base L18.5 10 L21.2 12.4 L24 8.6 L26.8 12.4 L29.5 10 L29.5 $base Z" fill="$bgc" $st/>'
          '<circle cx="24" cy="8.6" r="1" fill="$inc"/><circle cx="24" cy="13.8" r=".9" fill="$inc"/>');
  }

  // Sides
  switch (c[RobotPart.side]) {
    case 'bolts':
      back.write('<rect x="${_f(left - 2.6)}" y="22" width="4.6" height="6" fill="$bgc" $st/>'
          '<rect x="${_f(right - 2)}" y="22" width="4.6" height="6" fill="$bgc" $st/>');
    case 'gears':
      for (final gx in [left - .4, right + .4]) {
        back.write('<path d="${_gear(gx, cy, 4)}" fill="$bgc" $st/><circle cx="${_f(gx)}" cy="25" r="1.1" fill="$inc"/>');
      }
    case 'rods':
      back.write('<path d="M${_f(left)} 25 H${_f(left - 5)} M${_f(right)} 25 H${_f(right + 5)}" ${ln(1.3)}/>');
      front.write('<circle cx="${_f(left - 6.4)}" cy="25" r="1.7" fill="$inc"/><circle cx="${_f(right + 6.4)}" cy="25" r="1.7" fill="$inc"/>');
    case 'headphones':
      for (final (k, ex) in [(0, left), (1, right)]) {
        final x0 = k == 1 ? ex - 1.4 : ex - 4;
        front.write('<rect x="${_f(x0)}" y="20.4" width="5.4" height="9.2" rx="2.4" fill="$bgc" $st/>'
            '<path d="M${_f(x0 + (k == 1 ? 3.1 : 2.3))} 22.6 V27.4" ${ln(.8)}/>');
      }
  }

  // Eyes
  String ring(num ex, num r) => '<circle cx="${_f(ex)}" cy="$ey" r="${_f(r)}" fill="none" $st/>';
  const eyes = [19, 29];
  switch (c[RobotPart.eyes]) {
    case 'round':
    case 'lashes':
      final lashes = c[RobotPart.eyes] == 'lashes';
      for (final ex in eyes) {
        face.write('${ring(ex, 3)}<circle cx="$ex" cy="23.7" r="${lashes ? 1.6 : 1.2}" fill="$inc"/>');
        if (lashes) {
          final d = ex < 24 ? -1 : 1;
          face.write('<path d="M$ex 20.5 L${_f(ex + .5 * d)} 18.8 M${_f(ex + 1.6 * d)} 21 L${_f(ex + 2.7 * d)} 19.5 '
              'M${_f(ex + 2.6 * d)} 22.1 L${_f(ex + 3.7 * d)} 21.4" ${ln(.9)}/>');
        }
      }
    case 'hearts':
      for (final ex in eyes) {
        face.write('<path d="${_heart(ex, 23.7, 1.05)}" fill="$inc"/>');
      }
    case 'wink':
      face.write('<path d="M16.2 24.1 Q19 21.1 21.8 24.1" ${ln(1.4)}/>${ring(29, 3)}<circle cx="29" cy="23.7" r="1.2" fill="$inc"/>');
    case 'sleepy':
      for (final ex in eyes) {
        face.write('<path d="M${ex - 3} 23.1 A3 3 0 0 0 ${ex + 3} 23.1 Z" fill="none" $st/>'
            '<circle cx="$ex" cy="24.6" r="1.1" fill="$inc"/><path d="M${_f(ex - 3.6)} 23.1 H${_f(ex + 3.6)}" ${ln(1.3)}/>');
      }
    case 'glasses':
      for (final ex in eyes) {
        face.write('<circle cx="$ex" cy="$ey" r="3.6" fill="none" $st/><circle cx="$ex" cy="23.7" r="1.3" fill="$inc"/>');
      }
      face.write('<path d="M22.6 23.1 Q24 21.9 25.4 23.1 M15.4 22.7 H14.4 M32.6 22.7 H33.6" ${ln(1.2)}/>');
    case 'visor':
      face.write('<rect x="15" y="20.5" width="18" height="6" rx="3" fill="$inc"/>'
          '<circle cx="20" cy="$ey" r="1.4" fill="$bgc"/><circle cx="28" cy="$ey" r="1.4" fill="$bgc"/>');
    case 'cyclops':
      face.write('${ring(24, 3.9)}<circle cx="24" cy="$ey" r="2" fill="$inc"/>'
          '<path d="M17 $ey H19 M29 $ey H31" stroke="$inc" stroke-width=".8"/>');
  }

  // Cheeks belong to the face; every other accessory sits on the chest.
  switch (c[RobotPart.acc]) {
    case 'cheeks':
      for (final bx in [16.4, 31.6]) {
        face.write('<circle cx="$bx" cy="28.6" r="1.7" fill="$inc" fill-opacity=".4"/>');
      }
    case 'bowTie':
      chest.write(_bow(24, 39.6, .9, inc, bgc));
    case 'tie':
      chest.write('<path d="M22.4 38.6 H25.6 L25.1 40.8 H22.9 Z" fill="$inc"/>'
          '<path d="M22.9 41.3 H25.1 L26 44.6 L24 46.4 L22 44.6 Z" fill="$inc"/>');
    case 'medal':
      chest.write('<path d="M21.6 38.6 L23.4 41.6 M26.4 38.6 L24.6 41.6" ${ln(1.2)}/>'
          '<circle cx="24" cy="43.5" r="2.3" fill="$inc"/><path d="${_star(24, 43.6, 1.4)}" fill="$bgc"/>');
  }

  // Mouth (y 31)
  switch (c[RobotPart.mouth]) {
    case 'smile':
      face.write('<path d="M19.5 30 Q24 33.5 28.5 30" ${ln(1.3)}/>');
    case 'grille':
      face.write('<rect x="20.4" y="29.4" width="7.2" height="3.2" rx=".4" fill="none" stroke="$inc" stroke-width="1"/>'
          '<path d="M22.8 29.4 V32.6 M25.2 29.4 V32.6" stroke="$inc" stroke-width=".7"/>');
    case 'open':
      face.write('<path d="M19.5 29.2 H28.5 Q28 33.8 24 33.8 Q20 33.8 19.5 29.2 Z" fill="none" $st/>'
          '<path d="M21.6 32.5 Q24 31 26.4 32.5" ${ln(.8)}/>');
    case 'teeth':
      face.write('<path d="M19.5 30 Q24 32.6 28.5 30" ${ln(1.3)}/>'
          '<path d="M22.2 31.4 V33.2 H24 V31.6 M24 31.6 V33.2 H25.8 V31.4" fill="$bgc" stroke="$inc" stroke-width=".9" stroke-linejoin="round"/>');
    case 'wave':
      face.write('<path d="M20 31 q1 -1.8 2 0 t2 0 t2 0 t2 0" ${ln(1.2)}/>');
    case 'line':
      face.write('<path d="M19.5 31 H28.5" ${ln(1.3)}/>');
  }

  o
    ..write(chest)
    ..write(back)
    ..write(headEl)
    ..write(front)
    ..write(face);

  final grid = StringBuffer();
  for (var x = 6; x < 48; x += 6) {
    grid.write('<path d="M$x 0 V48 M0 $x H48"/>');
  }
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 48 48">'
      '<defs><clipPath id="c"><circle cx="24" cy="24" r="24"/></clipPath></defs>'
      '<g clip-path="url(#c)"><rect width="48" height="48" fill="$bgc"/>'
      '<g stroke="$inc" stroke-opacity=".12" stroke-width=".5">$grid</g>$o</g>'
      '<circle cx="24" cy="24" r="23.4" fill="none" stroke="$inc" stroke-opacity=".45" stroke-width="1.2"/></svg>';
}
