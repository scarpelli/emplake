import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/l10n_helpers.dart';
import '../../data/firestore_repository.dart';
import '../auth/login_page.dart' show TextLink;

bool hasPasswordLogin(User? user) => user?.providerData.any((p) => p.providerId == 'password') ?? false;

Future<void> showEditNameDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _EditNameDialog());

Future<void> showChangePasswordDialog(BuildContext context) =>
    showDialog<void>(context: context, builder: (_) => const _ChangePasswordDialog());

class _DialogFrame extends StatelessWidget {
  const _DialogFrame({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
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
                    child: Text(title, style: t.titleMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1)),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: context.l10n.close,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: children),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.text);

  final String? text;

  @override
  Widget build(BuildContext context) {
    if (text == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Text(
        text!,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.error),
      ),
    );
  }
}

class _SubmitButton extends StatelessWidget {
  const _SubmitButton({required this.busy, required this.label, required this.onPressed});

  final bool busy;
  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => FilledButton(
    onPressed: busy ? null : onPressed,
    child: busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : Text(label),
  );
}

void _closeWithMessage(BuildContext context, String message) {
  final messenger = ScaffoldMessenger.of(context);
  Navigator.of(context).pop();
  messenger.showSnackBar(SnackBar(content: Text(message)));
}

class _EditNameDialog extends ConsumerStatefulWidget {
  const _EditNameDialog();

  @override
  ConsumerState<_EditNameDialog> createState() => _EditNameDialogState();
}

class _EditNameDialogState extends ConsumerState<_EditNameDialog> {
  late final _name = TextEditingController(text: ref.read(firebaseAuthProvider).currentUser?.displayName ?? '');
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final l = context.l10n;
    final name = _name.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (name.isEmpty) {
      setState(() => _error = l.accountNameEmpty);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = ref.read(firebaseAuthProvider).currentUser!;
      await user.updateDisplayName(name);
      await ref.read(repositoryProvider)?.saveIdentity(displayName: name, email: user.email ?? '');
      ref.invalidate(profileProvider);
      if (mounted) _closeWithMessage(context, l.accountNameSaved);
    } on Exception {
      if (mounted) setState(() => _error = l.saveError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return _DialogFrame(
      title: l.accountEditName,
      children: [
        TextField(
          controller: _name,
          enabled: !_busy,
          autofocus: true,
          maxLength: 40,
          textCapitalization: TextCapitalization.words,
          autofillHints: const [AutofillHints.name],
          onSubmitted: (_) => _busy ? null : _save(),
          decoration: InputDecoration(labelText: l.accountNameLabel, counterText: ''),
        ),
        _ErrorText(_error),
        const SizedBox(height: 16),
        _SubmitButton(busy: _busy, label: l.save, onPressed: _save),
      ],
    );
  }
}

class _ChangePasswordDialog extends ConsumerStatefulWidget {
  const _ChangePasswordDialog();

  @override
  ConsumerState<_ChangePasswordDialog> createState() => _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<_ChangePasswordDialog> {
  final _current = TextEditingController();
  final _next = TextEditingController();
  bool _busy = false;
  bool _hide = true;
  String? _error;

  @override
  void dispose() {
    _current.dispose();
    _next.dispose();
    super.dispose();
  }

  FirebaseAuth get _auth => ref.read(firebaseAuthProvider);

  Future<void> _save() async {
    final l = context.l10n;
    final error = _current.text.isEmpty
        ? l.accountWrongPassword
        : _next.text.length < 6
        ? l.linkWeakPassword
        : null;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final user = _auth.currentUser!;
      await user.reauthenticateWithCredential(
        EmailAuthProvider.credential(email: user.email!, password: _current.text),
      );
      await user.updatePassword(_next.text);
      if (mounted) _closeWithMessage(context, l.accountPasswordSaved);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      setState(
        () => _error = switch (e.code) {
          'wrong-password' || 'invalid-credential' || 'invalid-login-credentials' => l.accountWrongPassword,
          'weak-password' => l.linkWeakPassword,
          'too-many-requests' => l.accountTooManyAttempts,
          _ => l.accountPasswordError,
        },
      );
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _sendReset() async {
    final l = context.l10n;
    final email = _auth.currentUser?.email ?? '';
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await _auth.sendPasswordResetEmail(email: email);
      if (mounted) _closeWithMessage(context, l.accountResetSent(email));
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        setState(() => _error = e.code == 'too-many-requests' ? l.accountTooManyAttempts : l.accountPasswordError);
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget field(TextEditingController c, String label, String hint, {bool autofocus = false}) => TextField(
      controller: c,
      enabled: !_busy,
      autofocus: autofocus,
      obscureText: _hide,
      autofillHints: [hint],
      onSubmitted: (_) => _busy ? null : _save(),
      decoration: InputDecoration(
        labelText: label,
        suffixIcon: IconButton(
          icon: Icon(_hide ? Icons.visibility_outlined : Icons.visibility_off_outlined),
          onPressed: () => setState(() => _hide = !_hide),
        ),
      ),
    );

    return _DialogFrame(
      title: l.accountChangePassword,
      children: [
        AutofillGroup(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              field(_current, l.accountCurrentPassword, AutofillHints.password, autofocus: true),
              const SizedBox(height: 12),
              field(_next, l.accountNewPassword, AutofillHints.newPassword),
            ],
          ),
        ),
        _ErrorText(_error),
        const SizedBox(height: 16),
        _SubmitButton(busy: _busy, label: l.save, onPressed: _save),
        const SizedBox(height: 8),
        Center(
          child: TextLink(label: l.accountForgotPassword, onTap: _busy ? null : _sendReset),
        ),
      ],
    );
  }
}
