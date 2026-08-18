import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import '../auth/profile_screen.dart';
import 'group_dashboard_screen.dart';
import 'group_form_screen.dart';

class GroupsScreen extends StatefulWidget {
  const GroupsScreen({super.key});

  @override
  State<GroupsScreen> createState() => _GroupsScreenState();
}

class _GroupsScreenState extends State<GroupsScreen> {
  final _groups = GroupRepository();
  List<OutingGroup> _items = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final user = context.read<AuthState>().user;
    if (user?.id == null) return;
    final items = await _groups.listForUser(user!.id!);
    if (!mounted) return;
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _create() async {
    final created = await pushPage<bool>(context, const GroupFormScreen());
    if (created == true) _reload();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Groups'),
        actions: [
          IconButton(
            tooltip: 'Account',
            onPressed: () => pushPage(context, const ProfileScreen()),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Create group'),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: _items.isEmpty
                  ? ListView(
                      children: [
                        const SizedBox(height: 80),
                        EmptyState(
                          emoji: '👥',
                          title: 'No groups yet',
                          subtitle: 'Create an outing with your barkada. Everything stays on this phone.',
                        ),
                        if (user != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: Center(
                              child: Text('Hi, ${user.fullName.split(' ').first}',
                                  style: const TextStyle(color: AppColors.muted)),
                            ),
                          ),
                      ],
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      itemCount: _items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final group = _items[index];
                        return InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () async {
                            await pushPage(context, GroupDashboardScreen(groupId: group.id!));
                            _reload();
                          },
                          child: SectionCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(group.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                                const SizedBox(height: 4),
                                Text(formatLongDate(parseIsoDate(group.date)),
                                    style: const TextStyle(color: AppColors.muted)),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    _chip('${group.memberCount} Members'),
                                    const SizedBox(width: 8),
                                    _chip('${formatPeso(group.budget)} Budget'),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
    );
  }

  Widget _chip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}
