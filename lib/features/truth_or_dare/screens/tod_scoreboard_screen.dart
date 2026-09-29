import 'package:flutter/material.dart';

import '../core/tod_theme.dart';
import '../data/tod_models.dart';
import '../widgets/tod_widgets.dart';

class TodScoreboardScreen extends StatelessWidget {
  const TodScoreboardScreen({super.key, required this.players});

  final List<TodPlayer> players;

  @override
  Widget build(BuildContext context) {
    final ranked = [...players]..sort((a, b) => b.points.compareTo(a.points));

    return TodScaffold(
      title: 'Scoreboard',
      child: ListView.separated(
        padding: const EdgeInsets.all(22),
        itemCount: ranked.length,
        separatorBuilder: (_, _) => const SizedBox(height: 10),
        itemBuilder: (context, i) {
          final p = ranked[i];
          return TodCard(
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: TodColors.purple.withValues(alpha: 0.35),
                  child: Text('${i + 1}', style: const TextStyle(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(width: 12),
                TodPlayerAvatar(name: p.name, size: 44),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800, color: TodColors.ink)),
                      const SizedBox(height: 4),
                      Text(
                        'T ${p.truthsCompleted} · D ${p.daresCompleted} · Skip ${p.skipped}',
                        style: const TextStyle(color: TodColors.muted, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${p.points}',
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: TodColors.pink),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
