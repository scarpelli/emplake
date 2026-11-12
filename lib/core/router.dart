import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../data/firestore_repository.dart';
import '../features/auth/login_page.dart';
import '../features/cover/cover_page.dart';
import '../features/game/application/game_controller.dart';
import '../features/game/domain/level.dart';
import '../features/game/presentation/game_page.dart';
import '../features/game/presentation/new_game_page.dart';
import '../features/history/solved_page.dart';
import '../features/settings/settings_page.dart';
import '../features/setup/level_page.dart';
import '../features/setup/mode_page.dart';
import '../features/shell/app_shell.dart';
import 'l10n_helpers.dart';
import 'prefs.dart';

class _StreamListenable extends ChangeNotifier {
  _StreamListenable(Stream<dynamic> stream) {
    _sub = stream.listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

bool _isRestorable(String location) =>
    location.startsWith('/play') ||
    location == '/game' ||
    location.startsWith('/history') ||
    location.startsWith('/settings');

final routerProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(firebaseAuthProvider);
  final prefs = ref.read(sharedPreferencesProvider);
  final refresh = _StreamListenable(auth.authStateChanges());
  ref.onDispose(refresh.dispose);

  String? saved() => prefs.getString(PrefKeys.lastLocation);

  final router = GoRouter(
    initialLocation: saved() ?? '/cover',
    refreshListenable: refresh,
    redirect: (context, state) {
      final loc = state.uri.path;
      final signedIn = auth.currentUser != null;
      if (loc == '/' || loc.isEmpty) return saved() ?? '/cover';
      if (loc == '/cover') return null;
      if (!signedIn) return loc == '/login' ? null : '/login';
      if (loc == '/login') return saved() ?? '/play';
      return null;
    },
    errorBuilder: (context, state) => Scaffold(body: Center(child: Text(context.l10n.notFound))),
    routes: [
      GoRoute(path: '/cover', builder: (_, _) => const CoverPage()),
      GoRoute(path: '/login', builder: (_, _) => const LoginPage()),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/play',
              builder: (_, _) => const ModePage(),
              routes: [
                GoRoute(
                  path: 'level',
                  builder: (_, state) => LevelPage(
                    mode: GameMode.values.asNameMap()[state.uri.queryParameters['mode']] ?? GameMode.random,
                  ),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/history', builder: (_, _) => const SolvedPage()),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/game',
              builder: (_, _) => const GamePage(),
              routes: [
                GoRoute(
                  path: 'new',
                  builder: (_, state) {
                    final q = state.uri.queryParameters;
                    return NewGamePage(
                      key: ValueKey(state.uri.toString()),
                      mode: GameMode.values.asNameMap()[q['mode']] ?? GameMode.random,
                      level: Level.values.asNameMap()[q['level']] ?? Level.intermediate,
                      number: q['n'],
                      exclude: q['exclude'],
                    );
                  },
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(path: '/settings', builder: (_, _) => const SettingsPage()),
          ]),
        ],
      ),
    ],
  );

  void remember() {
    final location = router.routerDelegate.currentConfiguration.uri.toString();
    if (_isRestorable(location)) prefs.setString(PrefKeys.lastLocation, location);
  }

  router.routerDelegate.addListener(remember);
  ref.onDispose(() {
    router.routerDelegate.removeListener(remember);
    router.dispose();
  });
  return router;
});

String newGameLocation({required GameMode mode, required Level level, String? number, String? exclude}) =>
    Uri(path: '/game/new', queryParameters: {
      'mode': mode.name,
      'level': level.name,
      'n': ?number,
      'exclude': ?exclude,
    }).toString();
