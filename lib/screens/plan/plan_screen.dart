import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  List<GroupPlan> _plans = [];
  OutingGroup? _group;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final plans = await PlanRepository().list(widget.groupId);
    final group = await GroupRepository().getById(widget.groupId);
    if (!mounted) return;
    setState(() {
      _plans = plans;
      _group = group;
    });
  }

  Future<void> _openForm({GroupPlan? plan}) async {
    final group = _group;
    if (group == null) return;
    final saved = await pushPage<bool>(
      context,
      PlanFormScreen(group: group, plan: plan),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(GroupPlan plan) async {
    final ok = await confirmAction(context, title: 'Delete this plan?', message: 'The group can create another plan anytime.');
    if (!ok) return;
    await PlanRepository().delete(plan.id!);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Final Group Plan')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Create plan'),
      ),
      body: _plans.isEmpty
          ? const EmptyState(
              emoji: '📋',
              title: 'No final plan yet',
              subtitle: 'Use Decide for Us, then save the result — or write the plan yourself.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: _plans.length,
              separatorBuilder: (_, _) => const SizedBox(height: 14),
              itemBuilder: (context, index) {
                final plan = _plans[index];
                return SectionCard(
                  child: Column(
                    children: [
                      Text('━━━━━━━━━━━━━━━━━━', style: TextStyle(color: Colors.black.withValues(alpha: 0.2))),
                      Text(plan.title.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1)),
                      Text('━━━━━━━━━━━━━━━━━━', style: TextStyle(color: Colors.black.withValues(alpha: 0.2))),
                      const SizedBox(height: 12),
                      _line('📅 Date', formatLongDate(parseIsoDate(plan.date))),
                      _line('📍 Place', plan.placeName.isEmpty ? 'TBD' : plan.placeName),
                      _line('🍔 Food', plan.foodName.isEmpty ? 'TBD' : plan.foodName),
                      _line('🎯 Activity', plan.activityName.isEmpty ? 'TBD' : plan.activityName),
                      _line('👥 Members', '${plan.memberCount} Members'),
                      _line('💰 Budget', formatPeso(plan.budget)),
                      _line('💸 Estimated Expenses', formatPeso(plan.estimatedExpenses)),
                      _line('💵 Estimated Per Person', formatPeso(plan.perPerson)),
                      if (plan.notes.isNotEmpty) _line('📝 Notes', plan.notes),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _openForm(plan: plan),
                              child: const Text('Edit'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => _delete(plan),
                              style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
                              child: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: Text(label, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700))),
          Expanded(
            child: Text(value, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800)),
          ),
        ],
      ),
    );
  }
}

class PlanFormScreen extends StatefulWidget {
  const PlanFormScreen({super.key, required this.group, this.plan});

  final OutingGroup group;
  final GroupPlan? plan;

  @override
  State<PlanFormScreen> createState() => _PlanFormScreenState();
}

class _PlanFormScreenState extends State<PlanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _title;
  late final TextEditingController _place;
  late final TextEditingController _food;
  late final TextEditingController _activity;
  late final TextEditingController _estimated;
  late final TextEditingController _notes;
  late DateTime _date;

  @override
  void initState() {
    super.initState();
    final plan = widget.plan;
    final group = widget.group;
    _title = TextEditingController(text: plan?.title ?? group.name);
    _place = TextEditingController(text: plan?.placeName ?? group.decidedPlace ?? '');
    _food = TextEditingController(text: plan?.foodName ?? group.decidedFood ?? '');
    _activity = TextEditingController(text: plan?.activityName ?? group.decidedActivity ?? '');
    _estimated = TextEditingController(
      text: plan == null ? '' : plan.estimatedExpenses.toStringAsFixed(0),
    );
    _notes = TextEditingController(text: plan?.notes ?? '');
    _date = parseIsoDate(plan?.date ?? group.date);
  }

  @override
  void dispose() {
    _title.dispose();
    _place.dispose();
    _food.dispose();
    _activity.dispose();
    _estimated.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final plan = GroupPlan(
      id: widget.plan?.id,
      groupId: widget.group.id!,
      title: _title.text.trim(),
      date: toIsoDate(_date),
      placeName: _place.text.trim(),
      foodName: _food.text.trim(),
      activityName: _activity.text.trim(),
      memberCount: widget.group.memberCount,
      budget: widget.group.budget,
      estimatedExpenses: parseAmount(_estimated.text),
      notes: _notes.text.trim(),
    );
    if (widget.plan == null) {
      await PlanRepository().insert(plan);
    } else {
      await PlanRepository().update(plan);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.plan == null ? 'Create final plan' : 'Edit final plan')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _title,
                  decoration: const InputDecoration(labelText: 'Plan title'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
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
                const SizedBox(height: 14),
                TextFormField(controller: _place, decoration: const InputDecoration(labelText: 'Place')),
                const SizedBox(height: 14),
                TextFormField(controller: _food, decoration: const InputDecoration(labelText: 'Food')),
                const SizedBox(height: 14),
                TextFormField(controller: _activity, decoration: const InputDecoration(labelText: 'Activity')),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _estimated,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Estimated expenses', prefixText: '₱ '),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _notes,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _save, child: const Text('Save plan')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
