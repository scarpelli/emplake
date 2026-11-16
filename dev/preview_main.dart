import 'dart:async';

import 'package:emplake/app.dart';
import 'package:emplake/core/prefs.dart';
import 'package:emplake/data/firestore_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _startAsGuest = bool.fromEnvironment('PREVIEW_GUEST');

class _FakeUser implements User {
  _FakeUser(this._auth, {required this.isAnonymous, this.displayName, this.email});

  final _FakeAuth _auth;
  @override
  final bool isAnonymous;
  @override
  String? displayName;
  @override
  final String? email;
  @override
  String get uid => 'preview';
  @override
  List<UserInfo> get providerData => [if (!isAnonymous) _PasswordInfo()];
  @override
  Future<void> reload() async {}
  @override
  Future<void> updateDisplayName(String? name) async {
    displayName = name;
    _auth._changes.add(this);
  }

  @override
  Future<UserCredential> reauthenticateWithCredential(AuthCredential credential) async {
    if (credential is EmailAuthCredential && credential.password == _auth._password) return _FakeCredential(this);
    throw FirebaseAuthException(code: 'invalid-credential');
  }

  @override
  Future<void> updatePassword(String newPassword) async => _auth._password = newPassword;
  @override
  Future<UserCredential> linkWithCredential(AuthCredential credential) async {
    final email = credential is EmailAuthCredential ? credential.email : null;
    return _auth._set(_FakeUser(_auth, isAnonymous: false, email: email));
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _PasswordInfo implements UserInfo {
  @override
  String get providerId => 'password';
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeCredential implements UserCredential {
  _FakeCredential(this.user);

  @override
  final User? user;
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeAuth implements FirebaseAuth {
  _FakeAuth() {
    if (!_startAsGuest) {
      _user = _FakeUser(this, isAnonymous: false, displayName: 'Maria Preview', email: 'maria@exemplo.com');
    }
  }

  final _changes = StreamController<User?>.broadcast();
  User? _user;
  String _password = 'senha123';

  UserCredential _set(User? user) {
    _user = user;
    _changes.add(user);
    return _FakeCredential(user);
  }

  Stream<User?> _stream() async* {
    yield _user;
    yield* _changes.stream;
  }

  @override
  User? get currentUser => _user;
  @override
  Stream<User?> authStateChanges() => _stream();
  @override
  Stream<User?> userChanges() => _stream();
  @override
  Future<UserCredential> signInAnonymously() async => _set(_FakeUser(this, isAnonymous: true));
  @override
  Future<void> signOut() async => _set(null);
  @override
  Future<void> sendPasswordResetEmail({required String email, ActionCodeSettings? actionCodeSettings}) async {}
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  usePathUrlStrategy();
  final prefs = await SharedPreferences.getInstance();
  final auth = _FakeAuth();
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        firebaseAuthProvider.overrideWithValue(auth),
        authStateProvider.overrideWith((ref) => auth.userChanges()),
        repositoryProvider.overrideWithValue(null),
      ],
      child: const EmplakeApp(),
    ),
  );
}
