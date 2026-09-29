import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/tod_theme.dart';
import '../data/tod_models.dart';
import '../providers/tod_providers.dart';
import '../widgets/tod_widgets.dart';
import 'tod_scoreboard_screen.dart';
import 'tod_summary_screen.dart';

class TodGameplayScreen extends ConsumerStatefulWidget {
  const TodGameplayScreen({super.key});

  @override
  ConsumerState<TodGameplayScreen> createState() => _TodGameplayScreenState();
}

class _TodGameplayScreenState extends ConsumerState<TodGameplayScreen>
    with SingleTickerProviderStateMixin {
  late final ConfettiController _confetti;
  late final AnimationController _pulse;
  bool _revealing = false;

  @override
  void initState() {
    super.initState();
    _confetti = ConfettiController(duration: const Duration(seconds: 1));
    _pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _confetti.dispose();
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _pick(TodPromptType type) async {
    final settings = ref.read(todSettingsProvider);
    await todClick(settings.soundEnabled);
    await todHaptic(settings.vibrationEnabled);
    setState(() => _revealing = true);
    await ref.read(todGameProvider.notifier).chooseType(type);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (mounted) setState(() => _revealing = false);
  }

  Future<void> _randomAssign() async {
    final settings = ref.read(todSettingsProvider);
    await todClick(settings.soundEnabled);
    await ref.read(todGameProvider.notifier).assignRandomType();
    setState(() => _revealing = true);
    await Future<void>.delayed(const Duration(milliseconds: 280));
    if (mounted) setState(() => _revealing = false);
  }

  Future<void> _complete() async {
    final settings = ref.read(todSettingsProvider);
    await todHaptic(settings.vibrationEnabled);
    _confetti.play();
    ref.read(todGameProvider.notifier).complete();
    await _afterTurn();
  }

  Future<void> _skip() async {
    ref.read(todGameProvider.notifier).skip();
    await _afterTurn();
  }

  Future<void> _afterTurn() async {
    final game = ref.read(todGameProvider.notifier);
    if (game.shouldEnd) {
      await _finish();
    }
  }

  Future<void> _finish() async {
    await ref.read(todGameProvider.notifier).persistHistory();
    if (!mounted) return;
    final snap = ref.read(todGameProvider);
    if (snap == null) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => TodSummaryScreen(snapshot: snap)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final snap = ref.watch(todGameProvider);
    final settings = ref.watch(todSettingsProvider);
    final mode = ref.read(todGameProvider.notifier).config?.mode ?? TodGameMode.classic;

    if (snap == null) {
      return TodScaffold(
        title: 'Game',
        child: Center(
          child: TodGradientButton(
            label: 'Back',
            onPressed: () => Navigator.pop(context),
          ),
        ),
      );
    }

    final player = snap.currentPlayer;

    return TodScaffold(
      title: 'Round ${snap.round}',
      actions: [
        if (settings.scoringEnabled)
          IconButton(
            icon: const Icon(Icons.leaderboard_rounded),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => TodScoreboardScreen(players: snap.players)),
            ),
          ),
        TextButton(
          onPressed: _finish,
          child: const Text('End', style: TextStyle(color: TodColors.pink, fontWeight: FontWeight.w800)),
        ),
      ],
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.fromLTRB(22, 8, 22, 28),
            children: [
              TodCard(
                child: Column(
                  children: [
                    const Text('NOW PLAYING', style: TextStyle(letterSpacing: 1.2, color: TodColors.muted, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    ScaleTransition(
                      scale: Tween(begin: 0.96, end: 1.04).animate(
                        CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
                      ),
                      child: TodPlayerAvatar(name: player.name, size: 72, highlight: true),
                    ),
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 250),
                      child: Text(
                        player.name,
                        key: ValueKey(player.id),
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: TodColors.ink),
                      ),
                    ),
                    if (settings.scoringEnabled) ...[
                      const SizedBox(height: 6),
                      Text('${player.points} pts', style: const TextStyle(color: TodColors.pink, fontWeight: FontWeight.w700)),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (snap.waitingChoice) ...[
                if (mode == TodGameMode.random)
                  TodGradientButton(
                    label: 'Reveal Truth or Dare',
                    icon: Icons.casino_rounded,
                    onPressed: _randomAssign,
                  )
                else
                  Row(
                    children: [
                      Expanded(
                        child: _ChoiceButton(
                          label: 'TRUTH',
                          color: TodColors.truth,
                          onTap: () => _pick(TodPromptType.truth),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _ChoiceButton(
                          label: 'DARE',
                          color: TodColors.dare,
                          onTap: () => _pick(TodPromptType.dare),
                        ),
                      ),
                    ],
                  ),
              ] else ...[
                AnimatedOpacity(
                  opacity: _revealing ? 0.3 : 1,
                  duration: const Duration(milliseconds: 220),
                  child: AnimatedScale(
                    scale: _revealing ? 0.94 : 1,
                    duration: const Duration(milliseconds: 280),
                    curve: Curves.easeOutBack,
                    child: TodCard(
                      color: (snap.currentType == TodPromptType.truth ? TodColors.truth : TodColors.dare)
                          .withValues(alpha: 0.12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            snap.currentType == TodPromptType.truth ? 'TRUTH' : 'DARE',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.4,
                              color: snap.currentType == TodPromptType.truth ? TodColors.truth : TodColors.dare,
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            snap.currentPrompt?.text ?? 'No prompts available for these filters.',
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              height: 1.35,
                              color: TodColors.ink,
                            ),
                          ),
                          if (snap.currentPrompt != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Text(
                                  todCategoryLabel(snap.currentPrompt!.category),
                                  style: const TextStyle(color: TodColors.muted, fontSize: 12),
                                ),
                                const Spacer(),
                                IconButton(
                                  tooltip: 'Favorite',
                                  onPressed: () async {
                                    final p = snap.currentPrompt!;
                                    final next = !p.isFavorite;
                                    await ref.read(todRepositoryProvider).setFavorite(p.id, next);
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(next ? 'Saved to favorites' : 'Removed from favorites'),
                                      ),
                                    );
                                  },
                                  icon: Icon(
                                    snap.currentPrompt!.isFavorite ? Icons.favorite : Icons.favorite_border,
                                    color: TodColors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TodGradientButton(
                  label: 'Completed',
                  icon: Icons.check_circle_outline,
                  onPressed: _complete,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TodOutlineButton(label: 'Skip', onPressed: _skip, color: TodColors.muted),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TodOutlineButton(
                        label: 'Randomize Again',
                        onPressed: () async {
                          setState(() => _revealing = true);
                          await ref.read(todGameProvider.notifier).randomizeAgain();
                          if (mounted) setState(() => _revealing = false);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confetti,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [TodColors.pink, TodColors.purple, TodColors.truth, Colors.white],
            ),
          ),
        ],
      ),
    );
  }
}

class _ChoiceButton extends StatefulWidget {
  const _ChoiceButton({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  State<_ChoiceButton> createState() => _ChoiceButtonState();
}

class _ChoiceButtonState extends State<_ChoiceButton> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) {
        setState(() => _scale = 1);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [widget.color, widget.color.withValues(alpha: 0.65)],
            ),
            boxShadow: [
              BoxShadow(color: widget.color.withValues(alpha: 0.4), blurRadius: 18, offset: const Offset(0, 8)),
            ],
          ),
          child: Text(
            widget.label,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 1),
          ),
        ),
      ),
    );
  }
}
