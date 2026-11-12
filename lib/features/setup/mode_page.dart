import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../data/firestore_repository.dart';
import '../../data/models.dart';
import '../game/application/game_controller.dart';

class ModePage extends ConsumerStatefulWidget {
  const ModePage({super.key});

  @override
  ConsumerState<ModePage> createState() => _ModePageState();
}

class _ModePageState extends ConsumerState<ModePage> {
  GameMode _mode = GameMode.random;
  Future<UserProfile>? _profile;

  @override
  void initState() {
    super.initState();
    _profile = ref.read(repositoryProvider)?.loadProfile();
  }

  static const _icons = {
    GameMode.educational: Icons.school_outlined,
    GameMode.random: Icons.shuffle,
    GameMode.specific: Icons.pin_outlined,
    GameMode.challenges: Icons.flag_outlined,
    GameMode.adventure: Icons.map_outlined,
  };

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final bp = context.bp;
    final user = ref.watch(authStateProvider).value;
    final fallbackName = (user?.displayName?.split(' ').first ?? l.player).toUpperCase();

    return ContentWidth(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: FutureBuilder<UserProfile>(
                      future: _profile,
                      builder: (context, snap) {
                        final name = (snap.data?.displayName.isNotEmpty ?? false)
                            ? snap.data!.displayName.split(' ').first.toUpperCase()
                            : fallbackName;
                        if (snap.connectionState == ConnectionState.waiting) {
                          return Row(children: [
                            Eyebrow(name),
                            const SizedBox(width: 8),
                            const SizedBox(width: 28, height: 14, child: BpLoader(size: 14)),
                          ]);
                        }
                        return Eyebrow(l.greeting(name, snap.data?.totalPoints ?? 0));
                      },
                    ),
                  ),
                  const SoundToggle(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            sliver: SliverToBoxAdapter(child: PageTitle(eyebrow: l.stepOf(1, 2), title: l.modeQuestion)),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: GameMode.values.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final m = GameMode.values[i];
                final selected = m == _mode;
                return SelectTile(
                  selected: selected,
                  enabled: m.isAvailable,
                  onTap: () => setState(() => _mode = m),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(_icons[m]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(m.label(l),
                                      style: t.titleSmall?.copyWith(
                                          fontWeight: FontWeight.w600, color: selected ? bp.onInk : bp.ink)),
                                ),
                                if (!m.isAvailable)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(border: Border.all(color: bp.line)),
                                    child: Text(l.comingSoon, style: t.labelSmall?.copyWith(letterSpacing: 1)),
                                  )
                                else
                                  Text((i + 1).toString().padLeft(2, '0'),
                                      style: t.labelSmall?.copyWith(color: selected ? bp.onInk : bp.muted)),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(m.description(l),
                                style: t.bodySmall?.copyWith(
                                    height: 1.4, color: (selected ? bp.onInk : bp.ink).withValues(alpha: 0.8))),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverToBoxAdapter(
              child: FilledButton.icon(
                iconAlignment: IconAlignment.end,
                icon: const Icon(Icons.arrow_forward),
                label: Text(l.continueLabel),
                onPressed: () => context.go('/play/level?mode=${_mode.name}'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
