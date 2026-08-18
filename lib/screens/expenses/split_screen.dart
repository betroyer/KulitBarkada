import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

class SplitScreen extends StatefulWidget {
  const SplitScreen({super.key, required this.groupId, required this.total});

  final int groupId;
  final double total;

  @override
  State<SplitScreen> createState() => _SplitScreenState();
}

class _SplitScreenState extends State<SplitScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  List<GroupMember> _members = [];
  final Map<int, TextEditingController> _custom = {};
  final Map<int, TextEditingController> _percent = {};
  List<ExpenseSplit> _saved = [];
  Map<int, double> _paid = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final members = await MemberRepository().list(widget.groupId);
    final saved = await ExpenseRepository().listSplits(widget.groupId);
    final paid = await ExpenseRepository().amountsPaidByMember(widget.groupId);
    for (final member in members) {
      final id = member.id;
      if (id == null) continue;
      final existing = saved.where((s) => s.memberId == id).firstOrNull;
      _custom[id] = TextEditingController(
        text: existing != null && existing.splitType == 'custom'
            ? existing.amount.toStringAsFixed(2)
            : '',
      );
      _percent[id] = TextEditingController(
        text: existing != null && existing.splitType == 'percentage'
            ? (existing.percentage ?? 0).toStringAsFixed(0)
            : '',
      );
    }
    if (!mounted) return;
    setState(() {
      _members = members;
      _saved = saved;
      _paid = paid;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in _custom.values) {
      c.dispose();
    }
    for (final c in _percent.values) {
      c.dispose();
    }
    super.dispose();
  }

  List<double> get _equal {
    return equalAmounts(widget.total, _members.length);
  }

  Future<void> _saveEqual() async {
    if (_members.isEmpty) return;
    final amounts = _equal;
    final splits = <ExpenseSplit>[];
    for (var i = 0; i < _members.length; i++) {
      splits.add(ExpenseSplit(
        groupId: widget.groupId,
        memberId: _members[i].id!,
        splitType: 'equal',
        amount: amounts[i],
      ));
    }
    await ExpenseRepository().saveSplits(widget.groupId, splits);
    if (!mounted) return;
    showSnack(context, 'Equal split saved.');
    _load();
  }

  Future<void> _saveCustom() async {
    double sum = 0;
    final splits = <ExpenseSplit>[];
    for (final member in _members) {
      final amount = parseAmount(_custom[member.id]!.text);
      sum += amount;
      splits.add(ExpenseSplit(
        groupId: widget.groupId,
        memberId: member.id!,
        splitType: 'custom',
        amount: amount,
      ));
    }
    if ((sum - widget.total).abs() > 0.05) {
      showSnack(context, 'Custom amounts must add up to ${formatPeso(widget.total)}.', error: true);
      return;
    }
    await ExpenseRepository().saveSplits(widget.groupId, splits);
    if (!mounted) return;
    showSnack(context, 'Custom split saved.');
    _load();
  }

  Future<void> _savePercent() async {
    double percentSum = 0;
    final splits = <ExpenseSplit>[];
    for (final member in _members) {
      final percent = parseAmount(_percent[member.id]!.text);
      percentSum += percent;
      splits.add(ExpenseSplit(
        groupId: widget.groupId,
        memberId: member.id!,
        splitType: 'percentage',
        amount: double.parse((widget.total * percent / 100).toStringAsFixed(2)),
        percentage: percent,
      ));
    }
    if ((percentSum - 100).abs() > 0.05) {
      showSnack(context, 'Percentages must add up to 100%.', error: true);
      return;
    }
    await ExpenseRepository().saveSplits(widget.groupId, splits);
    if (!mounted) return;
    showSnack(context, 'Percentage split saved.');
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final settlements = _buildSettlements();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense splitting'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Equal'),
            Tab(text: 'Custom'),
            Tab(text: 'Percent'),
          ],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                  child: SectionCard(
                    child: Row(
                      children: [
                        const Text('Total to split', style: TextStyle(fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text(formatPeso(widget.total), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabs,
                    children: [
                      _equalTab(),
                      _customTab(),
                      _percentTab(),
                    ],
                  ),
                ),
                if (settlements.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                    child: SectionCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Who pays whom', style: TextStyle(fontWeight: FontWeight.w800)),
                          const SizedBox(height: 8),
                          for (final s in settlements)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text('${s.fromName} → ${s.toName}  ${formatPeso(s.amount)}'),
                            ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _equalTab() {
    if (_members.isEmpty) {
      return const EmptyState(emoji: '👥', title: 'No members', subtitle: 'Add members first.');
    }
    final amounts = _equal;
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (var i = 0; i < _members.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: SectionCard(
              child: Row(
                children: [
                  AvatarCircle(initials: initials(_members[i].name), color: AppColors.expenses),
                  const SizedBox(width: 12),
                  Expanded(child: Text(_members[i].name, style: const TextStyle(fontWeight: FontWeight.w700))),
                  Text(formatPeso(amounts[i]), style: const TextStyle(fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
        FilledButton(onPressed: _saveEqual, child: const Text('Save equal split')),
      ],
    );
  }

  Widget _customTab() {
    double running = 0;
    for (final member in _members) {
      running += parseAmount(_custom[member.id]?.text ?? '');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (final member in _members)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: _custom[member.id],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: member.name, prefixText: '₱ '),
              onChanged: (_) => setState(() {}),
            ),
          ),
        Text('Assigned ${formatPeso(running)} of ${formatPeso(widget.total)}',
            style: TextStyle(color: (running - widget.total).abs() < 0.05 ? AppColors.success : AppColors.muted)),
        const SizedBox(height: 12),
        FilledButton(onPressed: _saveCustom, child: const Text('Save custom split')),
      ],
    );
  }

  Widget _percentTab() {
    double running = 0;
    for (final member in _members) {
      running += parseAmount(_percent[member.id]?.text ?? '');
    }
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        for (final member in _members)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: TextFormField(
              controller: _percent[member.id],
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: member.name,
                suffixText: '%  ${formatPeso(widget.total * parseAmount(_percent[member.id]?.text ?? '') / 100)}',
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
        Text('Assigned ${running.toStringAsFixed(0)}% of 100%',
            style: TextStyle(color: (running - 100).abs() < 0.05 ? AppColors.success : AppColors.muted)),
        const SizedBox(height: 12),
        FilledButton(onPressed: _savePercent, child: const Text('Save percentage split')),
      ],
    );
  }

  List<Settlement> _buildSettlements() {
    if (_saved.isEmpty || _members.isEmpty) return const [];
    final shares = {for (final s in _saved) s.memberId: s.amount};
    return buildSettlements(members: _members, paidByMember: _paid, shareByMember: shares);
  }
}
