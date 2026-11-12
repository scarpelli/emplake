import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n_helpers.dart';
import '../../../core/widgets/bp_widgets.dart';
import '../../../data/firestore_repository.dart';
import '../application/game_controller.dart';
import '../domain/level.dart';

class NewGamePage extends ConsumerStatefulWidget {
  const NewGamePage({super.key, required this.mode, required this.level, this.number, this.exclude});

  final GameMode mode;
  final Level level;
  final String? number;
  final String? exclude;

  @override
  ConsumerState<NewGamePage> createState() => _NewGamePageState();
}

class _Prepared {
  const _Prepared(this.number, this.alreadySolved);
  final String? number;
  final bool alreadySolved;
}

class _NewGamePageState extends ConsumerState<NewGamePage> {
  late Future<_Prepared> _future = _prepare();

  Future<_Prepared> _prepare() async {
    final repo = ref.read(repositoryProvider);
    final typed = widget.number;
    if (typed != null) {
      final solved = await repo?.isSolved(widget.level, typed) ?? false;
      return _Prepared(typed, solved);
    }
    if (repo == null) return _Prepared(FirestoreRepository.pickFrom(const {}, exclude: widget.exclude), false);
    return _Prepared(await repo.pickUnsolved(widget.level, exclude: widget.exclude), false);
  }

  void _launch(_Prepared p) {
    ref.read(gameControllerProvider.notifier).start(
          mode: widget.mode,
          level: widget.level,
          number: p.number!,
          alreadySolved: p.alreadySolved,
        );
    context.go('/game');
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return FutureBuilder<_Prepared>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return BpLoader(label: l.loadingNumber, size: 56);
        }
        if (snap.hasError) {
          return _Message(
            text: l.historyError,
            action: l.retry,
            onAction: () => setState(() => _future = _prepare()),
          );
        }
        final p = snap.data!;
        if (p.number == null) {
          return _Message(text: l.allSolved, action: l.menu, onAction: () => context.go('/play'));
        }
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _launch(p);
        });
        return BpLoader(label: l.loadingNumber, size: 56);
      },
    );
  }
}

class _Message extends StatelessWidget {
  const _Message({required this.text, required this.action, required this.onAction});
  final String text;
  final String action;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(text, textAlign: TextAlign.center, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 16),
              OutlinedButton(onPressed: onAction, child: Text(action)),
            ],
          ),
        ),
      );
}
