import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('sharedPreferencesProvider must be overridden'),
);

abstract final class PrefKeys {
  static const settings = 'settings.v1';
  static const lastLocation = 'nav.lastLocation';
  static const game = 'game.v1';
  static const seenCover = 'nav.seenCover';

  static const adventure = 'adventure.v1';
  static const challenges = 'challenges.v1';

  static const adventureCollapsed = 'adventure.collapsed.v1';
}
