import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tod_theme.dart';
import '../data/tod_seed.dart';
import '../providers/tod_providers.dart';
import '../widgets/tod_widgets.dart';

class TodCategoriesScreen extends ConsumerWidget {
  const TodCategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counts = ref.watch(todCategoryCountsProvider);

    return TodScaffold(
      title: 'Categories',
      child: counts.when(
        loading: () => const Center(child: CircularProgressIndicator(color: TodColors.pink)),
        error: (e, _) => Center(child: Text('$e')),
        data: (map) => ListView(
          padding: const EdgeInsets.all(22),
          children: [
            const Text(
              'Built-in packs plus any custom prompts you add.',
              style: TextStyle(color: TodColors.muted),
            ),
            const SizedBox(height: 16),
            for (final c in TodSeed.categories) ...[
              TodCard(
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: TodColors.purple.withValues(alpha: 0.3),
                      child: Text(
                        todCategoryLabel(c)[0],
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            todCategoryLabel(c),
                            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: TodColors.ink),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${map[c] ?? 0} prompts · truths & dares',
                            style: const TextStyle(color: TodColors.muted, fontSize: 13),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
