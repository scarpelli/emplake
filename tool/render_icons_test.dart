import 'dart:io';
import 'dart:ui' as ui;

import 'package:emplake/core/theme/blueprint.dart';
import 'package:emplake/core/widgets/emplake_logo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final _colors = Blueprint.fromSeed(const Color(0xFF2460B7), Brightness.dark);

Future<void> _render(String path, int px, EmplakeLogoPainter painter) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  painter.paint(canvas, Size.square(px.toDouble()));
  final image = await recorder.endRecording().toImage(px, px);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  File(path)
    ..createSync(recursive: true)
    ..writeAsBytesSync(bytes!.buffer.asUint8List());
}

void main() {
  testWidgets('render launcher icons', (tester) async {
    await tester.runAsync(() async {
      for (final px in [192, 512]) {
        await _render('web/icons/Icon-$px.png', px, EmplakeLogoPainter(_colors, cornerRadius: 0.18));
        await _render('web/icons/Icon-maskable-$px.png', px, EmplakeLogoPainter(_colors, maskable: true));
      }
      await _render('web/favicon.png', 32, EmplakeLogoPainter(_colors, grid: false, cornerRadius: 0.16));

      const android = {'mdpi': 48, 'hdpi': 72, 'xhdpi': 96, 'xxhdpi': 144, 'xxxhdpi': 192};
      for (final MapEntry(key: dpi, value: px) in android.entries) {
        await _render(
          'android/app/src/main/res/mipmap-$dpi/ic_launcher.png',
          px,
          EmplakeLogoPainter(_colors, grid: px >= 96, cornerRadius: 0.18),
        );
      }
    });
  });
}
