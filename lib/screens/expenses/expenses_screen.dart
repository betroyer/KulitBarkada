import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import 'expense_form_screen.dart';
import 'split_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _repo = ExpenseRepository();
  List<ExpenseItem> _items = [];
  double _total = 0;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await _repo.list(widget.groupId);
    final total = await _repo.totalForGroup(widget.groupId);
    if (!mounted) return;
    setState(() {
      _items = items;
      _total = total;
    });
  }

  Future<void> _openForm({ExpenseItem? expense}) async {
    final saved = await pushPage<bool>(
      context,
      ExpenseFormScreen(groupId: widget.groupId, expense: expense),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(ExpenseItem expense) async {
    final ok = await confirmAction(
      context,
      title: 'Delete ${expense.name}?',
      message: '${formatPeso(expense.amount)} will be removed from the group total.',
    );
    if (!ok) return;
    await _repo.delete(expense.id!);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          TextButton(
            onPressed: () async {
              await pushPage(context, SplitScreen(groupId: widget.groupId, total: _total));
              _reload();
            },
            child: const Text('Split'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
            child: SectionCard(
              color: AppColors.primaryDark,
              child: Row(
                children: [
                  const Expanded(
                    child: Text('Total Expenses', style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w600)),
                  ),
                  Text(formatPeso(_total),
                      style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                ],
              ),
            ),
          ),
          Expanded(
            child: _items.isEmpty
                ? const EmptyState(
                    emoji: '💸',
                    title: 'No expenses yet',
                    subtitle: 'Log food, transportation, and entrance fees as you go.',
                  )
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final expense = _items[index];
                      return SectionCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(expense.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text(
                            'Paid by: ${expense.paidByName}\n${formatShortDate(parseIsoDate(expense.date))}'
                            '${expense.participantNames.isEmpty ? '' : '\n${expense.participantNames.join(', ')}'}',
                          ),
                          isThreeLine: true,
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(formatPeso(expense.amount), style: const TextStyle(fontWeight: FontWeight.w800)),
                              PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'edit') _openForm(expense: expense);
                                  if (value == 'delete') _delete(expense);
                                },
                                itemBuilder: (_) => const [
                                  PopupMenuItem(value: 'edit', child: Text('Edit')),
                                  PopupMenuItem(value: 'delete', child: Text('Delete')),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
