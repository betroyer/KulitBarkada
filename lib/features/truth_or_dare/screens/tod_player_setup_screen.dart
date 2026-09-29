import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tod_theme.dart';
import '../data/tod_models.dart';
import '../providers/tod_providers.dart';
import '../widgets/tod_widgets.dart';
import 'tod_gameplay_screen.dart';

class TodPlayerSetupScreen extends ConsumerStatefulWidget {
  const TodPlayerSetupScreen({
    super.key,
    required this.mode,
    required this.categories,
    this.prefillNames = const [],
  });

  final TodGameMode mode;
  final Set<String> categories;
  final List<String> prefillNames;

  @override
  ConsumerState<TodPlayerSetupScreen> createState() => _TodPlayerSetupScreenState();
}

class _TodPlayerSetupScreenState extends ConsumerState<TodPlayerSetupScreen> {
  final _controller = TextEditingController();
  final _players = <TodPlayer>[];
  final _random = Random();
  bool _spinning = false;
  String? _spotlight;

  @override
  void initState() {
    super.initState();
    for (final name in widget.prefillNames) {
      if (name.trim().isEmpty) continue;
      _players.add(TodPlayer(id: UniqueKey().toString(), name: name.trim()));
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _add() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    if (_players.length >= 20) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 20 players.')),
      );
      return;
    }
    setState(() {
      _players.add(TodPlayer(id: UniqueKey().toString(), name: name));
      _controller.clear();
    });
    todClick(ref.read(todSettingsProvider).soundEnabled);
  }

  Future<void> _edit(TodPlayer player) async {
    final c = TextEditingController(text: player.name);
    final next = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: TodColors.surface,
        title: const Text('Edit name'),
        content: TextField(controller: c, autofocus: true),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, c.text.trim()), child: const Text('Save')),
        ],
      ),
    );
    if (next == null || next.isEmpty) return;
    setState(() => player.name = next);
  }

  Future<void> _start() async {
    if (_players.length < 2) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least 2 players.')),
      );
      return;
    }

    setState(() => _spinning = true);
    final settings = ref.read(todSettingsProvider);
    for (var i = 0; i < 14; i++) {
      await Future<void>.delayed(Duration(milliseconds: 50 + i * 10));
      if (!mounted) return;
      setState(() => _spotlight = _players[_random.nextInt(_players.length)].name);
      if (settings.vibrationEnabled) todHaptic(true);
    }

    final config = TodSessionConfig(
      mode: widget.mode,
      players: _players.map((p) => p.copy()).toList(),
      categories: widget.categories,
      difficulty: settings.difficulty,
    );
    ref.read(todGameProvider.notifier).start(config);
    if (settings.vibrationEnabled) todHaptic(true);
    if (!mounted) return;
    setState(() => _spinning = false);
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const TodGameplayScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TodScaffold(
      title: 'Players',
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(22),
              children: [
                Text(
                  todModeLabel(widget.mode.name),
                  style: const TextStyle(color: TodColors.pink, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 6),
                Text(
                  'Add 2–20 players · ${_players.length} ready',
                  style: const TextStyle(color: TodColors.muted),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        textInputAction: TextInputAction.done,
                        onSubmitted: (_) => _add(),
                        decoration: const InputDecoration(hintText: 'Player name'),
                      ),
                    ),
                    const SizedBox(width: 10),
                    IconButton.filled(
                      onPressed: _add,
                      style: IconButton.styleFrom(backgroundColor: TodColors.purple),
                      icon: const Icon(Icons.add),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                if (_spinning && _spotlight != null)
                  TodCard(
                    color: TodColors.purple.withValues(alpha: 0.35),
                    child: Column(
                      children: [
                        const Text('Selecting first player…', style: TextStyle(color: TodColors.muted)),
                        const SizedBox(height: 8),
                        Text(
                          _spotlight!,
                          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: TodColors.ink),
                        ),
                      ],
                    ),
                  ),
                if (_players.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 40),
                    child: Text(
                      'No players yet. Add friends to begin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: TodColors.muted),
                    ),
                  )
                else
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _players.map((p) {
                      return TodCard(
                        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TodPlayerAvatar(name: p.name, size: 40),
                            const SizedBox(width: 10),
                            ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: Text(
                                p.name,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(fontWeight: FontWeight.w700, color: TodColors.ink),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.edit_outlined, size: 18, color: TodColors.muted),
                              onPressed: () => _edit(p),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, size: 18, color: TodColors.pink),
                              onPressed: () => setState(() => _players.remove(p)),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 0, 22, 22),
            child: TodGradientButton(
              label: _spinning ? 'Spinning…' : 'Start Game',
              icon: Icons.play_arrow_rounded,
              onPressed: _spinning ? null : _start,
            ),
          ),
        ],
      ),
    );
  }
}
