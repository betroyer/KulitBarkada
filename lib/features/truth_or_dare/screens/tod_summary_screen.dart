import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tod_theme.dart';
import '../data/tod_models.dart';
import '../providers/tod_providers.dart';
import '../widgets/tod_widgets.dart';
import 'tod_home_screen.dart';
import 'tod_mode_select_screen.dart';
import 'tod_scoreboard_screen.dart';

class TodSummaryScreen extends ConsumerWidget {
  const TodSummaryScreen({super.key, required this.snapshot});

  final TodGameSnapshot snapshot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final roundsPlayed = (snapshot.round - 1).clamp(0, 9999);

    return TodScaffold(
      title: 'Game Over',
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'Nice session!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: TodColors.ink),
          ),
          const SizedBox(height: 8),
          const Text(
            'No forced winners — just vibes and stories.',
            textAlign: TextAlign.center,
            style: TextStyle(color: TodColors.muted),
          ),
          const SizedBox(height: 20),
          TodCard(
            child: Column(
              children: [
                _stat('Rounds played', '$roundsPlayed'),
                _stat('Truths completed', '${snapshot.totalTruths}'),
                _stat('Dares completed', '${snapshot.totalDares}'),
                _stat('Skipped', '${snapshot.totalSkipped}'),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TodOutlineButton(
            label: 'View scoreboard',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TodScoreboardScreen(players: snapshot.players)),
            ),
          ),
          const SizedBox(height: 12),
          TodGradientButton(
            label: 'Play Again',
            icon: Icons.replay_rounded,
            onPressed: () {
              final names = snapshot.players.map((p) => p.name).toList();
              ref.read(todGameProvider.notifier).end();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => TodModeSelectScreen(prefillNames: names)),
                (route) => route.isFirst,
              );
            },
          ),
          const SizedBox(height: 10),
          TodOutlineButton(
            label: 'Return to Home',
            onPressed: () {
              ref.read(todGameProvider.notifier).end();
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const TodHomeScreen()),
                (route) => route.isFirst,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: TodColors.muted))),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: TodColors.ink)),
        ],
      ),
    );
  }
}
