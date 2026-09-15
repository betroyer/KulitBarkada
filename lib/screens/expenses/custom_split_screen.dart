import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import '../../widgets/wireframe_ui.dart';
import '../members/members_screen.dart';
import 'custom_spin_screen.dart';

/// Wireframe Custom Split:
/// AMOUNT + ADD → SPLIT list (edit/delete) → spin → member totals.
class CustomSplitScreen extends StatefulWidget {
  const CustomSplitScreen({super.key, required this.groupId, this.total});

  final int groupId;
  /// Unused for freeform flow; kept for older call sites.
  final double? total;

  @override
  State<CustomSplitScreen> createState() => _CustomSplitScreenState();
}

class _CustomSplitScreenState extends State<CustomSplitScreen> {
  final _amountCtrl = TextEditingController();
  final List<double> _splits = [];
  List<GroupMember> _members = [];
  Map<int, double> _assigned = {};
  bool _loading = true;
  bool _showResult = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final members = await MemberRepository().list(widget.groupId);
    final saved = await ExpenseRepository().listSplits(widget.groupId);
    if (!mounted) return;
    setState(() {
      _members = members;
      if (saved.isNotEmpty && saved.first.splitType == 'custom') {
        _assigned = {for (final s in saved) s.memberId: s.amount};
        if (_splits.isEmpty) {
          _splits.addAll(saved.map((s) => s.amount));
        }
        _showResult = _assigned.isNotEmpty;
      }
      _loading = false;
    });
  }

  double get _splitSum => _splits.fold(0.0, (a, b) => a + b);

  String _display(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(0);
  }

  void _addAmount() {
    final amount = parseAmount(_amountCtrl.text);
    if (amount <= 0) {
      showSnack(context, 'Enter an amount greater than 0.', error: true);
      return;
    }
    setState(() {
      _splits.add(amount);
      _showResult = false;
      _assigned = {};
      _amountCtrl.clear();
    });
  }

  Future<void> _editSplit(int index) async {
    final ctrl = TextEditingController(text: _display(_splits[index]));
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit split'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Amount', prefixText: '₱ '),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );
    if (ok != true) return;
    final amount = parseAmount(ctrl.text);
    if (amount <= 0) return;
    setState(() {
      _splits[index] = amount;
      _showResult = false;
      _assigned = {};
    });
  }

  void _deleteSplit(int index) {
    setState(() {
      _splits.removeAt(index);
      _showResult = false;
      _assigned = {};
    });
  }

  Future<void> _spinAssign() async {
    if (_splits.isEmpty) {
      showSnack(context, 'Add at least one split amount.', error: true);
      return;
    }
    if (_members.isEmpty) {
      showSnack(context, 'Add members first.', error: true);
      return;
    }
    if (_splits.length != _members.length) {
      showSnack(
        context,
        'Add exactly ${_members.length} split amounts (one per member).',
        error: true,
      );
      return;
    }

    final result = await pushPage<Map<int, double>>(
      context,
      CustomSpinScreen(
        groupId: widget.groupId,
        members: _members,
        splitAmounts: List<double>.from(_splits),
      ),
    );
    if (result == null || !mounted) return;

    final splits = result.entries
        .map((e) => ExpenseSplit(
              groupId: widget.groupId,
              memberId: e.key,
              splitType: 'custom',
              amount: e.value,
            ))
        .toList();
    await ExpenseRepository().saveSplits(widget.groupId, splits);

    if (!mounted) return;
    setState(() {
      _assigned = result;
      _showResult = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final assignedSum = _assigned.values.fold(0.0, (a, b) => a + b);

    if (_showResult && _assigned.isNotEmpty) {
      return Scaffold(
        appBar: WireframeAppBar(
          title: 'Custom Split',
          actions: [
            IconButton(
              tooltip: 'Members',
              onPressed: () async {
                await pushPage(context, MembersScreen(groupId: widget.groupId));
                _load();
              },
              icon: const Icon(Icons.groups_outlined),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
          children: [
            for (final member in _members)
              if (member.id != null && _assigned.containsKey(member.id))
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          member.name.toUpperCase(),
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                        ),
                      ),
                      Text(
                        _display(_assigned[member.id!]!),
                        style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                      ),
                    ],
                  ),
                ),
            const Divider(height: 28),
            WireframeTotalBox(total: _display(assignedSum)),
            const SizedBox(height: 28),
            WireframeOutlineButton(
              label: 'Spin again',
              onPressed: () => setState(() {
                _showResult = false;
                _assigned = {};
              }),
            ),
            const SizedBox(height: 12),
            WireframeOutlineButton(
              label: 'Done',
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: WireframeAppBar(
        title: 'Custom Split',
        actions: [
          IconButton(
            tooltip: 'Members',
            onPressed: () async {
              await pushPage(context, MembersScreen(groupId: widget.groupId));
              _load();
            },
            icon: const Icon(Icons.groups_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.ink, width: 2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('AMOUNT', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.6)),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _amountCtrl,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(hintText: '100', prefixText: '₱ '),
                        onSubmitted: (_) => _addAmount(),
                      ),
                      const SizedBox(height: 12),
                      WireframeOutlineButton(label: 'Add', onPressed: _addAmount),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                for (var i = 0; i < _splits.length; i++)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SPLIT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                              Text(
                                _display(_splits[i]),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 22),
                              ),
                            ],
                          ),
                        ),
                        IconButton(onPressed: () => _editSplit(i), icon: const Icon(Icons.edit_outlined)),
                        IconButton(onPressed: () => _deleteSplit(i), icon: const Icon(Icons.delete_outline)),
                      ],
                    ),
                  ),
                if (_splits.isNotEmpty) ...[
                  const Divider(height: 24),
                  WireframeTotalBox(total: _display(_splitSum)),
                  const SizedBox(height: 8),
                  Text(
                    _members.isEmpty
                        ? 'Add members before spinning.'
                        : 'Need ${_members.length} split${_members.length == 1 ? '' : 's'} for ${_members.length} member${_members.length == 1 ? '' : 's'}.',
                    style: const TextStyle(color: AppColors.muted, fontSize: 13),
                  ),
                  const SizedBox(height: 20),
                  WireframeOutlineButton(label: 'Tap to spin', onPressed: _spinAssign),
                ],
              ],
            ),
    );
  }
}
