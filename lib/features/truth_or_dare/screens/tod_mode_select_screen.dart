import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tod_theme.dart';
import '../data/tod_models.dart';
import '../data/tod_seed.dart';
import '../widgets/tod_widgets.dart';
import 'tod_player_setup_screen.dart';

class TodModeSelectScreen extends ConsumerWidget {
  const TodModeSelectScreen({super.key, this.prefillNames = const []});

  final List<String> prefillNames;

  void _open(BuildContext context, TodGameMode mode, Set<String> categories) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TodPlayerSetupScreen(
          mode: mode,
          categories: categories,
          prefillNames: prefillNames,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TodScaffold(
      title: 'Game Mode',
      child: ListView(
        padding: const EdgeInsets.all(22),
        children: [
          const Text(
            'Pick how you want to play',
            style: TextStyle(color: TodColors.muted),
          ),
          const SizedBox(height: 16),
          TodMenuTile(
            icon: Icons.casino_rounded,
            title: 'Classic Mode',
            subtitle: 'Players choose Truth or Dare each turn',
            onTap: () => _open(context, TodGameMode.classic, TodSeed.categories.toSet()),
          ),
          const SizedBox(height: 12),
          TodMenuTile(
            icon: Icons.shuffle_rounded,
            title: 'Random Mode',
            subtitle: 'The game assigns Truth or Dare for you',
            accent: TodColors.indigo,
            onTap: () => _open(context, TodGameMode.random, TodSeed.categories.toSet()),
          ),
          const SizedBox(height: 12),
          TodMenuTile(
            icon: Icons.favorite_rounded,
            title: 'Couples Mode',
            subtitle: 'Romantic & getting-to-know-you prompts',
            accent: TodColors.pink,
            onTap: () => _open(context, TodGameMode.couples, {'couples'}),
          ),
          const SizedBox(height: 12),
          TodMenuTile(
            icon: Icons.celebration_rounded,
            title: 'Party Mode',
            subtitle: 'Funny, loud, group-friendly energy',
            accent: TodColors.dare,
            onTap: () => _open(context, TodGameMode.party, {'party', 'funny'}),
          ),
          const SizedBox(height: 12),
          TodMenuTile(
            icon: Icons.tune_rounded,
            title: 'Custom Mode',
            subtitle: 'Choose categories before you start',
            accent: TodColors.truth,
            onTap: () async {
              final selected = await showModalBottomSheet<Set<String>>(
                context: context,
                backgroundColor: TodColors.surface,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                ),
                builder: (ctx) => const _CategoryPickerSheet(),
              );
              if (selected == null || selected.isEmpty || !context.mounted) return;
              _open(context, TodGameMode.custom, selected);
            },
          ),
        ],
      ),
    );
  }
}

class _CategoryPickerSheet extends StatefulWidget {
  const _CategoryPickerSheet();

  @override
  State<_CategoryPickerSheet> createState() => _CategoryPickerSheetState();
}

class _CategoryPickerSheetState extends State<_CategoryPickerSheet> {
  final _selected = <String>{'classic', 'funny'};

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Select categories', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: TodColors.ink)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: TodSeed.categories.map((c) {
              final on = _selected.contains(c);
              return FilterChip(
                selected: on,
                label: Text(todCategoryLabel(c)),
                onSelected: (v) => setState(() => v ? _selected.add(c) : _selected.remove(c)),
                selectedColor: TodColors.purple,
                checkmarkColor: Colors.white,
                labelStyle: TextStyle(color: on ? Colors.white : TodColors.ink),
              );
            }).toList(),
          ),
          const SizedBox(height: 18),
          TodGradientButton(
            label: 'Continue',
            onPressed: _selected.isEmpty ? null : () => Navigator.pop(context, Set<String>.from(_selected)),
          ),
        ],
      ),
    );
  }
}
