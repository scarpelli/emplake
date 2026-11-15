import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/blueprint.dart';
import 'page_colors_stub.dart' if (dart.library.js_interop) 'page_colors_web.dart';

String _hex(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

String faviconSvg(Blueprint c) {
  final ink = _hex(c.ink);
  final accent = _hex(c.accent);
  return '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100">'
      '<rect width="100" height="100" rx="16" fill="${_hex(c.paper)}"/>'
      '<rect x="25" y="22" width="16" height="56" fill="$ink"/>'
      '<rect x="25" y="22" width="50" height="13.5" fill="$ink"/>'
      '<rect x="25" y="64.5" width="50" height="13.5" fill="$ink"/>'
      '<rect x="48" y="40.5" width="27" height="7" fill="$accent"/>'
      '<rect x="48" y="52.5" width="27" height="7" fill="$accent"/>'
      '</svg>';
}

class ThemeChrome extends StatelessWidget {
  const ThemeChrome({super.key, required this.seed, required this.brightness, required this.child});

  final Color seed;
  final Brightness brightness;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colors = Blueprint.fromSeed(seed, brightness);
    final dark = brightness == Brightness.dark;
    applyPageColors('data:image/svg+xml,${Uri.encodeComponent(faviconSvg(colors))}', _hex(colors.paper), dark);
    final icons = dark ? Brightness.light : Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarColor: colors.paper,
        statusBarIconBrightness: icons,
        statusBarBrightness: brightness,
        systemNavigationBarColor: colors.paper,
        systemNavigationBarIconBrightness: icons,
        systemNavigationBarDividerColor: colors.paper,
        systemNavigationBarContrastEnforced: false,
      ),
      child: child,
    );
  }
}
