import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/prefs.dart';
import '../../data/firestore_repository.dart';
import '../../data/models.dart';
import '../game/domain/challenge.dart';

final challengeStatsProvider = FutureProvider<Map<ChallengeKind, ChallengeStats>>((ref) async {
  final local = _local(ref);
  final remote = <ChallengeKind, ChallengeStats>{};
  if (ref.watch(repositoryProvider) != null) {
    try {
      remote.addAll((await ref.watch(profileProvider.future))?.challenges ?? const {});
    } catch (_) {
    }
  }
  return {
    for (final k in ChallengeKind.values)
      k: (local[k] ?? const ChallengeStats()).merge(remote[k] ?? const ChallengeStats()),
  };
});

Map<ChallengeKind, ChallengeStats> _local(Ref ref) {
  final raw = ref.read(sharedPreferencesProvider).getString(PrefKeys.challenges);
  if (raw == null) return {};
  try {
    return {
      for (final e in (jsonDecode(raw) as Map).entries)
        ?ChallengeKind.values.asNameMap()[e.key]: ChallengeStats.fromMap((e.value as Map).cast<String, dynamic>()),
    };
  } catch (_) {
    return {};
  }
}

Future<bool> recordChallengeRun(WidgetRef ref, ChallengeRun run) async {
  final before = (await ref.read(challengeStatsProvider.future))[run.kind] ?? const ChallengeStats();
  final prefs = ref.read(sharedPreferencesProvider);
  final raw = prefs.getString(PrefKeys.challenges);
  final local = <String, dynamic>{...?(raw == null ? null : jsonDecode(raw) as Map<String, dynamic>)};
  final mine = ChallengeStats.fromMap((local[run.kind.name] as Map?)?.cast<String, dynamic>() ?? const {});
  local[run.kind.name] = mine.merge(before).add(run.solved).toMap();
  await prefs.setString(PrefKeys.challenges, jsonEncode(local));
  try {
    await ref.read(repositoryProvider)?.saveChallengeRun(run.kind, run.solved);
    ref.invalidate(profileProvider);
  } catch (_) {
  }
  ref.invalidate(challengeStatsProvider);
  return run.solved > before.best;
}
