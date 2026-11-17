import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/prefs.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../core/widgets/emplake_logo.dart';
import '../../data/firestore_repository.dart';
import '../auth/guest.dart';
import '../game/application/catalog_provider.dart';
import '../game/application/game_controller.dart';
import '../game/domain/catalog.dart';
import '../game/domain/format.dart';
import '../game/domain/replay.dart';
import '../game/presentation/tree_view.dart';
import '../auth/login_page.dart';

class CoverPage extends ConsumerStatefulWidget {
  const CoverPage({super.key});

  @override
  ConsumerState<CoverPage> createState() => _CoverPageState();
}

class _CoverPageState extends ConsumerState<CoverPage> {
  bool _busy = false;

  Future<void> _enter() async {
    if (_busy) return;
    setState(() => _busy = true);
    final user = await ref.read(firebaseAuthProvider).authStateChanges().first;
    if (!mounted) return;
    if (user != null) {
      setState(() => _busy = false);
      final saved = ref.read(sharedPreferencesProvider).getString(PrefKeys.lastLocation);
      context.go(saved ?? '/play');
      return;
    }
    final ok = await continueAsGuest(context, ref);
    if (!mounted) return;
    setState(() => _busy = false);
    context.go(ok ? '/play' : '/login');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final signedIn = ref.watch(authStateProvider).value != null;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: GridBackground(
        child: SafeArea(
          child: Semantics(
            button: true,
            label: l.coverTap,
            child: InkWell(
              onTap: _enter,
              child: ContentWidth(
                maxWidth: 520,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                  child: Column(
                    children: [
                      const Row(mainAxisAlignment: MainAxisAlignment.end, children: [SoundToggle()]),
                      Expanded(
                        child: LayoutBuilder(
                          builder: (context, box) => SingleChildScrollView(
                            child: ConstrainedBox(
                              constraints: BoxConstraints(minHeight: box.maxHeight),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const _CoverBrand(),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    height: (box.maxHeight - 340).clamp(150.0, 200.0),
                                    child: const _CoverDemo(),
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    l.coverTagline,
                                    textAlign: TextAlign.center,
                                    style: t.bodyLarge?.copyWith(height: 1.5),
                                  ),
                                  const SizedBox(height: 24),
                                  _busy
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        )
                                      : const _TapHint(),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 44,
                        child: signedIn
                            ? null
                            : Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(l.coverHaveAccount, style: t.bodySmall?.copyWith(color: context.bp.muted)),
                                  const SizedBox(width: 2),
                                  TextLink(label: l.coverSignIn, onTap: () => context.go('/login')),
                                ],
                              ),
                      ),
                      Text(
                        l.teamNames(teamMembers[0], teamMembers[1]),
                        textAlign: TextAlign.center,
                        style: t.bodySmall?.copyWith(color: context.bp.muted),
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

class _CoverBrand extends StatefulWidget {
  const _CoverBrand();

  @override
  State<_CoverBrand> createState() => _CoverBrandState();
}

class _CoverBrandState extends State<_CoverBrand> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1600));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.value = 1;
    } else if (!_c.isAnimating && _c.value == 0) {
      _c.forward();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    return Semantics(
      label: 'EMPLAKE',
      excludeSemantics: true,
      child: Column(
        children: [
          SizedBox.square(
            dimension: 72,
            child: AnimatedBuilder(
              animation: _c,
              builder: (context, _) =>
                  CustomPaint(painter: EmplakeLogoPainter(bp, progress: Curves.easeInOut.transform(_c.value))),
            ),
          ),
          const SizedBox(height: 14),
          FadeTransition(
            opacity: CurvedAnimation(
              parent: _c,
              curve: const Interval(0.7, 1, curve: Curves.easeOut),
            ),
            child: Text('EMPLAKE', style: t.headlineSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 8)),
          ),
        ],
      ),
    );
  }
}

class _CoverDemo extends ConsumerStatefulWidget {
  const _CoverDemo();

  @override
  ConsumerState<_CoverDemo> createState() => _CoverDemoState();
}

class _CoverDemoState extends ConsumerState<_CoverDemo> {
  static const _tick = Duration(milliseconds: 900);
  static const _holdTicks = 3;

  final _random = math.Random();
  List<CatalogEntry> _pool = const [];
  CatalogEntry? _entry;
  List<ReplayStep> _steps = const [];
  int _step = 0;
  int _held = 0;
  Timer? _timer;

  static List<CatalogEntry> _poolOf(Catalog catalog) => [
    for (final e in catalog.all)
      if (e.stars == 1 && !e.number.contains('0') && replaySolution(e.number, e.solution).length <= 5) e,
  ];

  void _next() {
    if (_pool.isEmpty) return;
    var e = _pool[_random.nextInt(_pool.length)];
    if (_pool.length > 1) {
      while (e == _entry) {
        e = _pool[_random.nextInt(_pool.length)];
      }
    }
    _entry = e;
    _steps = replaySolution(e.number, e.solution);
    _step = 0;
    _held = 0;
  }

  void _start(Catalog catalog) {
    _pool = _poolOf(catalog);
    _next();
    if (MediaQuery.disableAnimationsOf(context)) {
      _step = _steps.length - 1;
      return;
    }
    _timer = Timer.periodic(_tick, (_) {
      if (!mounted) return;
      setState(() {
        if (_step < _steps.length - 1) {
          _step++;
        } else if (++_held > _holdTicks) {
          _next();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider).value;
    if (catalog != null && _entry == null) _start(catalog);
    final entry = _entry;
    if (entry == null) return const SizedBox.expand();

    final step = _steps[_step];
    final last = _step == _steps.length - 1;
    final demo = GameState(
      mode: GameMode.random,
      level: entry.level,
      board: step.board,
      secondsLeft: 0,
      phase: last ? GamePhase.solved : GamePhase.playing,
      practice: true,
    );
    final bp = context.bp;
    final t = Theme.of(context).textTheme;

    return ExcludeSemantics(
      child: IgnorePointer(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: Column(
            key: ValueKey(entry.id),
            children: [
              Expanded(
                child: TreeView(state: demo, onTapNode: (_) {}, onTapGap: (_) {}),
              ),
              const SizedBox(height: 6),
              LayoutBuilder(
                builder: (context, c) => _Dimension(
                  width: c.maxWidth - 16,
                  label: linearText(step.board),
                  style: t.labelMedium?.copyWith(
                    color: last ? bp.ink : bp.muted,
                    fontWeight: last ? FontWeight.w600 : null,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Dimension extends StatelessWidget {
  const _Dimension({required this.width, required this.label, this.style});
  final double width;
  final String label;
  final TextStyle? style;

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
            child: Text(label, style: style ?? Theme.of(context).textTheme.labelSmall?.copyWith(color: bp.muted)),
          ),
          Expanded(child: Container(height: 1, color: bp.line)),
          Container(width: 1, height: 10, color: bp.ink),
        ],
      ),
    );
  }
}
