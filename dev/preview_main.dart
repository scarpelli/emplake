import 'package:emplake/app.dart';
import 'package:emplake/core/prefs.dart';
import 'package:emplake/data/firestore_repository.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeUser implements User {
  @override
  String get uid => 'preview';
  @override
  String? get displayName => 'Maria Preview';
  @override
  String? get email => 'maria@exemplo.com';
  @override
  List<UserInfo> get providerData => const [];
  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

class _FakeAuth implements FirebaseAuth {
  User? _user = _FakeUser();
  @override
  User? get currentUser => _user;
  @override
  Stream<User?> authStateChanges() => Stream.value(_user);
  @override
  Stream<User?> userChanges() => Stream.value(_user);
  @override
  Future<void> signOut() async => _user = null;
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
