import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/roulette_wheel.dart';
import '../../widgets/wireframe_ui.dart';

/// Wireframe spin: member name on top, wheel with amounts, TAP to assign.
class CustomSpinScreen extends StatefulWidget {
  const CustomSpinScreen({
    super.key,
    required this.groupId,
    required this.members,
    required this.splitAmounts,
  });

  final int groupId;
  final List<GroupMember> members;
  final List<double> splitAmounts;

  @override
  State<CustomSpinScreen> createState() => _CustomSpinScreenState();
}

class _CustomSpinScreenState extends State<CustomSpinScreen> {
  final _wheelKey = GlobalKey<FortuneRouletteState>();
  var _round = 0;
  final _results = <int, double>{};
  final _remaining = <double>[];
  var _spinning = false;
  String? _lastPick;

  @override
  void initState() {
    super.initState();
    _remaining.addAll(widget.splitAmounts);
  }

  GroupMember get _member => widget.members[_round];

  List<String> get _options => _remaining.map(_label).toList();

  String _label(double a) {
    if (a == a.roundToDouble()) return a.round().toString();
    return a.toStringAsFixed(0);
  }

  void _removeAmount(double amount) {
    for (var i = 0; i < _remaining.length; i++) {
      if ((_remaining[i] - amount).abs() < 0.01) {
        _remaining.removeAt(i);
        return;
      }
    }
  }

  void _onSettled(String label) {
    final amount = double.tryParse(label) ?? 0;
    setState(() {
      _lastPick = label;
      _results[_member.id!] = amount;
      _removeAmount(amount);
      _spinning = false;
    });

    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      if (_round < widget.members.length - 1) {
        setState(() {
          _round += 1;
          _lastPick = null;
        });
      } else {
        Navigator.pop(context, Map<int, double>.from(_results));
      }
    });
  }

  Future<void> _tapSpin() async {
    if (_spinning || _options.isEmpty) return;
    setState(() => _spinning = true);
    await _wheelKey.currentState?.spin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WireframeAppBar(title: 'Custom Split'),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              _member.name.toUpperCase(),
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: 0.8),
            ),
            const SizedBox(height: 6),
            Text(
              'Round ${_round + 1} of ${widget.members.length}',
              style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
            ),
            const Spacer(),
            FortuneRoulette(
              key: _wheelKey,
              options: _options,
              emoji: '🎡',
              size: 280,
              onSettled: _onSettled,
            ),
            const Spacer(),
            if (_lastPick != null)
              Text(
                'Landed on $_lastPick',
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18),
              ),
            const SizedBox(height: 16),
            WireframeOutlineButton(
              label: _spinning ? 'Spinning...' : 'Tap',
              onPressed: _spinning ? null : _tapSpin,
            ),
          ],
        ),
      ),
    );
  }
}
