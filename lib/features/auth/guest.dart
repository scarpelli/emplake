import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_helpers.dart';
import '../../core/prefs.dart';
import '../../core/theme/blueprint.dart';
import '../../data/firestore_repository.dart';
import '../game/application/game_controller.dart';
import '../game/presentation/skip_dialog.dart';
import 'login_page.dart';

bool isGuest(User? user) => user?.isAnonymous ?? false;

Future<bool> continueAsGuest(BuildContext context, WidgetRef ref) async {
  try {
    await ref.read(firebaseAuthProvider).signInAnonymously();
    return true;
  } on FirebaseAuthException {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.guestError)));
    }
    return false;
  }
}

Future<void> resetLocalSession(WidgetRef ref) async {
  ref.read(gameControllerProvider.notifier).clear();
  await ref.read(sharedPreferencesProvider).remove(PrefKeys.lastLocation);
}

enum GuestReminder { firstGame, firstAchievement, solved5, solved15 }

const _remindersKey = 'guest.reminders.v1';

Future<void> maybeRemindGuest(BuildContext context, WidgetRef ref) async {
  if (!isGuest(ref.read(firebaseAuthProvider).currentUser)) return;
  final prefs = ref.read(sharedPreferencesProvider);
  final shown = {...?prefs.getStringList(_remindersKey)};
  final profile = await ref.read(profileProvider.future).catchError((_) => null);
  final solved = profile?.solvedCount ?? 0;

  bool due(GuestReminder r) => switch (r) {
    GuestReminder.firstGame => true,
    GuestReminder.firstAchievement => (profile?.achievements.isNotEmpty ?? false),
    GuestReminder.solved5 => solved >= 5 && solved < 15,
    GuestReminder.solved15 => solved >= 15,
  };

  final next = GuestReminder.values.where((r) => !shown.contains(r.name) && due(r)).firstOrNull;
  if (next == null) return;
  shown.add(next.name);
  if (next == GuestReminder.solved15) shown.add(GuestReminder.solved5.name);
  await prefs.setStringList(_remindersKey, shown.toList());

  await Future<void>.delayed(const Duration(milliseconds: 700));
  if (!context.mounted) return;
  final l = context.l10n;
  final create = await showChoiceDialog(
    context,
    title: l.remindTitle,
    body: switch (next) {
      GuestReminder.firstGame => l.remindFirstGame,
      GuestReminder.firstAchievement => l.remindFirstAchievement,
      GuestReminder.solved5 || GuestReminder.solved15 => l.remindSolved(solved),
    },
    primary: l.guestCreateAccount,
    secondary: l.remindLater,
  );
  if (create == true && context.mounted) await showLinkAccountDialog(context);
}

Future<void> showLinkAccountDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _LinkAccountDialog());

class _LinkAccountDialog extends ConsumerStatefulWidget {
  const _LinkAccountDialog();

  @override
  ConsumerState<_LinkAccountDialog> createState() => _LinkAccountDialogState();
}

class _LinkAccountDialogState extends ConsumerState<_LinkAccountDialog> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _busy = false;
  bool _hidePassword = true;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _linkEmail() => _run(() async {
    final l = context.l10n;
    final email = _email.text.trim();
    final password = _password.text;
    try {
      await _auth.currentUser!.linkWithCredential(EmailAuthProvider.credential(email: email, password: password));
      await _done();
    } on FirebaseAuthException catch (e) {
      switch (e.code) {
        case 'email-already-in-use' || 'credential-already-in-use':
          if (await _confirmSwitch()) {
            try {
              await _switchTo(() => _auth.signInWithEmailAndPassword(email: email, password: password));
            } on FirebaseAuthException {
              if (mounted) setState(() => _error = l.linkWrongPassword);
            }
          }
        case 'weak-password':
          setState(() => _error = l.linkWeakPassword);
        case 'invalid-email' || 'missing-email':
          setState(() => _error = l.linkInvalidEmail);
        default:
          setState(() => _error = l.linkError);
      }
    }
  });

  Future<void> _linkGoogle() => _run(() async {
    final l = context.l10n;
    final provider = GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'});
    try {
      final user = _auth.currentUser!;
      kIsWeb ? await user.linkWithPopup(provider) : await user.linkWithProvider(provider);
      await _done();
    } on FirebaseAuthException catch (e) {
      const cancelled = {'popup-closed-by-user', 'cancelled-popup-request', 'web-context-canceled', 'canceled'};
      if (cancelled.contains(e.code)) return;
      if (e.code == 'credential-already-in-use' || e.code == 'email-already-in-use') {
        if (!await _confirmSwitch()) return;
        final credential = e.credential;
        await _switchTo(() async {
          if (credential != null) {
            await _auth.signInWithCredential(credential);
          } else if (kIsWeb) {
            await _auth.signInWithPopup(provider);
          } else {
            await _auth.signInWithProvider(provider);
          }
        });
        return;
      }
      setState(() => _error = l.linkError);
    }
  });

  Future<bool> _confirmSwitch() async {
    final l = context.l10n;
    return await showChoiceDialog(
          context,
          title: l.linkExistsTitle,
          body: l.linkExistsBody,
          primary: l.linkExistsConfirm,
          secondary: l.cancel,
        ) ==
        true;
  }

  Future<void> _switchTo(Future<void> Function() signIn) async {
    await signIn();
    await resetLocalSession(ref);
    ref.invalidate(profileProvider);
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _done() async {
    await _auth.currentUser!.reload();
    var fresh = _auth.currentUser!;
    final google = fresh.providerData.where((p) => p.providerId == 'google.com').firstOrNull;
    final googleName = google?.displayName ?? '';
    if ((fresh.displayName ?? '').isEmpty && googleName.isNotEmpty) {
      await fresh.updateDisplayName(googleName);
      await fresh.reload();
      fresh = _auth.currentUser!;
    }
    await ref
        .read(repositoryProvider)
        ?.saveIdentity(displayName: fresh.displayName ?? '', email: fresh.email ?? google?.email ?? '');
    ref.invalidate(profileProvider);
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final text = context.l10n.linkDone;
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    return Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 420),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 12, 12, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      l.linkTitle,
                      style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: l.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(l.linkBody, style: t.bodyMedium?.copyWith(color: bp.muted)),
                    const SizedBox(height: 20),
                    OutlinedButton(
                      onPressed: _busy ? null : _linkGoogle,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(width: 18, height: 18, child: CustomPaint(painter: GoogleGPainter())),
                          const SizedBox(width: 10),
                          Text(l.linkGoogle),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(child: Divider(color: bp.lineSoft)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(l.loginOr, style: t.labelSmall?.copyWith(color: bp.muted, letterSpacing: 2)),
                        ),
                        Expanded(child: Divider(color: bp.lineSoft)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _email,
                      enabled: !_busy,
                      keyboardType: TextInputType.emailAddress,
                      autofillHints: const [AutofillHints.email],
                      decoration: InputDecoration(labelText: l.linkEmail),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _password,
                      enabled: !_busy,
                      obscureText: _hidePassword,
                      autofillHints: const [AutofillHints.newPassword],
                      onSubmitted: (_) => _busy ? null : _linkEmail(),
                      decoration: InputDecoration(
                        labelText: l.linkPassword,
                        suffixIcon: IconButton(
                          icon: Icon(_hidePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                          onPressed: () => setState(() => _hidePassword = !_hidePassword),
                        ),
                      ),
                    ),
                    if (_error != null) ...[
                      const SizedBox(height: 10),
                      Text(_error!, style: t.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error)),
                    ],
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: _busy ? null : _linkEmail,
                      child: _busy
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                          : Text(l.linkSubmit),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
