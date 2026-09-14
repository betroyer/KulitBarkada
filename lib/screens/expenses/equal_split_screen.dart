import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../widgets/widgets.dart';
import '../../widgets/wireframe_ui.dart';

class EqualSplitScreen extends StatefulWidget {
  const EqualSplitScreen({super.key, required this.groupId, required this.total});

  final int groupId;
  final double total;

  @override
  State<EqualSplitScreen> createState() => _EqualSplitScreenState();
}

class _EqualSplitScreenState extends State<EqualSplitScreen> {
  List<GroupMember> _members = [];
  bool _loading = true;

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

  List<double> get _amounts => equalAmounts(widget.total, _members.length);

  String _display(double value) {
    if (value == value.roundToDouble()) return value.round().toString();
    return value.toStringAsFixed(0);
  }

  Future<void> _save() async {
    if (_members.isEmpty) return;
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
    showSnack(context, 'Equal split saved automatically.');
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
                    const Text(
                      'Automatic pag equal — each member pays the same share.',
                      style: TextStyle(color: AppColors.muted, height: 1.4),
                    ),
                    const SizedBox(height: 20),
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
                            Text(_display(_amounts[i]), style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
                          ],
                        ),
                      ),
                    const Divider(height: 32),
                    WireframeTotalBox(total: _display(widget.total)),
                    const SizedBox(height: 24),
                    WireframeOutlineButton(label: 'Save equal split', onPressed: _save),
                  ],
                ),
    );
  }
}
