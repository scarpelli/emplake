import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/router.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../game/application/game_controller.dart';
import '../game/domain/level.dart';

class LevelPage extends StatefulWidget {
  const LevelPage({super.key, required this.mode});

  final GameMode mode;

  @override
  State<LevelPage> createState() => _LevelPageState();
}

class _LevelPageState extends State<LevelPage> {
  Level _level = Level.intermediate;
  final _digits = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _digits.dispose();
    super.dispose();
  }

  void _start() {
    final specific = widget.mode == GameMode.specific;
    if (specific && _digits.text.length != 4) {
      setState(() => _error = context.l10n.typeFourDigits);
      return;
    }
    context.go(newGameLocation(mode: widget.mode, level: _level, number: specific ? _digits.text : null));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final bp = context.bp;

    return ContentWidth(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
        children: [
          Row(
            children: [
              InkWell(
                onTap: () => context.go('/play'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(children: [
                    Icon(Icons.arrow_back, size: 18, semanticLabel: l.back),
                    const SizedBox(width: 6),
                    Eyebrow(l.modeLabel(widget.mode.label(l).toUpperCase())),
                  ]),
                ),
              ),
              const Spacer(),
              const SoundToggle(),
            ],
          ),
          const SizedBox(height: 16),
          PageTitle(eyebrow: l.stepOf(2, 2), title: l.chooseLevel),
          const SizedBox(height: 12),
          for (final level in Level.values) ...[
            SelectTile(
              selected: level == _level,
              onTap: () => setState(() => _level = level),
              child: Builder(builder: (context) {
                final on = level == _level;
                final fg = on ? bp.onInk : bp.ink;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      crossAxisAlignment: WrapCrossAlignment.end,
                      children: [
                        Text(level.label(l), style: t.titleSmall?.copyWith(fontWeight: FontWeight.w600, color: fg)),
                        Text(
                          '${l.operatorCount(level.operatorLabels.length)} · ${l.secondsPerNumber(level.seconds)}',
                          style: t.labelSmall?.copyWith(color: fg.withValues(alpha: 0.75)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: [
                        for (final op in level.operatorLabels)
                          Container(
                            constraints: const BoxConstraints(minWidth: 28),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                            decoration: BoxDecoration(border: Border.all(color: fg.withValues(alpha: 0.5))),
                            child: Text(op, textAlign: TextAlign.center, style: t.labelMedium?.copyWith(color: fg)),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(level.note(l), style: t.bodySmall?.copyWith(color: fg.withValues(alpha: 0.8))),
                  ],
                );
              }),
            ),
            const SizedBox(height: 8),
          ],
          if (widget.mode == GameMode.specific) ...[
            const SizedBox(height: 8),
            Eyebrow(l.fourDigitNumber),
            const SizedBox(height: 8),
            _DigitsField(
              controller: _digits,
              error: _error,
              onChanged: () => setState(() => _error = null),
              onSubmitted: _start,
            ),
          ],
          const SizedBox(height: 16),
          FilledButton.icon(
            iconAlignment: IconAlignment.end,
            icon: const Icon(Icons.play_arrow),
            label: Text(l.start),
            onPressed: _start,
          ),
        ],
      ),
    );
  }
}

class _DigitsField extends StatelessWidget {
  const _DigitsField({required this.controller, required this.onChanged, required this.onSubmitted, this.error});

  final TextEditingController controller;
  final VoidCallback onChanged;
  final VoidCallback onSubmitted;
  final String? error;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          children: [
            ValueListenableBuilder(
              valueListenable: controller,
              builder: (context, value, _) => Container(
                decoration: BoxDecoration(border: Border.all(color: error == null ? bp.ink : bp.danger)),
                child: Row(
                  children: [
                    for (var i = 0; i < 4; i++)
                      Expanded(
                        child: Container(
                          height: 56,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            border: i == 3 ? null : Border(right: BorderSide(color: bp.lineSoft)),
                          ),
                          child: Text(
                            i < value.text.length ? value.text[i] : '·',
                            style: t.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                              color: i < value.text.length ? bp.ink : bp.faint,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                alwaysIncludeSemantics: true,
                child: TextField(
                  controller: controller,
                  autofocus: true,
                  keyboardType: TextInputType.number,
                  maxLength: 4,
                  showCursor: false,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(4)],
                  onChanged: (_) => onChanged(),
                  onSubmitted: (_) => onSubmitted(),
                  decoration: InputDecoration(
                    counterText: '',
                    border: InputBorder.none,
                    labelText: context.l10n.fourDigitNumber,
                  ),
                ),
              ),
            ),
          ],
        ),
        if (error != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(error!, style: t.bodySmall?.copyWith(color: bp.danger)),
          ),
      ],
    );
  }
}
