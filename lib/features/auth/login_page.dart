import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart' hide EmailAuthProvider;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../core/widgets/emplake_logo.dart';

const teamMembers = ['Bruna Scarpelli', 'Gustavo Kis', 'Ricardo Suzuki'];

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: GridBackground(
        child: SignInScreen(
          providers: [EmailAuthProvider()],
          showPasswordVisibilityToggle: true,
          breakpoint: 900,
          maxWidth: 1080,
          headerMaxExtent: 210,
          headerBuilder: (context, constraints, shrinkOffset) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(alignment: Alignment.topRight, child: LanguagePicker()),
                const Spacer(),
                Row(
                  children: [
                    const EmplakeLogo(size: 40),
                    const SizedBox(width: 12),
                    Text('EMPLAKE', style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 4)),
                  ],
                ),
                const SizedBox(height: 6),
                Text(l.loginSubtitle, style: t.bodyMedium?.copyWith(color: context.bp.muted)),
              ],
            ),
          ),
          sideBuilder: (context, constraints) => Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const LanguagePicker(showNames: true),
                  const SizedBox(height: 40),
                  const EmplakeLogo(size: 72),
                  const SizedBox(height: 16),
                  Text('EMPLAKE', style: t.displaySmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 6)),
                  const SizedBox(height: 8),
                  Text(l.loginSubtitle, style: t.titleMedium?.copyWith(color: context.bp.muted)),
                  const SizedBox(height: 40),
                  const _TeamCard(),
                ],
              ),
            ),
          ),
          footerBuilder: (context, action) {
            final wide = MediaQuery.sizeOf(context).width >= 900;
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 16),
                const _OrDivider(),
                const SizedBox(height: 16),
                const Center(child: _GoogleButton()),
                if (!wide) const Padding(padding: EdgeInsets.only(top: 24), child: _TeamCard()),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TeamCard extends StatelessWidget {
  const _TeamCard();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: bp.line)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            color: bp.ink,
            child: Text(l.loginTeam, style: t.labelSmall?.copyWith(color: bp.onInk, letterSpacing: 2)),
          ),
          for (var i = 0; i < teamMembers.length; i++)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: bp.lineSoft)),
              ),
              child: Row(
                children: [
                  SizedBox(width: 120, child: Eyebrow(l.loginMember(i + 1), opacity: 0.6)),
                  Expanded(
                    child: Text(teamMembers[i], style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(
              l.loginCredit,
              style: t.bodySmall?.copyWith(color: bp.muted, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    return Row(
      children: [
        Expanded(child: Divider(color: bp.lineSoft)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Eyebrow(context.l10n.loginOr, opacity: 0.6),
        ),
        Expanded(child: Divider(color: bp.lineSoft)),
      ],
    );
  }
}

class _GoogleButton extends StatefulWidget {
  const _GoogleButton();

  @override
  State<_GoogleButton> createState() => _GoogleButtonState();
}

class _GoogleButtonState extends State<_GoogleButton> {
  bool _busy = false;

  Future<void> _signIn() async {
    setState(() => _busy = true);
    final provider = GoogleAuthProvider()..setCustomParameters({'prompt': 'select_account'});
    try {
      if (kIsWeb) {
        await FirebaseAuth.instance.signInWithPopup(provider);
      } else {
        await FirebaseAuth.instance.signInWithProvider(provider);
      }
    } on FirebaseAuthException catch (e) {
      const cancelled = {'popup-closed-by-user', 'cancelled-popup-request', 'web-context-canceled', 'canceled'};
      if (!cancelled.contains(e.code) && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.loginGoogleError)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) => OutlinedButton(
    style: OutlinedButton.styleFrom(
      minimumSize: const Size(0, 44),
      padding: const EdgeInsets.symmetric(horizontal: 16),
    ),
    onPressed: _busy ? null : _signIn,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _busy
            ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
            : const SizedBox(width: 18, height: 18, child: CustomPaint(painter: _GoogleGPainter())),
        const SizedBox(width: 10),
        Text(context.l10n.loginGoogle),
      ],
    ),
  );
}

class _GoogleGPainter extends CustomPainter {
  const _GoogleGPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final stroke = s * 0.2;
    final rect = Rect.fromCircle(center: size.center(Offset.zero), radius: (s - stroke) / 2);
    Paint p(int color) => Paint()
      ..color = Color(color)
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    double rad(double deg) => deg * math.pi / 180;
    canvas.drawArc(rect, rad(-40), rad(-100), false, p(0xFFEA4335));
    canvas.drawArc(rect, rad(-140), rad(-85), false, p(0xFFFBBC05));
    canvas.drawArc(rect, rad(135), rad(-95), false, p(0xFF34A853));
    canvas.drawArc(rect, rad(40), rad(-40), false, p(0xFF4285F4));
    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTRB(
        size.width / 2,
        size.height / 2 - stroke / 2,
        rect.right + stroke / 2,
        size.height / 2 + stroke / 2,
      ),
      bar,
    );
  }

  @override
  bool shouldRepaint(_GoogleGPainter oldDelegate) => false;
}
