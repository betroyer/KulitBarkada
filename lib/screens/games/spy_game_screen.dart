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

enum _SpyPhase { setup, reveal, discuss, vote, result }

class SpyGameScreen extends StatefulWidget {
  const SpyGameScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<SpyGameScreen> createState() => _SpyGameScreenState();
}

class _SpyGameScreenState extends State<SpyGameScreen> {
  final _random = Random();
  List<GroupMember> _members = [];
  bool _loading = true;

  _SpyPhase _phase = _SpyPhase.setup;
  var _spyCount = 1;
  String? _location;
  Set<int> _spyIds = {};
  var _revealIndex = 0;
  var _cardHidden = true;
  Map<int, int> _votes = {};
  int? _selectedVote;

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
      _spyCount = members.length >= 6 ? 2 : 1;
      _loading = false;
    });
  }

  void _startRound() {
    if (_members.length < 3) {
      showSnack(context, 'Need at least 3 members.', error: true);
      return;
    }
    final ids = _members.map((m) => m.id!).toList()..shuffle(_random);
    final spies = ids.take(_spyCount).toSet();
    setState(() {
      _location = GameContent.randomLocation();
      _spyIds = spies;
      _revealIndex = 0;
      _cardHidden = true;
      _votes = {};
      _selectedVote = null;
      _phase = _SpyPhase.reveal;
    });
  }

  GroupMember get _current => _members[_revealIndex];

  void _showCard() {
    setState(() => _cardHidden = false);
    HapticFeedback.lightImpact();
  }

  void _hideAndNext() {
    if (_revealIndex < _members.length - 1) {
      setState(() {
        _cardHidden = true;
        _revealIndex += 1;
      });
    } else {
      setState(() {
        _cardHidden = true;
        _phase = _SpyPhase.discuss;
      });
    }
  }

  void _castVote() {
    final voter = _members[_votes.length];
    final target = _selectedVote;
    if (target == null) {
      showSnack(context, 'Pick who you think is the spy.', error: true);
      return;
    }
    setState(() {
      _votes[voter.id!] = target;
      _selectedVote = null;
      if (_votes.length >= _members.length) {
        _phase = _SpyPhase.result;
      }
    });
  }

  MapEntry<int, int> get _topVoted {
    final tallies = <int, int>{};
    for (final target in _votes.values) {
      tallies[target] = (tallies[target] ?? 0) + 1;
    }
    final sorted = tallies.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return sorted.first;
  }

  String _nameOf(int id) => _members.firstWhere((m) => m.id == id).name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WireframeAppBar(title: 'Who is the Spy'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : switch (_phase) {
              _SpyPhase.setup => _setupView(),
              _SpyPhase.reveal => _revealView(),
              _SpyPhase.discuss => _discussView(),
              _SpyPhase.vote => _voteView(),
              _SpyPhase.result => _resultView(),
            },
    );
  }

  Widget _setupView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const Text(
          'Pass the phone one by one. Civilians see the secret place. Spies only see that they are the spy.',
          style: TextStyle(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('${_members.length} players', style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final m in _members)
                    Chip(
                      avatar: CircleAvatar(
                        backgroundColor: AppColors.activities.withValues(alpha: 0.15),
                        foregroundColor: AppColors.activities,
                        child: Text(initials(m.name), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                      ),
                      label: Text(m.name),
                    ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text('Number of spies', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        if (_members.length >= 5)
          SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 1, label: Text('1 spy')),
              ButtonSegment(value: 2, label: Text('2 spies')),
            ],
            selected: {_spyCount},
            onSelectionChanged: (v) => setState(() => _spyCount = v.first),
          )
        else
          const Text('1 spy (add 5+ members to unlock 2 spies)', style: TextStyle(color: AppColors.muted)),
        const SizedBox(height: 24),
        WireframeOutlineButton(label: 'Start round', onPressed: _startRound),
      ],
    );
  }

  Widget _revealView() {
    final isSpy = _spyIds.contains(_current.id);
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Text(
            'Pass to ${_current.name.toUpperCase()}',
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
          ),
          const SizedBox(height: 8),
          Text(
            'Player ${_revealIndex + 1} of ${_members.length}',
            style: const TextStyle(color: AppColors.muted),
          ),
          const Spacer(),
          if (_cardHidden)
            SectionCard(
              child: Column(
                children: [
                  const Text('🙈', style: TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  const Text(
                    'Make sure only this player can see the screen.',
                    textAlign: TextAlign.center,
                    style: TextStyle(height: 1.4),
                  ),
                  const SizedBox(height: 16),
                  WireframeOutlineButton(label: 'Show my role', onPressed: _showCard),
                ],
              ),
            )
          else
            SectionCard(
              color: isSpy ? AppColors.danger.withValues(alpha: 0.08) : AppColors.success.withValues(alpha: 0.08),
              child: Column(
                children: [
                  Text(isSpy ? '🕵️' : '📍', style: const TextStyle(fontSize: 48)),
                  const SizedBox(height: 12),
                  Text(
                    isSpy ? 'YOU ARE THE SPY' : 'CIVILIAN',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 22,
                      color: isSpy ? AppColors.danger : AppColors.success,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    isSpy
                        ? 'You do not know the place. Blend in. Ask vague questions.'
                        : 'The place is:\n\n${_location!}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  WireframeOutlineButton(
                    label: _revealIndex < _members.length - 1 ? 'Hide & next player' : 'Hide & start talking',
                    onPressed: _hideAndNext,
                  ),
                ],
              ),
            ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _discussView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        const Text('DISCUSSION', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
        const SizedBox(height: 12),
        const Text(
          'Take turns asking questions about the place. Civilians: don’t say the place out loud. Spy: try to figure it out without getting caught.',
          style: TextStyle(color: AppColors.muted, height: 1.4),
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tips', style: TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              const Text('• Ask about sounds, smells, clothes, or prices.'),
              const Text('• Keep answers short so the spy stays guessing.'),
              const Text('• When ready, vote who you think is the spy.'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        WireframeOutlineButton(
          label: 'Start voting',
          onPressed: () => setState(() => _phase = _SpyPhase.vote),
        ),
      ],
    );
  }

  Widget _voteView() {
    final voter = _members[_votes.length];
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          '${voter.name.toUpperCase()} votes',
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
        ),
        const SizedBox(height: 6),
        Text(
          'Vote ${_votes.length + 1} of ${_members.length}',
          style: const TextStyle(color: AppColors.muted),
        ),
        const SizedBox(height: 16),
        const Text('Who is the spy?', style: TextStyle(fontWeight: FontWeight.w800)),
        const SizedBox(height: 10),
        for (final member in _members)
          if (member.id != voter.id)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: _selectedVote == member.id ? AppColors.primary : AppColors.ink,
                    width: 2,
                  ),
                ),
                leading: AvatarCircle(initials: initials(member.name), color: AppColors.activities),
                title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                selected: _selectedVote == member.id,
                onTap: () => setState(() => _selectedVote = member.id),
              ),
            ),
        const SizedBox(height: 16),
        WireframeOutlineButton(label: 'Lock vote', onPressed: _castVote),
      ],
    );
  }

  Widget _resultView() {
    final top = _topVoted;
    final accusedId = top.key;
    final accusedIsSpy = _spyIds.contains(accusedId);
    final spyNames = _spyIds.map(_nameOf).join(', ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Text(
          accusedIsSpy ? '🎉 CIVILIANS WIN' : '🕵️ SPY WINS',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 24,
            color: accusedIsSpy ? AppColors.success : AppColors.danger,
          ),
        ),
        const SizedBox(height: 20),
        SectionCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _line('Voted out', _nameOf(accusedId)),
              _line('Votes', '${top.value}'),
              _line('Real spy', spyNames),
              _line('Secret place', _location ?? '—'),
            ],
          ),
        ),
        const SizedBox(height: 24),
        WireframeOutlineButton(label: 'Play again', onPressed: _startRound),
        const SizedBox(height: 12),
        WireframeOutlineButton(
          label: 'Back to setup',
          onPressed: () => setState(() => _phase = _SpyPhase.setup),
        ),
      ],
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700))),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w900)),
          ),
        ],
      ),
    );
  }
}
