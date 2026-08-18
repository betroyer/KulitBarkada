import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, required this.groupId, this.expense});

  final int groupId;
  final ExpenseItem? expense;

  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormScreenState();
}

class _ExpenseFormScreenState extends State<ExpenseFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _amount;
  DateTime _date = DateTime.now();
  List<GroupMember> _members = [];
  int? _payerId;
  final Set<int> _participants = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _name = TextEditingController(text: expense?.name ?? '');
    _amount = TextEditingController(
      text: expense == null ? '' : expense.amount.toStringAsFixed(0),
    );
    if (expense != null) _date = parseIsoDate(expense.date);
    _load();
  }

  Future<void> _load() async {
    final members = await MemberRepository().list(widget.groupId);
    if (!mounted) return;
    setState(() {
      _members = members;
      _payerId = widget.expense?.paidByMemberId ?? members.firstOrNull?.id;
      if (widget.expense != null) {
        _participants.addAll(widget.expense!.participantIds);
      } else {
        _participants.addAll(members.map((m) => m.id).whereType<int>());
      }
      _loading = false;
    });
  }

  @override
  void dispose() {
    _name.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_payerId == null) {
      showSnack(context, 'Add a member before logging expenses.', error: true);
      return;
    }
    if (_participants.isEmpty) {
      showSnack(context, 'Select at least one member involved.', error: true);
      return;
    }
    final expense = ExpenseItem(
      id: widget.expense?.id,
      groupId: widget.groupId,
      name: _name.text.trim(),
      amount: parseAmount(_amount.text),
      paidByMemberId: _payerId!,
      date: toIsoDate(_date),
      participantIds: _participants.toList(),
    );
    if (widget.expense == null) {
      await ExpenseRepository().insert(expense);
    } else {
      await ExpenseRepository().update(expense);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.expense == null ? 'Add expense' : 'Edit expense')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: _name,
                        decoration: const InputDecoration(labelText: 'Expense name'),
                        validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _amount,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(labelText: 'Amount', prefixText: '₱ '),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) return 'Required';
                          if (parseAmount(v) <= 0) return 'Enter an amount greater than 0';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),
                      DropdownButtonFormField<int>(
                        initialValue: _payerId,
                        decoration: const InputDecoration(labelText: 'Who paid'),
                        items: [
                          for (final member in _members)
                            if (member.id != null)
                              DropdownMenuItem(value: member.id, child: Text(member.name)),
                        ],
                        onChanged: (value) => setState(() => _payerId = value),
                      ),
                      const SizedBox(height: 14),
                      ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Colors.black.withValues(alpha: 0.08)),
                        ),
                        tileColor: Colors.white,
                        title: const Text('Date'),
                        subtitle: Text(formatLongDate(_date)),
                        trailing: const Icon(Icons.calendar_today_outlined),
                        onTap: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: _date,
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2100),
                          );
                          if (picked != null) setState(() => _date = picked);
                        },
                      ),
                      const SizedBox(height: 20),
                      const Text('Members involved', style: TextStyle(fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          for (final member in _members)
                            if (member.id != null)
                              FilterChip(
                                label: Text(member.name),
                                selected: _participants.contains(member.id),
                                selectedColor: AppColors.primary.withValues(alpha: 0.16),
                                onSelected: (selected) {
                                  setState(() {
                                    if (selected) {
                                      _participants.add(member.id!);
                                    } else {
                                      _participants.remove(member.id);
                                    }
                                  });
                                },
                              ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      FilledButton(onPressed: _save, child: const Text('Save expense')),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}
