import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import '../../widgets/wireframe_ui.dart';

/// Wireframe Equal Split: enter total → auto-divide among members → TOTAL.
class EqualSplitScreen extends StatefulWidget {
  const EqualSplitScreen({super.key, required this.groupId, this.total});

  final int groupId;
  final double? total;

  @override
  State<EqualSplitScreen> createState() => _EqualSplitScreenState();
}

class _EqualSplitScreenState extends State<EqualSplitScreen> {
  final _totalCtrl = TextEditingController();
  List<GroupMember> _members = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    if (widget.total != null && widget.total! > 0) {
      _totalCtrl.text = widget.total == widget.total!.roundToDouble()
          ? widget.total!.round().toString()
          : widget.total!.toStringAsFixed(0);
    }
    _load();
  }

  @override
  void dispose() {
    _totalCtrl.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final members = await MemberRepository().list(widget.groupId);
    if (widget.total == null || widget.total! <= 0) {
      final expenseTotal = await ExpenseRepository().totalForGroup(widget.groupId);
      if (expenseTotal > 0 && _totalCtrl.text.isEmpty) {
        _totalCtrl.text = expenseTotal == expenseTotal.roundToDouble()
            ? expenseTotal.round().toString()
            : expenseTotal.toStringAsFixed(0);
      }
    }
    if (!mounted) return;
    setState(() {
      _members = members;
      _loading = false;
    });
  }

  double get _total => parseAmount(_totalCtrl.text);

  List<double> get _amounts => equalAmounts(_total, _members.length);

  String _display(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(0);
  }

  Future<void> _save() async {
    if (_members.isEmpty) {
      showSnack(context, 'Add members first.', error: true);
      return;
    }
    if (_total <= 0) {
      showSnack(context, 'Enter a total amount to split.', error: true);
      return;
    }
    final amounts = _amounts;
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
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WireframeAppBar(title: 'Equal Split'),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const EmptyState(emoji: '👥', title: 'No members', subtitle: 'Add members to the group first.')
              : ListView(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  children: [
                    TextField(
                      controller: _totalCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'TOTAL AMOUNT',
                        prefixText: '₱ ',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Automatic pag equal — each member gets the same share.',
                      style: TextStyle(color: AppColors.muted, height: 1.4),
                    ),
                    const SizedBox(height: 24),
                    if (_total > 0) ...[
                      for (var i = 0; i < _members.length; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  _members[i].name.toUpperCase(),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                                ),
                              ),
                              Text(
                                _display(_amounts[i]),
                                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                              ),
                            ],
                          ),
                        ),
                      const Divider(height: 32),
                      WireframeTotalBox(total: _display(_total)),
                      const SizedBox(height: 24),
                      WireframeOutlineButton(label: 'Save', onPressed: _save),
                    ],
                  ],
                ),
    );
  }
}
