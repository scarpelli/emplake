import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../game/application/game_controller.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _gameBranch = 2;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bp = context.bp;
    final l = context.l10n;
    final current = shell.currentIndex;
    final icons = [
      (Icons.home_outlined, l.navHome),
      (Icons.history, l.navHistory),
      (Icons.account_tree_outlined, l.navGame),
      (Icons.settings_outlined, l.navSettings),
      (Icons.help_outline, l.navHelp),
    ];
    final away = current != _gameBranch;
    WidgetsBinding.instance.addPostFrameCallback((_) => ref.read(gameControllerProvider.notifier).setAway(away));

    return Scaffold(
      backgroundColor: bp.paper,
      body: GridBackground(child: SafeArea(bottom: false, child: shell)),
      bottomNavigationBar: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: CurvedNavigationBar(
          index: current,
          height: 62,
          color: bp.deep,
          buttonBackgroundColor: bp.ink,
          backgroundColor: bp.paper,
          animationDuration: const Duration(milliseconds: 380),
          items: [
            for (var i = 0; i < icons.length; i++)
              Tooltip(
                message: icons[i].$2,
                child: Semantics(
                  label: icons[i].$2,
                  button: true,
                  selected: i == current,
                  child: Icon(icons[i].$1, size: 26, color: i == current ? bp.onInk : bp.ink.withValues(alpha: 0.75)),
                ),
              ),
          ],
          onTap: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        ),
      ),
    );
  }
}
