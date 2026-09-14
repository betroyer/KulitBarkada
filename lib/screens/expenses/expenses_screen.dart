import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../utils/plan_costs.dart';
import '../../widgets/widgets.dart';
import '../../widgets/wireframe_ui.dart';
import 'custom_split_screen.dart';
import 'equal_split_screen.dart';
import 'expense_form_screen.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  final _repo = ExpenseRepository();
  PlanCostBreakdown? _planCosts;
  List<ExpenseItem> _items = [];
  double _loggedTotal = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final group = await GroupRepository().getById(widget.groupId);
    final planCosts = await loadPlanCosts(widget.groupId, group);
    final items = await _repo.list(widget.groupId);
    final total = await _repo.totalForGroup(widget.groupId);
    if (!mounted) return;
    setState(() {
      _planCosts = planCosts;
      _items = items;
      _loggedTotal = total;
      _loading = false;
    });
  }

  double get _splitTotal {
    if (_loggedTotal > 0) return _loggedTotal;
    return _planCosts?.total ?? 0;
  }

  String _amount(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(0);
  }

  Future<void> _openForm({ExpenseItem? expense}) async {
    final saved = await pushPage<bool>(
      context,
      ExpenseFormScreen(groupId: widget.groupId, expense: expense),
    );
    if (saved == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final plan = _planCosts;
    return Scaffold(
      appBar: const WireframeAppBar(title: 'Expenses'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      body: _loading || plan == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              children: [
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  decoration: BoxDecoration(
                    border: Border(left: BorderSide(color: AppColors.ink, width: 3)),
                  ),
                  child: Column(
                    children: [
                      WireframeLineItem(label: 'Food', amount: _amount(plan.food)),
                      WireframeLineItem(label: 'Place', amount: _amount(plan.place)),
                      WireframeLineItem(label: 'Activity', amount: _amount(plan.activity)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                WireframeTotalBox(total: _amount(_splitTotal)),
                const WireframeSectionLabel(label: 'Expense Splitting'),
                Row(
                  children: [
                    Expanded(
                      child: WireframeOutlineButton(
                        label: 'Equal',
                        onPressed: _splitTotal <= 0
                            ? null
                            : () async {
                                await pushPage(
                                  context,
                                  EqualSplitScreen(groupId: widget.groupId, total: _splitTotal),
                                );
                                _reload();
                              },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WireframeOutlineButton(
                        label: 'Custom',
                        onPressed: _splitTotal <= 0
                            ? null
                            : () async {
                                await pushPage(
                                  context,
                                  CustomSplitScreen(groupId: widget.groupId, total: _splitTotal),
                                );
                                _reload();
                              },
                      ),
                    ),
                  ],
                ),
                if (_items.isNotEmpty) ...[
                  const SizedBox(height: 28),
                  const WireframeSectionLabel(label: 'Logged Expenses'),
                  ..._items.map((expense) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: SectionCard(
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(expense.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                          subtitle: Text('Paid by ${expense.paidByName}'),
                          trailing: Text(formatPeso(expense.amount), style: const TextStyle(fontWeight: FontWeight.w900)),
                          onTap: () => _openForm(expense: expense),
                        ),
                      ),
                    );
                  }),
                ],
              ],
            ),
    );
  }
}
