import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/prefs.dart';
import '../../data/firestore_repository.dart';
import '../game/application/catalog_provider.dart';
import '../game/domain/adventure.dart';

final adventureStarsProvider = FutureProvider<Map<String, int>>((ref) async {
  final out = <String, int>{..._local(ref)};
  void keep(Map<String, int> m) {
    for (final e in m.entries) {
      if (e.value > (out[e.key] ?? 0)) out[e.key] = e.value;
    }
  }

  final repo = ref.watch(repositoryProvider);
  if (repo != null) {
    try {
      final profile = await ref.watch(profileProvider.future);
      keep(profile?.adventure ?? const {});
      keep(await repo.solvedStars());
    } catch (_) {
    }
  }
  return out;
});

final adventureProgressProvider = FutureProvider<AdventureProgress>((ref) async {
  final catalog = await ref.watch(catalogProvider.future);
  final stars = await ref.watch(adventureStarsProvider.future);
  return AdventureProgress.from(catalog, stars);
});

Map<String, int> _local(Ref ref) {
  final raw = ref.read(sharedPreferencesProvider).getString(PrefKeys.adventure);
  if (raw == null) return {};
  try {
    return (jsonDecode(raw) as Map).map((k, v) => MapEntry(k as String, (v as num).toInt()));
  } catch (_) {
    return {};
  }
}

Future<void> recordAdventureStars(WidgetRef ref, String id, int stars) async {
  if (stars <= 0) return;
  final prefs = ref.read(sharedPreferencesProvider);
  final raw = prefs.getString(PrefKeys.adventure);
  final local = <String, dynamic>{...?(raw == null ? null : jsonDecode(raw) as Map<String, dynamic>)};
  if (stars > ((local[id] as num?)?.toInt() ?? 0)) {
    local[id] = stars;
    await prefs.setString(PrefKeys.adventure, jsonEncode(local));
  }
  try {
    await ref.read(repositoryProvider)?.saveAdventureStars(id, stars);
  } catch (_) {
  }
  ref.invalidate(adventureStarsProvider);
}
