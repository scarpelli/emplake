import 'dart:math' as math;

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException;
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../core/widgets/emplake_logo.dart';
import 'guest.dart';

const teamMembers = ['Bruna Scarpelli', 'Gustavo Sanches Martins Kis'];

const googleClientId = '502048843819-feh7pu6ee6mared07grb1ndur9bf0n6c.apps.googleusercontent.com';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  static const _headerHeight = 210.0;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: GridBackground(
        child: Theme(
          data: _linkTheme(Theme.of(context)),
          child: SignInScreen(
            providers: [EmailAuthProvider()],
            showPasswordVisibilityToggle: true,
            breakpoint: 900,
            maxWidth: 1080,
            headerMaxExtent: _headerHeight,
            headerBuilder: (context, constraints, shrinkOffset) => ClipRect(
              child: OverflowBox(
                alignment: Alignment.bottomCenter,
                minHeight: _headerHeight,
                maxHeight: _headerHeight,
                child: Padding(
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
                          Text(
                            'EMPLAKE',
                            style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 4),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(l.loginSubtitle, style: t.bodyMedium?.copyWith(color: context.bp.muted)),
                    ],
                  ),
                ),
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
                  const SizedBox(height: 12),
                  const Center(child: _GuestLink()),
                  if (!wide) const Padding(padding: EdgeInsets.only(top: 24), child: _TeamCard()),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _GuestLink extends ConsumerStatefulWidget {
  const _GuestLink();

  @override
  ConsumerState<_GuestLink> createState() => _GuestLinkState();
}

class _GuestLinkState extends ConsumerState<_GuestLink> {
  bool _busy = false;

  @override
  Widget build(BuildContext context) => TextLink(
    label: context.l10n.loginGuest,
    onTap: _busy
        ? null
        : () async {
            setState(() => _busy = true);
            await continueAsGuest(context, ref);
            if (mounted) setState(() => _busy = false);
          },
  );
}

class TextLink extends StatelessWidget {
  const TextLink({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final color = onTap == null ? bp.muted : bp.ink;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodySmall
              ?.copyWith(color: color, decoration: TextDecoration.underline, decorationColor: color),
        ),
      ),
    );
  }
}

ThemeData _linkTheme(ThemeData base) {
  final text = base.textTheme;
  final buttonText = text.labelLarge?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 1);
  return base.copyWith(
    textTheme: text.copyWith(
      labelLarge: text.bodySmall?.copyWith(
        decoration: TextDecoration.underline,
        decorationColor: base.colorScheme.primary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: (base.elevatedButtonTheme.style ?? const ButtonStyle()).copyWith(
        textStyle: WidgetStatePropertyAll(buttonText),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: (base.textButtonTheme.style ?? const ButtonStyle()).copyWith(
        textStyle: WidgetStatePropertyAll(text.labelLarge),
      ),
    ),
  );
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

final _google = GoogleProvider(clientId: googleClientId);

class _GoogleButton extends StatelessWidget {
  const _GoogleButton();

  static const _cancelled = {'popup-closed-by-user', 'cancelled-popup-request', 'web-context-canceled', 'canceled'};

  void _onTransition(BuildContext context, AuthState newState) {
    if (newState is! AuthFailed) return;
    final e = newState.exception;
    if (e is FirebaseAuthException && _cancelled.contains(e.code)) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(context.l10n.loginGoogleError)));
  }

  @override
  Widget build(BuildContext context) => AuthFlowBuilder<OAuthController>(
    provider: _google,
    listener: (_, newState, _) => _onTransition(context, newState),
    builder: (context, state, ctrl, _) {
      final busy = state is SigningIn;
      return OutlinedButton(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 44),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        onPressed: busy ? null : () => ctrl.signIn(Theme.of(context).platform),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 18,
              height: 18,
              child: busy
                  ? LoadingAnimationWidget.hexagonDots(color: context.bp.ink, size: 18)
                  : const CustomPaint(painter: GoogleGPainter()),
            ),
            const SizedBox(width: 10),
            Text(context.l10n.loginGoogle),
          ],
        ),
      );
    },
  );
}

class GoogleGPainter extends CustomPainter {
  const GoogleGPainter();

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
  bool shouldRepaint(GoogleGPainter oldDelegate) => false;
}
