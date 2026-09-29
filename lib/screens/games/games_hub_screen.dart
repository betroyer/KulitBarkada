import 'package:flutter/material.dart';

import '../../data/repositories.dart';
import '../../features/truth_or_dare/screens/tod_home_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/wireframe_ui.dart';
import 'spy_game_screen.dart';

class GamesHubScreen extends StatefulWidget {
  const GamesHubScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<GamesHubScreen> createState() => _GamesHubScreenState();
}

class _GamesHubScreenState extends State<GamesHubScreen> {
  int _memberCount = 0;
  List<String> _memberNames = [];
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
      _memberNames = members.map((m) => m.name).toList();
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const WireframeAppBar(title: 'Games'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: AppColors.heroGradient,
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: AppColors.softShadow,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Party games for the barkada',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20, color: AppColors.ink),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '$_memberCount members ready · fully offline',
                        style: const TextStyle(color: AppColors.muted),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                _GameCard(
                  emoji: '🎭',
                  title: 'Truth or Dare',
                  subtitle: 'Full party mode — categories, scores, custom prompts.',
                  color: AppColors.pink,
                  onTap: () {
                    pushPage(
                      context,
                      TodHomeScreen(prefillNames: _memberNames),
                    );
                  },
                ),
                const SizedBox(height: 14),
                _GameCard(
                  emoji: '🕵️',
                  title: 'Who is the Spy',
                  subtitle: 'One spy doesn’t know the place. Ask questions, then vote.',
                  color: AppColors.accent,
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
        borderRadius: BorderRadius.circular(24),
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: AppColors.softShadow,
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 17, color: AppColors.ink)),
                      const SizedBox(height: 4),
                      Text(subtitle, style: const TextStyle(color: AppColors.muted, height: 1.35, fontSize: 13)),
                    ],
                  ),
                ),
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(color: AppColors.primaryDark, shape: BoxShape.circle),
                  child: const Icon(Icons.arrow_outward, size: 16, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
