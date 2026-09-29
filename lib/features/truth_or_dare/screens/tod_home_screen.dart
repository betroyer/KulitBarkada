import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tod_theme.dart';
import '../providers/tod_providers.dart';
import '../widgets/tod_widgets.dart';
import 'tod_categories_screen.dart';
import 'tod_custom_questions_screen.dart';
import 'tod_how_to_play_screen.dart';
import 'tod_mode_select_screen.dart';
import 'tod_settings_screen.dart';

/// Truth or Dare feature home — entry from Kulit Barkada Games hub.
class TodHomeScreen extends ConsumerWidget {
  const TodHomeScreen({super.key, this.prefillNames = const []});

  final List<String> prefillNames;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ready = ref.watch(todReadyProvider);

    return TodScaffold(
      child: ready.when(
        loading: () => const Center(child: CircularProgressIndicator(color: TodColors.pink)),
        error: (e, _) => Center(child: Text('Could not load game: $e', style: const TextStyle(color: TodColors.ink))),
        data: (_) => ListView(
          padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
          children: [
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 88,
                height: 88,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: TodColors.buttonGradient,
                  boxShadow: [
                    BoxShadow(
                      color: TodColors.pink.withValues(alpha: 0.45),
                      blurRadius: 28,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Text('🎭', style: TextStyle(fontSize: 42)),
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Truth or Dare',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: TodColors.ink),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pass the phone. Tell the truth. Take the dare.\nFully offline party mode.',
              textAlign: TextAlign.center,
              style: TextStyle(color: TodColors.muted, height: 1.45),
            ),
            const SizedBox(height: 28),
            TodGradientButton(
              label: 'Play',
              icon: Icons.play_arrow_rounded,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => TodModeSelectScreen(prefillNames: prefillNames),
                  ),
                );
              },
            ),
            const SizedBox(height: 14),
            TodMenuTile(
              icon: Icons.category_rounded,
              title: 'Categories',
              subtitle: 'Browse Classic, Funny, Couples, Party & more',
              accent: TodColors.indigo,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TodCategoriesScreen()),
              ),
            ),
            const SizedBox(height: 12),
            TodMenuTile(
              icon: Icons.edit_note_rounded,
              title: 'Custom Questions',
              subtitle: 'Add your own truths and dares',
              accent: TodColors.pink,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TodCustomQuestionsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            TodMenuTile(
              icon: Icons.settings_rounded,
              title: 'Game Settings',
              subtitle: 'Sound, scoring, rounds, difficulty',
              accent: TodColors.purple,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TodSettingsScreen()),
              ),
            ),
            const SizedBox(height: 12),
            TodMenuTile(
              icon: Icons.help_outline_rounded,
              title: 'How to Play',
              subtitle: 'Quick rules for the barkada',
              accent: TodColors.truth,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const TodHowToPlayScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
