import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/auth_state.dart';
import '../../utils/formatters.dart';

class GroupFormScreen extends StatefulWidget {
  const GroupFormScreen({super.key, this.group});

  final OutingGroup? group;

  @override
  State<GroupFormScreen> createState() => _GroupFormScreenState();
}

class _GroupFormScreenState extends State<GroupFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _budget;
  late DateTime _date;
  bool _busy = false;

  bool get _editing => widget.group != null;

  @override
  void initState() {
    super.initState();
    final group = widget.group;
    _name = TextEditingController(text: group?.name ?? '');
    _description = TextEditingController(text: group?.description ?? '');
    _budget = TextEditingController(
      text: group == null || group.budget == 0 ? '' : group.budget.toStringAsFixed(0),
    );
    _date = group == null ? DateTime.now() : parseIsoDate(group.date);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _budget.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final user = context.read<AuthState>().user;
    if (user?.id == null) return;
    setState(() => _busy = true);
    final repo = GroupRepository();
    final group = OutingGroup(
      id: widget.group?.id,
      userId: user!.id!,
      name: _name.text.trim(),
      date: toIsoDate(_date),
      description: _description.text.trim(),
      budget: parseAmount(_budget.text),
      decidedFood: widget.group?.decidedFood,
      decidedPlace: widget.group?.decidedPlace,
      decidedActivity: widget.group?.decidedActivity,
    );
    if (_editing) {
      await repo.update(group);
    } else {
      final id = await repo.insert(group);
      await MemberRepository().insert(GroupMember(
        groupId: id,
        name: user.fullName,
        role: 'Organizer',
      ));
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_editing ? 'Edit group' : 'Create group')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(labelText: 'Group name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Group name is required' : null,
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
                  onTap: _pickDate,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _description,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _budget,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Budget (₱)', prefixText: '₱ '),
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) return 'Budget is required';
                    if (parseAmount(v) < 0) return 'Budget cannot be negative';
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: _busy ? null : _save,
                  child: Text(_editing ? 'Save changes' : 'Create group'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
