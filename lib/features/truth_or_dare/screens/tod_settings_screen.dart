import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tod_theme.dart';
import '../data/tod_models.dart';
import '../providers/tod_providers.dart';
import '../widgets/tod_widgets.dart';

class TodSettingsScreen extends ConsumerWidget {
  const TodSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(todSettingsProvider);
    final notifier = ref.read(todSettingsProvider.notifier);

    return TodScaffold(
      title: 'Game Settings',
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          TodCard(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Sound effects', style: TextStyle(color: TodColors.ink)),
                  value: settings.soundEnabled,
                  activeThumbColor: TodColors.pink,
                  onChanged: (v) => notifier.update(settings.copyWith(soundEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Background music', style: TextStyle(color: TodColors.ink)),
                  subtitle: const Text('Optional — no track bundled; toggle for future packs', style: TextStyle(color: TodColors.muted, fontSize: 12)),
                  value: settings.musicEnabled,
                  activeThumbColor: TodColors.pink,
                  onChanged: (v) => notifier.update(settings.copyWith(musicEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Vibration', style: TextStyle(color: TodColors.ink)),
                  value: settings.vibrationEnabled,
                  activeThumbColor: TodColors.pink,
                  onChanged: (v) => notifier.update(settings.copyWith(vibrationEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Scoring', style: TextStyle(color: TodColors.ink)),
                  subtitle: const Text('Truth +1 · Dare +2', style: TextStyle(color: TodColors.muted, fontSize: 12)),
                  value: settings.scoringEnabled,
                  activeThumbColor: TodColors.pink,
                  onChanged: (v) => notifier.update(settings.copyWith(scoringEnabled: v)),
                ),
                SwitchListTile(
                  title: const Text('Allow question repetition', style: TextStyle(color: TodColors.ink)),
                  value: settings.allowRepetition,
                  activeThumbColor: TodColors.pink,
                  onChanged: (v) => notifier.update(settings.copyWith(allowRepetition: v)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TodCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Max rounds', style: TextStyle(fontWeight: FontWeight.w800, color: TodColors.ink)),
                const SizedBox(height: 4),
                Text(
                  settings.maxRounds == 0 ? 'Unlimited' : '${settings.maxRounds} rounds',
                  style: const TextStyle(color: TodColors.muted),
                ),
                Slider(
                  value: settings.maxRounds.toDouble(),
                  min: 0,
                  max: 40,
                  divisions: 40,
                  activeColor: TodColors.pink,
                  label: settings.maxRounds == 0 ? '∞' : '${settings.maxRounds}',
                  onChanged: (v) => notifier.update(settings.copyWith(maxRounds: v.round())),
                ),
                const SizedBox(height: 8),
                const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.w800, color: TodColors.ink)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: TodDifficulty.values.map((d) {
                    final on = settings.difficulty == d;
                    return ChoiceChip(
                      label: Text(d.name),
                      selected: on,
                      selectedColor: TodColors.purple,
                      labelStyle: TextStyle(color: on ? Colors.white : TodColors.ink),
                      onSelected: (_) => notifier.update(settings.copyWith(difficulty: d)),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          TodOutlineButton(
            label: 'Reset used prompts (this session)',
            onPressed: () {
              ref.read(todGameProvider.notifier).resetUsedPrompts();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Used prompts cleared for the current game.')),
              );
            },
          ),
          const SizedBox(height: 10),
          TodOutlineButton(
            label: 'Reset game progress / history',
            color: TodColors.dare,
            onPressed: () async {
              await notifier.resetProgress();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Game history cleared.')),
              );
            },
          ),
        ],
      ),
    );
  }
}
