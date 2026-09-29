import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tod_theme.dart';
import '../data/tod_models.dart';
import '../data/tod_seed.dart';
import '../providers/tod_providers.dart';
import '../widgets/tod_widgets.dart';

class TodCustomQuestionsScreen extends ConsumerStatefulWidget {
  const TodCustomQuestionsScreen({super.key});

  @override
  ConsumerState<TodCustomQuestionsScreen> createState() => _TodCustomQuestionsScreenState();
}

class _TodCustomQuestionsScreenState extends ConsumerState<TodCustomQuestionsScreen> {
  Future<void> _showEditor({TodPrompt? existing}) async {
    final textCtrl = TextEditingController(text: existing?.text ?? '');
    var category = existing?.category ?? 'classic';
    var type = existing?.type ?? TodPromptType.truth;
    var difficulty = existing?.difficulty ?? TodDifficulty.medium;

    final saved = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: TodColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModal) {
            return Padding(
              padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + MediaQuery.of(ctx).viewInsets.bottom),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    existing == null ? 'New custom prompt' : 'Edit prompt',
                    style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: TodColors.ink),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Write your truth or dare…'),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: category,
                    decoration: const InputDecoration(labelText: 'Category'),
                    items: TodSeed.categories
                        .map((c) => DropdownMenuItem(value: c, child: Text(todCategoryLabel(c))))
                        .toList(),
                    onChanged: (v) => setModal(() => category = v ?? category),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TodPromptType>(
                    initialValue: type,
                    decoration: const InputDecoration(labelText: 'Type'),
                    items: const [
                      DropdownMenuItem(value: TodPromptType.truth, child: Text('Truth')),
                      DropdownMenuItem(value: TodPromptType.dare, child: Text('Dare')),
                    ],
                    onChanged: (v) => setModal(() => type = v ?? type),
                  ),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<TodDifficulty>(
                    initialValue: difficulty,
                    decoration: const InputDecoration(labelText: 'Difficulty'),
                    items: TodDifficulty.values
                        .map((d) => DropdownMenuItem(value: d, child: Text(d.name)))
                        .toList(),
                    onChanged: (v) => setModal(() => difficulty = v ?? difficulty),
                  ),
                  const SizedBox(height: 16),
                  TodGradientButton(
                    label: 'Save',
                    onPressed: () {
                      if (textCtrl.text.trim().isEmpty) return;
                      Navigator.pop(ctx, true);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (saved != true) return;
    final repo = ref.read(todRepositoryProvider);
    if (existing == null) {
      await repo.insertCustom(
        category: category,
        type: type,
        text: textCtrl.text,
        difficulty: difficulty,
      );
    } else {
      await repo.updatePrompt(
        existing.copyWith(
          text: textCtrl.text,
          category: category,
          type: type,
          difficulty: difficulty,
        ),
      );
    }
    ref.invalidate(todCustomPromptsProvider);
    ref.invalidate(todCategoryCountsProvider);
  }

  @override
  Widget build(BuildContext context) {
    final prompts = ref.watch(todCustomPromptsProvider);

    return TodScaffold(
      title: 'Custom Questions',
      floatingActionButton: FloatingActionButton(
        backgroundColor: TodColors.pink,
        onPressed: () => _showEditor(),
        child: const Icon(Icons.add),
      ),
      child: prompts.when(
        loading: () => const Center(child: CircularProgressIndicator(color: TodColors.pink)),
        error: (e, _) => Center(child: Text('$e')),
        data: (list) {
          if (list.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'No custom prompts yet.\nTap + to create truths and dares.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: TodColors.muted, height: 1.4),
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 88),
            itemCount: list.length,
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, i) {
              final p = list[i];
              return TodCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          p.type == TodPromptType.truth ? 'TRUTH' : 'DARE',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: p.type == TodPromptType.truth ? TodColors.truth : TodColors.dare,
                          ),
                        ),
                        const Spacer(),
                        IconButton(
                          icon: Icon(
                            p.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: TodColors.pink,
                          ),
                          onPressed: () async {
                            await ref.read(todRepositoryProvider).setFavorite(p.id, !p.isFavorite);
                            ref.invalidate(todCustomPromptsProvider);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit_outlined, color: TodColors.muted),
                          onPressed: () => _showEditor(existing: p),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, color: TodColors.dare),
                          onPressed: () async {
                            await ref.read(todRepositoryProvider).deletePrompt(p.id);
                            ref.invalidate(todCustomPromptsProvider);
                            ref.invalidate(todCategoryCountsProvider);
                          },
                        ),
                      ],
                    ),
                    Text(p.text, style: const TextStyle(color: TodColors.ink, fontSize: 16, height: 1.35)),
                    const SizedBox(height: 8),
                    Text(
                      '${todCategoryLabel(p.category)} · ${p.difficulty.name}',
                      style: const TextStyle(color: TodColors.muted, fontSize: 12),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
