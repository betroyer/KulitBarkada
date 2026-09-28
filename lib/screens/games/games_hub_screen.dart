import 'package:flutter/material.dart';

import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/wireframe_ui.dart';
import 'spy_game_screen.dart';
import 'truth_dare_screen.dart';

class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  int _memberCount = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final members = await MemberRepository().list(widget.groupId);
    if (!mounted) return;
    setState(() {
      _memberCount = members.length;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WireframeAppBar(title: 'Games'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                const Text(
                  'Party games for the barkada — fully offline.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_memberCount members ready',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),
                _GameCard(
                  emoji: '🎭',
                  title: 'Truth or Dare',
                  subtitle: 'Spin a member, pick Truth or Dare, keep the vibe going.',
                  color: AppColors.decide,
                  onTap: () {
                    if (_memberCount < 2) {
                      showSnack(context, 'Add at least 2 members first.', error: true);
                      return;
                    }
                    pushPage(context, TruthDareScreen(groupId: widget.groupId));
                  },
                ),
                const SizedBox(height: 14),
                _GameCard(
                  emoji: '🕵️',
                  title: 'Who is the Spy',
                  subtitle: 'One spy doesn’t know the place. Ask questions, then vote.',
                  color: AppColors.activities,
                  onTap: () {
                    if (_memberCount < 3) {
                      showSnack(context, 'Need at least 3 members for Who is the Spy.', error: true);
                      return;
                    }
                    pushPage(context, SpyGameScreen(groupId: widget.groupId));
                  },
                ),
              ],
            ),
    );
  }
}

class _GameCard extends StatelessWidget {
  const _GameCard({
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.ink, width: 2),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      const SizedBox(height: 6),
                      Text(subtitle, style: const TextStyle(color: AppColors.muted, height: 1.35)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
