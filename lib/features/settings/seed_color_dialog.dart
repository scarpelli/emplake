import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';

Future<Color?> showSeedColorDialog(BuildContext context, Color initial) => showDialog<Color>(
  context: context,
  barrierColor: Colors.black.withValues(alpha: 0.5),
  builder: (_) => SeedColorDialog(initial: initial),
);

class SeedColorDialog extends StatefulWidget {
  const SeedColorDialog({super.key, required this.initial});
  final Color initial;

  @override
  State<SeedColorDialog> createState() => _SeedColorDialogState();
}

class _SeedColorDialogState extends State<SeedColorDialog> {
  late HSVColor _hsv = HSVColor.fromColor(widget.initial.withValues(alpha: 1));
  late final _hex = TextEditingController(text: _hexOf(_hsv.toColor()));

  static String _hexOf(Color c) => (c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0').toUpperCase();

  Color get _color => _hsv.toColor();

  void _set(HSVColor hsv) => setState(() {
    _hsv = hsv;
    _hex.text = _hexOf(_color);
  });

  void _onHex(String text) {
    if (text.length != 6) return;
    final v = int.tryParse(text, radix: 16);
    if (v == null) return;
    setState(() => _hsv = HSVColor.fromColor(Color(0xFF000000 | v)));
  }

  @override
  void dispose() {
    _hex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final m = MaterialLocalizations.of(context);
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final look = Blueprint.fromSeed(_color, Theme.of(context).brightness);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.pickColor,
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1.5),
                    ),
                  ),
                  BoxIconButton(
                    icon: Icons.close,
                    tooltip: m.closeButtonTooltip,
                    size: 40,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: 1.5,
                child: _SatValArea(hsv: _hsv, border: bp.line, onChanged: _set),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 28,
                child: _HueBar(hsv: _hsv, border: bp.line, onChanged: _set),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Container(
                    width: 72,
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: look.paper,
                      border: Border.all(color: look.line),
                    ),
                    child: Text(
                      '9+2',
                      style: TextStyle(color: look.ink, fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _color,
                      border: Border.all(color: bp.line),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextField(
                      controller: _hex,
                      onChanged: _onHex,
                      maxLength: 6,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp('[0-9a-fA-F]')),
                        TextInputFormatter.withFunction((_, v) => v.copyWith(text: v.text.toUpperCase())),
                      ],
                      decoration: const InputDecoration(
                        prefixText: '# ',
                        counterText: '',
                        border: OutlineInputBorder(borderRadius: BorderRadius.zero),
                        isDense: true,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  OutlinedButton(onPressed: () => Navigator.of(context).pop(), child: Text(m.cancelButtonLabel)),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: () => Navigator.of(context).pop(_color), child: Text(m.okButtonLabel)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SatValArea extends StatelessWidget {
  const _SatValArea({required this.hsv, required this.border, required this.onChanged});
  final HSVColor hsv;
  final Color border;
  final ValueChanged<HSVColor> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final size = c.biggest;
      void pick(Offset p) => onChanged(
        hsv.withSaturation((p.dx / size.width).clamp(0.0, 1.0)).withValue(1 - (p.dy / size.height).clamp(0.0, 1.0)),
      );
      final thumb = Offset(hsv.saturation * size.width, (1 - hsv.value) * size.height);

      return MouseRegion(
        cursor: SystemMouseCursors.precise,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) => pick(d.localPosition),
          onPanUpdate: (d) => pick(d.localPosition),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    gradient: LinearGradient(colors: [Colors.white, HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor()]),
                  ),
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Colors.black],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: thumb.dx - 9,
                top: thumb.dy - 9,
                child: IgnorePointer(child: _Thumb(color: hsv.toColor())),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _HueBar extends StatelessWidget {
  const _HueBar({required this.hsv, required this.border, required this.onChanged});
  final HSVColor hsv;
  final Color border;
  final ValueChanged<HSVColor> onChanged;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, c) {
      final w = c.maxWidth;
      void pick(Offset p) => onChanged(hsv.withHue((p.dx / w).clamp(0.0, 1.0) * 359.9));
      void pickHue(Offset p) {
        if (hsv.saturation < 0.05 || hsv.value < 0.05) {
          onChanged(HSVColor.fromAHSV(1, (p.dx / w).clamp(0.0, 1.0) * 359.9, 0.8, 0.75));
        } else {
          pick(p);
        }
      }

      return MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanDown: (d) => pickHue(d.localPosition),
          onPanUpdate: (d) => pick(d.localPosition),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(color: border),
                    gradient: LinearGradient(
                      colors: [for (var h = 0; h <= 360; h += 60) HSVColor.fromAHSV(1, h % 360, 1, 1).toColor()],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: hsv.hue / 360 * w - 9,
                top: c.maxHeight / 2 - 9,
                child: IgnorePointer(child: _Thumb(color: HSVColor.fromAHSV(1, hsv.hue, 1, 1).toColor())),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _Thumb extends StatelessWidget {
  const _Thumb({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Colors.white, width: 2.5),
      boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 3)],
    ),
  );
}
