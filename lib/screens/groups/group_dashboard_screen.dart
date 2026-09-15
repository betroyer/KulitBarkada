import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import '../../widgets/wireframe_ui.dart';
import '../catalog/catalog_screen.dart';
import '../decide/decide_screen.dart';
import '../expenses/custom_split_screen.dart';
import '../expenses/equal_split_screen.dart';
import '../members/members_screen.dart';
import '../plan/plan_screen.dart';
import 'group_form_screen.dart';
import 'group_summary_screen.dart';

/// Group hub matching the wireframe flow:
/// Members → Decide → Equal / Custom split (main path).
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
      message: 'Members, plans, and expenses for this barkada will also be removed.',
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
      appBar: WireframeAppBar(
        title: group?.name ?? 'Group',
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
                Text(
                  formatLongDate(parseIsoDate(group.date)),
                  style: const TextStyle(color: AppColors.muted, fontWeight: FontWeight.w600),
                ),
                if (group.description.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(group.description, style: const TextStyle(height: 1.4)),
                ],
                const SizedBox(height: 16),
                Row(
                  children: [
                    WireframePill(
                      label: '${group.memberCount} MEMBERS',
                      onTap: () => _open(MembersScreen(groupId: widget.groupId)),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      formatPeso(group.totalExpenses),
                      style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.muted),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const WireframeSectionLabel(label: 'Expense Splitting'),
                const Text(
                  'Choose how the barkada will split the bill.',
                  style: TextStyle(color: AppColors.muted, height: 1.4),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: WireframeOutlineButton(
                        label: 'Equal',
                        onPressed: () => _open(EqualSplitScreen(groupId: widget.groupId)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: WireframeOutlineButton(
                        label: 'Custom',
                        onPressed: () => _open(CustomSplitScreen(groupId: widget.groupId)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                const WireframeSectionLabel(label: 'Plan the outing'),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.2,
                  children: [
                    FeatureTile(
                      emoji: '👥',
                      label: 'Members',
                      color: AppColors.members,
                      onTap: () => _open(MembersScreen(groupId: widget.groupId)),
                    ),
                    FeatureTile(
                      emoji: '🎡',
                      label: 'Decide for Us',
                      color: AppColors.decide,
                      onTap: () => _open(DecideScreen(groupId: widget.groupId)),
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
