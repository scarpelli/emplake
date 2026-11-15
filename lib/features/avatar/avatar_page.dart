import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/l10n_helpers.dart';
import '../../core/theme/blueprint.dart';
import '../../core/widgets/bp_widgets.dart';
import '../../data/firestore_repository.dart';
import '../../l10n/app_localizations.dart';
import 'robot_avatar.dart';

/// The player's robot: the one they saved, or one drawn from their uid until then.
final playerAvatarProvider = Provider<RobotAvatar>((ref) {
  final saved = ref.watch(profileProvider).value?.avatar;
  if (saved != null) return saved;
  return RobotAvatar.fromSeed(ref.watch(authStateProvider).value?.uid ?? '');
});

extension RobotPartL10n on RobotPart {
  String label(AppLocalizations l) => switch (this) {
    RobotPart.head => l.avatarGroupHead,
    RobotPart.top => l.avatarGroupTop,
    RobotPart.eyes => l.avatarGroupEyes,
    RobotPart.mouth => l.avatarGroupMouth,
    RobotPart.side => l.avatarGroupSide,
    RobotPart.acc => l.avatarGroupAcc,
  };

  String optionName(AppLocalizations l, String v) => switch (this) {
    RobotPart.head => l.avatarHead(v),
    RobotPart.top => l.avatarTop(v),
    RobotPart.eyes => l.avatarEyes(v),
    RobotPart.mouth => l.avatarMouth(v),
    RobotPart.side => l.avatarSide(v),
    RobotPart.acc => l.avatarAcc(v),
  };
}

/// Settings › Player › avatar: build the robot part by part. Every thumbnail
/// shows the current robot with that option applied.
class AvatarPage extends ConsumerStatefulWidget {
  const AvatarPage({super.key});

  @override
  ConsumerState<AvatarPage> createState() => _AvatarPageState();
}

class _AvatarPageState extends ConsumerState<AvatarPage> {
  RobotAvatar? _draft;
  bool _saving = false;
  bool _justSaved = false;

  void _pick(RobotAvatar a) => setState(() {
    _draft = a;
    _justSaved = false;
  });

  Future<void> _save(RobotAvatar a) async {
    final repo = ref.read(repositoryProvider);
    if (repo == null) return;
    setState(() => _saving = true);
    try {
      await repo.saveAvatar(a);
      ref.invalidate(profileProvider);
      if (mounted) setState(() => _justSaved = true);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text(context.l10n.avatarSaveError)));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/settings');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final RobotAvatar avatar = _draft ?? ref.watch(playerAvatarProvider);

    return ContentWidth(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
            child: PageTitle(
              leading: BoxIconButton(icon: Icons.arrow_back, tooltip: l.back, onPressed: _back),
              eyebrow: '${l.settingsTitle} › ${l.settingsGroupPlayer}'.toUpperCase(),
              title: l.avatarTitle,
            ),
          ),
          const SizedBox(height: 16),
          Center(child: _Preview(avatar)),
          const SizedBox(height: 6),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 4),
              children: [
                for (final part in RobotPart.values) _PartRow(part: part, avatar: avatar, onPick: _pick),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            child: Row(
              children: [
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(RobotAvatar.random(math.Random())),
                    style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(horizontal: 14)),
                    icon: const Icon(Icons.casino_outlined, size: 20),
                    label: Text(l.avatarShuffle, style: const TextStyle(letterSpacing: 2)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: _saving ? null : () => _save(avatar),
                      icon: _saving
                          ? const BpLoader(size: 18)
                          : Icon(_justSaved ? Icons.check : Icons.save_outlined, size: 20),
                      label: Text(
                        _justSaved ? l.avatarSaved : l.avatarSave,
                        style: const TextStyle(letterSpacing: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Large preview with a blueprint dimension line ("Ø 48") above it.
class _Preview extends StatelessWidget {
  const _Preview(this.avatar);
  final RobotAvatar avatar;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    return SizedBox(
      width: 220,
      height: 196,
      child: Stack(
        children: [
          Positioned(
            left: 24,
            right: 24,
            top: 0,
            height: 10,
            child: Container(
              decoration: BoxDecoration(
                border: Border.symmetric(vertical: BorderSide(color: bp.ink.withValues(alpha: 0.7))),
              ),
              child: Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    left: 0,
                    right: 0,
                    top: 5,
                    child: Container(height: 1, color: bp.ink.withValues(alpha: 0.55)),
                  ),
                  Positioned(
                    top: -2,
                    child: ExcludeSemantics(
                      child: ColoredBox(
                        color: bp.paper,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Text('Ø 48', style: t.labelSmall?.copyWith(color: bp.ink, height: 1.1)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 24,
            top: 20,
            child: RobotAvatarView(avatar, size: 172, semanticLabel: context.l10n.avatarPreview),
          ),
        ],
      ),
    );
  }
}

/// One group of parts: its name, the chosen option's name, and a sideways
/// strip of thumbnails with a thin scrollbar under it.
class _PartRow extends StatefulWidget {
  const _PartRow({required this.part, required this.avatar, required this.onPick});

  final RobotPart part;
  final RobotAvatar avatar;
  final ValueChanged<RobotAvatar> onPick;

  @override
  State<_PartRow> createState() => _PartRowState();
}

class _PartRowState extends State<_PartRow> {
  final _scroll = ScrollController();

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final bp = context.bp;
    final t = Theme.of(context).textTheme;
    final part = widget.part;
    final current = widget.avatar[part];
    final label = part.label(l);
    final labelStyle = t.labelSmall?.copyWith(letterSpacing: 1, color: bp.ink);

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 7),
            child: Row(
              children: [
                Text(label, style: labelStyle?.copyWith(fontWeight: FontWeight.w600)),
                const Spacer(),
                Text(part.optionName(l, current), style: labelStyle?.copyWith(color: bp.muted)),
              ],
            ),
          ),
          SizedBox(
            height: 70,
            child: RawScrollbar(
              controller: _scroll,
              thumbVisibility: true,
              trackVisibility: true,
              thickness: 3,
              radius: const Radius.circular(2),
              trackRadius: const Radius.circular(2),
              thumbColor: bp.ink.withValues(alpha: 0.38),
              trackColor: bp.ink.withValues(alpha: 0.08),
              trackBorderColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ListView.separated(
                controller: _scroll,
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 10),
                itemCount: robotOptions[part]!.length,
                separatorBuilder: (_, _) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final value = robotOptions[part]![i];
                  return _Chip(
                    avatar: widget.avatar.withPart(part, value),
                    selected: value == current,
                    label: '${label.toLowerCase()}: ${part.optionName(l, value)}',
                    onTap: () => widget.onPick(widget.avatar.withPart(part, value)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.avatar, required this.selected, required this.label, required this.onTap});

  final RobotAvatar avatar;
  final bool selected;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bp = context.bp;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          width: 52,
          height: 52,
          // Selected: a light ring separated from the thumbnail by a paper gap.
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: selected
                ? [BoxShadow(color: bp.ink, spreadRadius: 4), BoxShadow(color: bp.paper, spreadRadius: 2)]
                : const [],
          ),
          child: Opacity(opacity: selected ? 1 : 0.82, child: RobotAvatarView(avatar, size: 52)),
        ),
      ),
    );
  }
}
