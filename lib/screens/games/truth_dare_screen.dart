import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../data/game_content.dart';
import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import '../../widgets/wireframe_ui.dart';

class TruthDareScreen extends StatefulWidget {
  const TruthDareScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<TruthDareScreen> createState() => _TruthDareScreenState();
}

class _TruthDareScreenState extends State<TruthDareScreen> {
  final _random = Random();
  List<GroupMember> _members = [];
  bool _loading = true;
  bool _picking = false;
  GroupMember? _current;
  String? _mode;
  String? _prompt;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final members = await MemberRepository().list(widget.groupId);
    if (!mounted) return;
    setState(() {
      _members = members;
      _loading = false;
    });
  }

  Future<void> _pickPlayer() async {
    if (_members.isEmpty || _picking) return;
    setState(() {
      _picking = true;
      _mode = null;
      _prompt = null;
    });

    GroupMember? flash;
    for (var i = 0; i < 12; i++) {
      await Future<void>.delayed(Duration(milliseconds: 60 + i * 12));
      if (!mounted) return;
      flash = _members[_random.nextInt(_members.length)];
      setState(() => _current = flash);
    }

    HapticFeedback.mediumImpact();
    setState(() {
      _current = _members[_random.nextInt(_members.length)];
      _picking = false;
    });
  }

  void _choose(String mode) {
    if (_current == null) {
      showSnack(context, 'Pick a player first.', error: true);
      return;
    }
    setState(() {
      _mode = mode;
      _prompt = mode == 'truth' ? GameContent.randomTruth() : GameContent.randomDare();
    });
    HapticFeedback.selectionClick();
  }

  void _rerollPrompt() {
    if (_mode == null) return;
    setState(() {
      _prompt = _mode == 'truth' ? GameContent.randomTruth() : GameContent.randomDare();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WireframeAppBar(title: 'Truth or Dare'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              children: [
                const Text(
                  'Pass the phone around. Spin a player, then choose Truth or Dare.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 24),
                SectionCard(
                  child: Column(
                    children: [
                      const Text('UP NEXT', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.8, color: AppColors.muted)),
                      const SizedBox(height: 12),
                      if (_current == null)
                        const Text(
                          'Tap spin',
                          style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppColors.muted),
                        )
                      else ...[
                        AvatarCircle(initials: initials(_current!.name), color: AppColors.decide),
                        const SizedBox(height: 10),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 120),
                          child: Text(
                            _current!.name.toUpperCase(),
                            key: ValueKey(_current!.name + (_picking ? '-picking' : '')),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900),
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      WireframeOutlineButton(
                        label: _picking ? 'Spinning...' : 'Spin player',
                        onPressed: _picking ? null : _pickPlayer,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: WireframeOutlineButton(
                        label: 'Truth',
                        onPressed: _picking || _current == null ? null : () => _choose('truth'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WireframeOutlineButton(
                        label: 'Dare',
                        onPressed: _picking || _current == null ? null : () => _choose('dare'),
                      ),
                    ),
                  ],
                ),
                if (_prompt != null && _mode != null) ...[
                  const SizedBox(height: 20),
                  SectionCard(
                    color: _mode == 'truth'
                        ? AppColors.members.withValues(alpha: 0.08)
                        : AppColors.accent.withValues(alpha: 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _mode == 'truth' ? 'TRUTH' : 'DARE',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1,
                            color: _mode == 'truth' ? AppColors.members : AppColors.accent,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _prompt!,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, height: 1.35),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _rerollPrompt,
                                child: const Text('New prompt'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: FilledButton(
                                onPressed: _pickPlayer,
                                child: const Text('Next player'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
