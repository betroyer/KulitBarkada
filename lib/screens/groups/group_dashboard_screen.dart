import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import '../catalog/catalog_screen.dart';
import '../decide/decide_screen.dart';
import '../expenses/expenses_screen.dart';
import '../members/members_screen.dart';
import '../plan/plan_screen.dart';
import 'group_form_screen.dart';
import 'group_summary_screen.dart';

class GroupDashboardScreen extends StatefulWidget {
  const GroupDashboardScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<GroupDashboardScreen> createState() => _GroupDashboardScreenState();
}

class _GroupDashboardScreenState extends State<GroupDashboardScreen> {
  OutingGroup? _group;
  bool _loading = true;

  Future<void> _reload() async {
    final group = await GroupRepository().getById(widget.groupId);
    if (!mounted) return;
    setState(() {
      _group = group;
      _loading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _edit() async {
    final group = _group;
    if (group == null) return;
    final saved = await pushPage<bool>(context, GroupFormScreen(group: group));
    if (saved == true) _reload();
  }

  Future<void> _delete() async {
    final ok = await confirmAction(
      context,
      title: 'Delete this group?',
      message: 'Members, food, places, expenses, and the final plan will also be removed.',
    );
    if (!ok || !mounted) return;
    await GroupRepository().delete(widget.groupId);
    if (!mounted) return;
    Navigator.pop(context);
  }

  Future<void> _open(Widget page) async {
    await pushPage(context, page);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    final group = _group;
    return Scaffold(
      appBar: AppBar(
        title: Text(group?.name ?? 'Group'),
        actions: [
          IconButton(onPressed: _edit, icon: const Icon(Icons.edit_outlined)),
          IconButton(onPressed: _delete, icon: const Icon(Icons.delete_outline)),
        ],
      ),
      body: _loading || group == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Text(formatLongDate(parseIsoDate(group.date)),
                    style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600)),
                if (group.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(group.description, style: const TextStyle(height: 1.4)),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    StatPill(emoji: '👥', label: 'Members', value: '${group.memberCount}'),
                    const SizedBox(width: 8),
                    StatPill(emoji: '💰', label: 'Budget', value: formatPeso(group.budget)),
                    const SizedBox(width: 8),
                    StatPill(emoji: '💸', label: 'Expenses', value: formatPeso(group.totalExpenses)),
                  ],
                ),
                const SizedBox(height: 20),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.15,
                  children: [
                    FeatureTile(
                      emoji: '👥',
                      label: 'Members',
                      color: AppColors.members,
                      onTap: () => _open(MembersScreen(groupId: widget.groupId)),
                    ),
                    FeatureTile(
                      emoji: '🍔',
                      label: 'Food',
                      color: AppColors.food,
                      onTap: () => _open(CatalogScreen(groupId: widget.groupId, type: CatalogType.food)),
                    ),
                    FeatureTile(
                      emoji: '📍',
                      label: 'Places',
                      color: AppColors.places,
                      onTap: () => _open(CatalogScreen(groupId: widget.groupId, type: CatalogType.place)),
                    ),
                    FeatureTile(
                      emoji: '🎯',
                      label: 'Activities',
                      color: AppColors.activities,
                      onTap: () => _open(CatalogScreen(groupId: widget.groupId, type: CatalogType.activity)),
                    ),
                    FeatureTile(
                      emoji: '🎲',
                      label: 'Decide for Us',
                      color: AppColors.decide,
                      onTap: () => _open(DecideScreen(groupId: widget.groupId)),
                    ),
                    FeatureTile(
                      emoji: '💰',
                      label: 'Expenses',
                      color: AppColors.expenses,
                      onTap: () => _open(ExpensesScreen(groupId: widget.groupId)),
                    ),
                    FeatureTile(
                      emoji: '📋',
                      label: 'Final Plan',
                      color: AppColors.plan,
                      onTap: () => _open(PlanScreen(groupId: widget.groupId)),
                    ),
                    FeatureTile(
                      emoji: '📊',
                      label: 'Summary',
                      color: AppColors.summary,
                      onTap: () => _open(GroupSummaryScreen(groupId: widget.groupId)),
                    ),
                  ],
                ),
              ],
            ),
    );
  }
}
