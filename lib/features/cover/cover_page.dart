import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/prefs.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../data/firestore_repository.dart';

class CoverPage extends ConsumerWidget {
  const CoverPage({super.key});

  void _enter(BuildContext context, WidgetRef ref) {
    final signedIn = ref.read(firebaseAuthProvider).currentUser != null;
    final saved = ref.read(sharedPreferencesProvider).getString(PrefKeys.lastLocation);
    context.go(signedIn ? (saved ?? '/play') : '/login');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: GridBackground(
        child: SafeArea(
          child: Semantics(
            button: true,
            label: l.coverTap,
            child: InkWell(
              onTap: () => _enter(context, ref),
              child: ContentWidth(
                maxWidth: 520,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [SoundToggle()],
                      ),
                      const Spacer(),
                      const _DimensionedPlate(),
                      const SizedBox(height: 32),
                      Text(l.coverTagline, textAlign: TextAlign.center, style: t.bodyLarge?.copyWith(height: 1.5)),
                      const SizedBox(height: 28),
                      const _TapHint(),
                      const Spacer(),
                      const SizedBox(height: 44),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _TapHint extends StatefulWidget {
  const _TapHint();

  @override
  State<_TapHint> createState() => _TapHintState();
}

class _TapHintState extends State<_TapHint> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.45, end: 1.0).animate(_c),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.touch_app_outlined),
          const SizedBox(width: 8),
          Text(
            context.l10n.coverTap,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(letterSpacing: 2, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _DimensionedPlate extends StatelessWidget {
  const _DimensionedPlate();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return LayoutBuilder(
      builder: (context, c) {
        final w = (c.maxWidth - 40).clamp(200.0, 360.0);
        final h = w * 130 / 400;
        return Column(
          children: [
            _Dimension(width: w, label: '400 mm'),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: w,
                  height: h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F2),
                    border: Border.all(color: const Color(0xFF1B1B1B), width: 2),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: h * 0.24,
                        decoration: const BoxDecoration(
                          color: Color(0xFF1F4BA5),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(4)),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          context.l10n.plateCountry,
                          style: t.labelSmall?.copyWith(
                            color: Colors.white,
                            letterSpacing: 3,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Expanded(
                        child: FittedBox(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              '3MPL4K3',
                              style: t.displayMedium?.copyWith(
                                color: const Color(0xFF1B1B1B),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 4,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                RotatedBox(
                  quarterTurns: 1,
                  child: _Dimension(width: h, label: '130'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _Dimension extends StatelessWidget {
  const _Dimension({required this.width, required this.label});
  final double width;
  final String label;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Container(width: 1, height: 10, color: bp.ink),
          Expanded(child: Container(height: 1, color: bp.line)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Text(label, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: bp.muted)),
          ),
          Expanded(child: Container(height: 1, color: bp.line)),
          Container(width: 1, height: 10, color: bp.ink),
        ],
      ),
    );
  }
}
