import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import '../../widgets/wireframe_ui.dart';
import 'custom_spin_screen.dart';

class CustomSplitScreen extends StatefulWidget {
  const CustomSplitScreen({super.key, required this.groupId, required this.total});

  final int groupId;
  final double total;

  @override
  State<CustomSplitScreen> createState() => _CustomSplitScreenState();
}

class _CustomSplitScreenState extends State<CustomSplitScreen> {
  final _amountCtrl = TextEditingController();
  final List<double> _splits = [];
  List<GroupMember> _members = [];
  Map<int, double> _assigned = {};
  bool _loading = true;

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
        _splits.addAll(saved.map((s) => s.amount));
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
      _amountCtrl.clear();
    });
  }

  void _editSplit(int index) async {
    final ctrl = TextEditingController(text: _splits[index].toStringAsFixed(0));
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit split'),
        content: TextField(
          controller: ctrl,
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
    setState(() => _splits[index] = amount);
  }

  void _deleteSplit(int index) {
    setState(() => _splits.removeAt(index));
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
    if ((_splitSum - widget.total).abs() > 0.05) {
      showSnack(context, 'Split amounts must total ${formatPeso(widget.total)}.', error: true);
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
    if (result != null) setState(() => _assigned = result);
  }

  Future<void> _saveManual() async {
    if (_assigned.length != _members.length) {
      showSnack(context, 'Spin the roulette to assign each member first.', error: true);
      return;
    }
    final splits = _assigned.entries
        .map((e) => ExpenseSplit(
              groupId: widget.groupId,
              memberId: e.key,
              splitType: 'custom',
              amount: e.value,
            ))
        .toList();
    await ExpenseRepository().saveSplits(widget.groupId, splits);
    if (!mounted) return;
    showSnack(context, 'Custom split saved.');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final assignedSum = _assigned.values.fold(0.0, (a, b) => a + b);
    return Scaffold(
      appBar: const WireframeAppBar(title: 'Custom Split'),
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
                        decoration: const InputDecoration(hintText: 'Enter amount', prefixText: '₱ '),
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
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('SPLIT', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12)),
                              Text(
                                _display(_splits[i]),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 20),
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
                ],
                if (_assigned.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const WireframeSectionLabel(label: 'Assigned'),
                  for (final member in _members)
                    if (member.id != null && _assigned.containsKey(member.id))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                member.name.toUpperCase(),
                                style: const TextStyle(fontWeight: FontWeight.w800),
                              ),
                            ),
                            Text(
                              _display(_assigned[member.id!]!),
                              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                  WireframeTotalBox(total: _display(assignedSum)),
                ],
                const SizedBox(height: 24),
                WireframeOutlineButton(label: 'Custom Spin', onPressed: _spinAssign),
                if (_assigned.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  WireframeOutlineButton(label: 'Save custom split', onPressed: _saveManual),
                ],
              ],
            ),
    );
  }
}
