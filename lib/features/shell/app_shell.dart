import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../help/help_dialog.dart';

class AppShell extends StatelessWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  static const _helpIndex = 3;

  static int? _branchFor(int barIndex) => switch (barIndex) {
        0 => 0,
        1 => 1,
        2 => 2,
        4 => 3,
        _ => null,
      };

  static int _barFor(int branch) => branch == 3 ? 4 : branch;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final l = context.l10n;
    final current = _barFor(shell.currentIndex);
    final icons = [
      (Icons.home_outlined, l.navHome),
      (Icons.history, l.navHistory),
      (Icons.account_tree_outlined, l.navGame),
      (Icons.help_outline, l.navHelp),
      (Icons.settings_outlined, l.navSettings),
    ];

    return Scaffold(
      backgroundColor: bp.paper,
      body: GridBackground(child: SafeArea(bottom: false, child: shell)),
      bottomNavigationBar: CurvedNavigationBar(
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
        letIndexChange: (i) {
          if (i == _helpIndex) {
            showHelpDialog(context);
            return false;
          }
          return true;
        },
        onTap: (i) {
          final branch = _branchFor(i);
          if (branch == null) return;
          shell.goBranch(branch, initialLocation: branch == shell.currentIndex);
        },
      ),
    );
  }
}
