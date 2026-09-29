import 'package:flutter/material.dart';

import '../core/tod_theme.dart';
import '../widgets/tod_widgets.dart';

class TodHowToPlayScreen extends StatelessWidget {
  const TodHowToPlayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const steps = [
      ('1', 'Add 2–20 players and pick a game mode.'),
      ('2', 'The first player is chosen at random.'),
      ('3', 'Choose Truth or Dare — or let Random Mode decide.'),
      ('4', 'Read the challenge aloud, then Complete or Skip.'),
      ('5', 'Pass the phone. Turns never repeat the same person twice in a row.'),
      ('6', 'Optional scoring: Truth +1, Dare +2. End anytime for a fun summary.'),
    ];

    return TodScaffold(
      title: 'How to Play',
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const TodCard(
            child: Text(
              'One phone. Whole group. Keep it kind, consensual, and offline.',
              style: TextStyle(color: TodColors.ink, height: 1.45, fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(height: 16),
          for (final s in steps) ...[
            TodCard(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    backgroundColor: TodColors.purple.withValues(alpha: 0.35),
                    child: Text(s.$1, style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(s.$2, style: const TextStyle(color: TodColors.ink, height: 1.4)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
