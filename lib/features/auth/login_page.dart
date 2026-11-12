import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:firebase_ui_oauth_google/firebase_ui_oauth_google.dart';
import 'package:flutter/material.dart';

import '../../core/firebase_config.dart';
import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';

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
          providers: [
            EmailAuthProvider(),
            GoogleProvider(clientId: googleWebClientId),
          ],
          showPasswordVisibilityToggle: true,
          breakpoint: 900,
          maxWidth: 440,
          headerMaxExtent: 210,
          headerBuilder: (context, constraints, shrinkOffset) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Align(alignment: Alignment.topRight, child: LanguagePicker()),
                const Spacer(),
                Text('EMPLAKE', style: t.headlineMedium?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 4)),
                const SizedBox(height: 6),
                Text(l.loginSubtitle, style: t.bodyMedium?.copyWith(color: context.bp.muted)),
              ],
            ),
          ),
          sideBuilder: (context, constraints) => Padding(
            padding: const EdgeInsets.all(40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const LanguagePicker(showNames: true),
                const SizedBox(height: 40),
                Text('EMPLAKE', style: t.displaySmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 6)),
                const SizedBox(height: 8),
                Text(l.loginSubtitle, style: t.titleMedium?.copyWith(color: context.bp.muted)),
                const SizedBox(height: 40),
                const _TeamCard(),
              ],
            ),
          ),
          footerBuilder: (context, action) {
            final wide = MediaQuery.sizeOf(context).width >= 900;
            return wide ? const SizedBox.shrink() : const Padding(
              padding: EdgeInsets.only(top: 24),
              child: _TeamCard(),
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
              decoration: BoxDecoration(border: Border(bottom: BorderSide(color: bp.lineSoft))),
              child: Row(
                children: [
                  SizedBox(width: 120, child: Eyebrow(l.loginMember(i + 1), opacity: 0.6)),
                  Expanded(child: Text(teamMembers[i], style: t.bodyMedium?.copyWith(fontWeight: FontWeight.w600))),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Text(l.loginCredit, style: t.bodySmall?.copyWith(color: bp.muted, fontStyle: FontStyle.italic)),
          ),
        ],
      ),
    );
  }
}
