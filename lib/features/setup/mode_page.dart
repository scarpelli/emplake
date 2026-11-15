import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../data/firestore_repository.dart';
import '../../data/models.dart';
import '../avatar/avatar_page.dart';
import '../avatar/robot_avatar.dart';
import '../daily/daily_card.dart';
import '../game/application/game_controller.dart';
import '../settings/settings_page.dart';

class ModePage extends ConsumerStatefulWidget {
  const ModePage({super.key});

  @override
  ConsumerState<ModePage> createState() => _ModePageState();
}

class _ModePageState extends ConsumerState<ModePage> {
  GameMode _mode = GameMode.adventure;
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
    GameMode.daily: Icons.today_outlined,
  };

  static const _listed = [
    GameMode.adventure,
    GameMode.random,
    GameMode.challenges,
    GameMode.educational,
    GameMode.specific,
  ];

  PointerDeviceKind? _lastPointer;

  void _open(GameMode m) {
    final direct = m == _mode || _lastPointer == PointerDeviceKind.touch;
    setState(() => _mode = m);
    if (direct) _continue();
  }

  void _continue() {
    if (_mode == GameMode.educational) {
      context.go('/play/learn');
    } else if (_mode == GameMode.adventure) {
      context.go('/play/adventure');
    } else if (_mode == GameMode.challenges) {
      context.go('/play/challenges');
    } else {
      context.go('/play/level?mode=${_mode.name}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;
    final bp = context.bp;
    final user = ref.watch(authStateProvider).value;
    final narrow = MediaQuery.sizeOf(context).width < 600;
    final fallbackName = switch (user?.displayName) {
      _ when user?.isAnonymous ?? false => l.guest,
      final name? when name.isNotEmpty => name.split(' ').first,
      _ => l.player,
    }.toUpperCase();

    return ContentWidth(
      child: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: SliverToBoxAdapter(
              child: Row(
                children: [
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Semantics(
                        button: true,
                        label: l.openProfile,
                        child: InkWell(
                          onTap: () => openPlayerSettings(context, ref),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(minHeight: 44),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RobotAvatarView(
                                  ref.watch(playerAvatarProvider),
                                  size: 30,
                                  semanticLabel: l.avatarYours,
                                ),
                                const SizedBox(width: 10),
                                Flexible(
                                  child: FutureBuilder<UserProfile>(
                                    future: _profile,
                                    builder: (context, snap) {
                                      final name = (snap.data?.displayName.isNotEmpty ?? false)
                                          ? snap.data!.displayName.split(' ').first.toUpperCase()
                                          : fallbackName;
                                      if (snap.connectionState == ConnectionState.waiting) {
                                        return Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Eyebrow(name),
                                            const SizedBox(width: 8),
                                            const SizedBox(width: 28, height: 14, child: BpLoader(size: 14)),
                                          ],
                                        );
                                      }
                                      return Eyebrow(l.greeting(name, snap.data?.totalPoints ?? 0));
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SoundToggle(),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            sliver: const SliverToBoxAdapter(child: DailyCard()),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
            sliver: SliverToBoxAdapter(
              child: PageTitle(eyebrow: l.stepOf(1, 2), title: l.modeQuestion),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverList.separated(
              itemCount: _listed.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final m = _listed[i];
                final selected = m == _mode;
                return Listener(
                  onPointerDown: (e) => _lastPointer = e.kind,
                  child: SelectTile(
                    selected: selected,
                    enabled: m.isAvailable,
                    onTap: () => _open(m),
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
                                    child: Text(
                                      m.label(l),
                                      style: t.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w600,
                                        color: selected ? bp.onInk : bp.ink,
                                      ),
                                    ),
                                  ),
                                  if (!m.isAvailable)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(border: Border.all(color: bp.line)),
                                      child: Text(l.comingSoon, style: t.labelSmall?.copyWith(letterSpacing: 1)),
                                    )
                                  else
                                    Text(
                                      (i + 1).toString().padLeft(2, '0'),
                                      style: t.labelSmall?.copyWith(color: selected ? bp.onInk : bp.muted),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                m.description(l),
                                style: t.bodySmall?.copyWith(
                                  height: 1.4,
                                  color: (selected ? bp.onInk : bp.ink).withValues(alpha: 0.8),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (narrow)
            const SliverToBoxAdapter(child: SizedBox(height: 28))
          else
            SliverPadding(
              padding: const EdgeInsets.all(20),
              sliver: SliverToBoxAdapter(
                child: FilledButton.icon(
                  iconAlignment: IconAlignment.end,
                  icon: const Icon(Icons.arrow_forward),
                  label: Text(l.continueLabel),
                  onPressed: _continue,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
