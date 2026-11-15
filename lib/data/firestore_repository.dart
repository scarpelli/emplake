import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/avatar/robot_avatar.dart';
import '../features/daily/daily.dart';
import '../features/game/application/catalog_provider.dart';
import '../features/game/domain/adventure.dart';
import '../features/game/domain/catalog.dart';
import '../features/game/domain/challenge.dart';
import '../features/game/domain/level.dart';
import 'models.dart';

class FirestoreRepository {
  FirestoreRepository(this._db, this.user);

  final FirebaseFirestore _db;
  final User user;

  DocumentReference<Map<String, dynamic>> get _userDoc => _db.collection('users').doc(user.uid);
  CollectionReference<Map<String, dynamic>> get _solved => _userDoc.collection('solved');
  CollectionReference<Map<String, dynamic>> get _skipped => _userDoc.collection('skipped');

  static String docId(Level level, String number) => '${level.name}_$number';

  Future<UserProfile> loadProfile() async {
    final snap = await _userDoc.get();
    if (snap.exists) return UserProfile.fromMap(snap.data()!);
    final data = {
      'displayName': user.displayName ?? '',
      'email': user.email ?? '',
      'totalPoints': 0,
      'solvedCount': 0,
      'skippedCount': 0,
      'createdAt': FieldValue.serverTimestamp(),
    };
    await _userDoc.set(data, SetOptions(merge: true));
    return UserProfile.fromMap(data);
  }

  Future<void> saveIdentity({required String displayName, required String email}) =>
      _userDoc.set({'displayName': displayName, 'email': email}, SetOptions(merge: true));

  Future<void> saveAvatar(RobotAvatar avatar) => _userDoc.set({'avatar': avatar.toMap()}, SetOptions(merge: true));

  Future<Set<String>> solvedNumbers(Level level) async {
    final q = await _solved.where('level', isEqualTo: level.name).get();
    return {for (final d in q.docs) d.data()['number'] as String};
  }

  Future<bool> isSolved(Level level, String number) async => (await _solved.doc(docId(level, number)).get()).exists;

  Future<CatalogEntry?> pickUnsolved(Catalog catalog, Level level, {String? exclude, Random? random}) async {
    final solved = await solvedNumbers(level);
    return DrawPolicy.pick(catalog, level, solved, exclude: exclude, random: random);
  }

  Future<SaveOutcome> saveSolved({
    required Level level,
    required String number,
    required String expression,
    required String latex,
    required int points,
    required int seconds,
    required bool inTime,
    int hints = 0,
    bool blind = false,
  }) {
    final ref = _solved.doc(docId(level, number));
    return _db.runTransaction((tx) async {
      final existing = await tx.get(ref);
      final profile = await tx.get(_userDoc);
      final data = profile.data() ?? const <String, dynamic>{};
      final total = (data['totalPoints'] as num?)?.toInt() ?? 0;
      final streak = (data['streak'] as num?)?.toInt() ?? 0;
      if (existing.exists) {
        return SaveOutcome(isNew: false, pointsAwarded: 0, totalPoints: total, streak: streak);
      }
      final keeps = inTime && hints == 0;
      final newStreak = keeps ? streak + 1 : 0;
      final best = (data['bestStreak'] as num?)?.toInt() ?? 0;
      tx.set(ref, {
        'number': number,
        'level': level.name,
        'expression': expression,
        'latex': latex,
        'points': points,
        'seconds': seconds,
        'inTime': inTime,
        'hints': hints,
        'blind': blind,
        'solvedAt': FieldValue.serverTimestamp(),
      });
      tx.set(_userDoc, {
        'displayName': user.displayName ?? '',
        'email': user.email ?? '',
        'totalPoints': FieldValue.increment(points),
        'solvedCount': FieldValue.increment(1),
        'solvedByLevel': {level.name: FieldValue.increment(1)},
        'streak': newStreak,
        'bestStreak': newStreak > best ? newStreak : best,
        if (inTime) 'inTimeSolves': FieldValue.increment(1),
        if (inTime && blind) 'blindSolves': FieldValue.increment(1),
      }, SetOptions(merge: true));
      return SaveOutcome(isNew: true, pointsAwarded: points, totalPoints: total + points, streak: newStreak);
    });
  }

  Future<Map<String, int>> solvedStars() async {
    final q = await _solved.get();
    final out = <String, int>{};
    for (final d in q.docs) {
      final m = d.data();
      final level = Level.values.asNameMap()[m['level']];
      if (level == null) continue;
      out[d.id] = AdventureStars.ofSolved(
        level: level,
        inTime: m['inTime'] as bool? ?? true,
        hints: (m['hints'] as num?)?.toInt() ?? 0,
        seconds: (m['seconds'] as num?)?.toInt() ?? 0,
      );
    }
    return out;
  }

  Future<void> saveAdventureStars(String id, int stars) => _db.runTransaction((tx) async {
    final snap = await tx.get(_userDoc);
    final old = ((snap.data()?['adventure'] as Map?)?[id] as num?)?.toInt() ?? 0;
    if (stars <= old) return;
    tx.set(_userDoc, {
      'adventure': {id: stars},
    }, SetOptions(merge: true));
  });

  Future<ChallengeStats> saveChallengeRun(ChallengeKind kind, int score) => _db.runTransaction((tx) async {
    final snap = await tx.get(_userDoc);
    final old = ChallengeStats.fromMap(
      ((snap.data()?['challenges'] as Map?)?[kind.name] as Map?)?.cast<String, dynamic>() ?? const {},
    );
    final next = old.add(score);
    tx.set(_userDoc, {
      'challenges': {kind.name: next.toMap()},
    }, SetOptions(merge: true));
    return next;
  });

  Future<void> recordSkip(Level level, String number, {bool revealed = false}) async {
    final batch = _db.batch();
    batch.set(_skipped.doc(docId(level, number)), {
      'number': number,
      'level': level.name,
      'times': FieldValue.increment(1),
      'lastAt': FieldValue.serverTimestamp(),
      if (revealed) 'revealed': true,
    }, SetOptions(merge: true));
    batch.set(_userDoc, {'skippedCount': FieldValue.increment(1), 'streak': 0}, SetOptions(merge: true));
    await batch.commit();
  }

  DocumentReference<Map<String, dynamic>> _dailyDoc(String key) => _userDoc.collection('daily').doc(key);

  DocumentReference<Map<String, dynamic>> _dailyStats(String key) => _db.collection('dailyStats').doc(key);

  Future<DailyStats> dailyStats(String key) async {
    final snap = await _dailyStats(key).get();
    return snap.exists ? DailyStats.fromMap(snap.data()!) : const DailyStats();
  }

  Future<DailyResult?> dailyResult(String key) async {
    final snap = await _dailyDoc(key).get();
    return snap.exists ? DailyResult.fromMap(snap.data()!) : null;
  }

  Future<void> startDaily(String key, {required String number, required Level level}) =>
      _dailyDoc(key).set({'number': number, 'level': level.name, 'status': 'started'}, SetOptions(merge: true));

  Future<bool> recordPlayedDay(String key) => _db.runTransaction((tx) async {
    final data = (await tx.get(_userDoc)).data() ?? const <String, dynamic>{};
    final last = data['lastDaily'] as String?;
    if (last == key) return false;
    final streak = Daily.nextStreak(key: key, lastDay: last, current: (data['dailyStreak'] as num?)?.toInt() ?? 0);
    tx.set(_userDoc, {'dailyStreak': streak, 'lastDaily': key}, SetOptions(merge: true));
    return true;
  });

  Future<void> finishDaily(
    String key, {
    required bool solved,
    required int seconds,
    required int hints,
    required bool blind,
    String? solution,
  }) {
    return _db.runTransaction((tx) async {
      final previous = await tx.get(_dailyDoc(key));
      final status = previous.data()?['status'];
      if (status != 'solved' && status != 'failed') {
        tx.set(_dailyStats(key), {
          'plays': FieldValue.increment(1),
          if (solved)
            'times': {DailyStats.bucketKey(seconds): FieldValue.increment(1)}
          else
            'missed': FieldValue.increment(1),
        }, SetOptions(merge: true));
      }
      tx.set(_dailyDoc(key), {
        'status': solved ? 'solved' : 'failed',
        'seconds': seconds,
        'hints': hints,
        'blind': blind,
        'solution': ?solution,
        'finishedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    });
  }

  Future<void> unlockAchievements(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    await _userDoc.set({
      'achievements': {for (final id in ids) id: FieldValue.serverTimestamp()},
    }, SetOptions(merge: true));
  }

  Future<HistorySnapshot> loadHistory() async {
    final results = await Future.wait([
      _solved.orderBy('solvedAt', descending: true).limit(500).get(),
      _userDoc.get(),
      _skipped.orderBy('lastAt', descending: true).limit(200).get(),
    ]);
    final solved = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final profile = results[1] as DocumentSnapshot<Map<String, dynamic>>;
    final skipped = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final solvedIds = {for (final d in solved.docs) d.id};
    return HistorySnapshot(
      entries: [for (final d in solved.docs) SolvedEntry.fromMap(d.data())],
      skippedCount: (profile.data()?['skippedCount'] as num?)?.toInt() ?? 0,
      solvedCount: (profile.data()?['solvedCount'] as num?)?.toInt(),
      skipped: [
        for (final d in skipped.docs)
          if (!solvedIds.contains(d.id)) SkippedEntry.fromMap(d.data()),
      ],
    );
  }
}

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>((ref) => ref.watch(firebaseAuthProvider).userChanges());

final repositoryProvider = Provider<FirestoreRepository?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return FirestoreRepository(FirebaseFirestore.instance, user);
});

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = ref.watch(repositoryProvider);
  return repo?.loadProfile();
});
