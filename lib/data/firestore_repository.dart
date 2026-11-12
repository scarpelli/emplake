import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  Future<Set<String>> solvedNumbers(Level level) async {
    final q = await _solved.where('level', isEqualTo: level.name).get();
    return {for (final d in q.docs) d.data()['number'] as String};
  }

  Future<bool> isSolved(Level level, String number) async =>
      (await _solved.doc(docId(level, number)).get()).exists;

  Future<String?> pickUnsolved(Level level, {String? exclude, Random? random}) async {
    final solved = await solvedNumbers(level);
    return pickFrom(solved, exclude: exclude, random: random);
  }

  static String? pickFrom(Set<String> solved, {String? exclude, Random? random}) {
    final r = random ?? Random();
    for (var i = 0; i < 64; i++) {
      final n = r.nextInt(10000).toString().padLeft(4, '0');
      if (!solved.contains(n) && n != exclude) return n;
    }
    final free = [
      for (var i = 0; i < 10000; i++)
        if (!solved.contains(i.toString().padLeft(4, '0')) && i.toString().padLeft(4, '0') != exclude)
          i.toString().padLeft(4, '0'),
    ];
    if (free.isEmpty) return null;
    return free[r.nextInt(free.length)];
  }

  Future<SaveOutcome> saveSolved({
    required Level level,
    required String number,
    required String expression,
    required String latex,
    required int points,
    required int seconds,
    required bool inTime,
  }) {
    final ref = _solved.doc(docId(level, number));
    return _db.runTransaction((tx) async {
      final existing = await tx.get(ref);
      final profile = await tx.get(_userDoc);
      final total = (profile.data()?['totalPoints'] as num?)?.toInt() ?? 0;
      if (existing.exists) {
        return SaveOutcome(isNew: false, pointsAwarded: 0, totalPoints: total);
      }
      tx.set(ref, {
        'number': number,
        'level': level.name,
        'expression': expression,
        'latex': latex,
        'points': points,
        'seconds': seconds,
        'inTime': inTime,
        'solvedAt': FieldValue.serverTimestamp(),
      });
      tx.set(
        _userDoc,
        {
          'displayName': user.displayName ?? '',
          'email': user.email ?? '',
          'totalPoints': FieldValue.increment(points),
          'solvedCount': FieldValue.increment(1),
        },
        SetOptions(merge: true),
      );
      return SaveOutcome(isNew: true, pointsAwarded: points, totalPoints: total + points);
    });
  }

  Future<void> recordSkip(Level level, String number) async {
    final batch = _db.batch();
    batch.set(
      _skipped.doc(docId(level, number)),
      {
        'number': number,
        'level': level.name,
        'times': FieldValue.increment(1),
        'lastAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
    batch.set(_userDoc, {'skippedCount': FieldValue.increment(1)}, SetOptions(merge: true));
    await batch.commit();
  }

  Future<HistorySnapshot> loadHistory() async {
    final results = await Future.wait([
      _solved.orderBy('solvedAt', descending: true).limit(500).get(),
      _userDoc.get(),
    ]);
    final solved = results[0] as QuerySnapshot<Map<String, dynamic>>;
    final profile = results[1] as DocumentSnapshot<Map<String, dynamic>>;
    return HistorySnapshot(
      entries: [for (final d in solved.docs) SolvedEntry.fromMap(d.data())],
      skippedCount: (profile.data()?['skippedCount'] as num?)?.toInt() ?? 0,
    );
  }
}

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) => FirebaseAuth.instance);

final authStateProvider = StreamProvider<User?>(
  (ref) => ref.watch(firebaseAuthProvider).userChanges(),
);

final repositoryProvider = Provider<FirestoreRepository?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return null;
  return FirestoreRepository(FirebaseFirestore.instance, user);
});

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  final repo = ref.watch(repositoryProvider);
  return repo?.loadProfile();
});
