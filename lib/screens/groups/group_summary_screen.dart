import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

class GroupSummaryScreen extends StatefulWidget {
  const GroupSummaryScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupSummaryScreen> createState() => _GroupSummaryScreenState();
}

class _GroupSummaryScreenState extends State<GroupSummaryScreen> {
  OutingGroup? _group;
  GroupPlan? _plan;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final group = await GroupRepository().getById(widget.groupId);
    final plan = await PlanRepository().latest(widget.groupId);
    if (!mounted) return;
    setState(() {
      _group = group;
      _plan = plan;
    });
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    return Scaffold(
      appBar: AppBar(title: const Text('Group Summary')),
      body: group == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                SectionCard(
                  color: AppColors.primaryDark,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(group.name.toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 6),
                      Text(formatLongDate(parseIsoDate(group.date)),
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _row('👥 Members', '${group.memberCount}'),
                _row('💰 Group Budget', formatPeso(group.budget)),
                _row('💸 Total Expenses', formatPeso(group.totalExpenses)),
                _row('💵 Remaining', formatPeso(group.remaining)),
                const SizedBox(height: 8),
                _row('🍔 Food', _plan?.foodName.isNotEmpty == true ? _plan!.foodName : (group.decidedFood ?? 'Not decided')),
                _row('📍 Place', _plan?.placeName.isNotEmpty == true ? _plan!.placeName : (group.decidedPlace ?? 'Not decided')),
                _row('🎯 Activity', _plan?.activityName.isNotEmpty == true ? _plan!.activityName : (group.decidedActivity ?? 'Not decided')),
              ],
            ),
    );
  }

  Widget _row(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SectionCard(
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700))),
            Text(value, style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}
