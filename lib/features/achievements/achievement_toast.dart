import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import 'achievements.dart';

Future<void> showAchievementToasts(BuildContext context, List<Achievement> unlocked) async {
  final overlay = Overlay.maybeOf(context, rootOverlay: true);
  if (overlay == null) return;
  for (final a in unlocked) {
    late OverlayEntry entry;
    final done = Completer<void>();
    entry = OverlayEntry(
      builder: (_) => _AchievementToast(
        achievement: a,
        onDone: () {
          entry.remove();
          done.complete();
        },
      ),
    );
    overlay.insert(entry);
    await done.future;
  }
}

class _AchievementToast extends StatefulWidget {
  const _AchievementToast({required this.achievement, required this.onDone});

  final Achievement achievement;
  final VoidCallback onDone;

  @override
  State<_AchievementToast> createState() => _AchievementToastState();
}

class _AchievementToastState extends State<_AchievementToast> with TickerProviderStateMixin {
  late final _enter = AnimationController(vsync: this, duration: const Duration(milliseconds: 750));
  late final _burst = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
  late final _exit = AnimationController(vsync: this, duration: const Duration(milliseconds: 320));
  bool _leaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_enter.isAnimating || _enter.isCompleted) return;
    final reduce = MediaQuery.disableAnimationsOf(context);
    if (reduce) {
      _enter.value = 1;
      _burst.value = 1;
    } else {
      _enter.forward();
      Future.delayed(const Duration(milliseconds: 250), () {
        if (mounted) _burst.forward();
      });
    }
    Future.delayed(const Duration(milliseconds: 3600), _leave);
  }

  Future<void> _leave() async {
    if (_leaving || !mounted) return;
    _leaving = true;
    if (!MediaQuery.disableAnimationsOf(context)) await _exit.forward();
    widget.onDone();
  }

  @override
  void dispose() {
    _enter.dispose();
    _burst.dispose();
    _exit.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final a = widget.achievement;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedBuilder(
            animation: Listenable.merge([_enter, _burst, _exit]),
            builder: (context, _) {
              final drop = Curves.elasticOut.transform(_enter.value);
              final up = Curves.easeInCubic.transform(_exit.value);
              final dy = -120 * (1 - drop) - 140 * up;
              final pop = Curves.elasticOut.transform(_burst.value);
              return Transform.translate(
                offset: Offset(0, dy + 12),
                child: Opacity(
                  opacity: (1 - up).clamp(0.0, 1.0),
                  child: GestureDetector(
                    onTap: _leave,
                    child: Semantics(
                      liveRegion: true,
                      label: l.achievementUnlocked(a.title(l)),
                      child: Material(
                        color: bp.ink,
                        elevation: 10,
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 420),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(12, 10, 18, 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(
                                  width: 56,
                                  height: 56,
                                  child: CustomPaint(
                                    painter: _SparksPainter(progress: _burst.value, color: bp.accent),
                                    child: Center(
                                      child: Transform.rotate(
                                        angle: (1 - pop) * math.pi,
                                        child: Transform.scale(
                                          scale: 0.4 + 0.6 * pop,
                                          child: Container(
                                            width: 40,
                                            height: 40,
                                            decoration: BoxDecoration(color: bp.accent, shape: BoxShape.circle),
                                            child: Icon(a.icon, color: bp.onAccent, size: 22),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l.achievementBanner,
                                        style: t.labelSmall?.copyWith(color: bp.accent, letterSpacing: 1.5),
                                      ),
                                      Text(
                                        a.title(l),
                                        style: t.titleSmall?.copyWith(color: bp.onInk, fontWeight: FontWeight.w700),
                                      ),
                                      Text(
                                        a.description(l),
                                        style: t.bodySmall?.copyWith(color: bp.onInk.withValues(alpha: 0.8)),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _SparksPainter extends CustomPainter {
  _SparksPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final c = size.center(Offset.zero);
    final eased = Curves.easeOutCubic.transform(progress);
    final paint = Paint()
      ..color = color.withValues(alpha: 1 - progress)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    const rays = 10;
    for (var i = 0; i < rays; i++) {
      final angle = i * 2 * math.pi / rays;
      final dir = Offset(math.cos(angle), math.sin(angle));
      final from = c + dir * (16 + 14 * eased);
      final to = c + dir * (20 + 22 * eased);
      canvas.drawLine(from, to, paint);
    }
  }

  @override
  bool shouldRepaint(_SparksPainter old) => old.progress != progress || old.color != color;
}
