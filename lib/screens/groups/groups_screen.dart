import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';
import '../../widgets/wireframe_ui.dart';
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
  List<OutingGroup> _filtered = [];
  bool _loading = true;
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _search.addListener(_applyFilter);
    _reload();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _applyFilter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _items
          : _items.where((g) => g.name.toLowerCase().contains(q)).toList();
    });
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
    _applyFilter();
  }

  Future<void> _create() async {
    final created = await pushPage<bool>(context, const GroupFormScreen());
    if (created == true) _reload();
  }

  Future<void> _openSearch() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('SEARCH', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.8)),
            const SizedBox(height: 12),
            TextField(
              controller: _search,
              autofocus: true,
              decoration: const InputDecoration(hintText: 'Find a barkada...'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KulitAppHeader(onProfileTap: () => pushPage(context, const ProfileScreen())),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: WireframeCreateFab(onPressed: _create),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'MY BARKADA',
                          style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.6),
                        ),
                      ),
                      WireframePill(label: 'SEARCH', icon: Icons.search, onTap: _openSearch),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 48),
                      child: EmptyState(
                        emoji: '👥',
                        title: 'No barkada yet',
                        subtitle: 'Tap + CREATE to start a group outing.',
                      ),
                    )
                  else
                    ..._filtered.map((group) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: WireframeGroupCard(
                          name: group.name,
                          date: formatShortDate(parseIsoDate(group.date)),
                          memberCount: group.memberCount,
                          onTap: () async {
                            await pushPage(context, GroupDashboardScreen(groupId: group.id!));
                            _reload();
                          },
                        ),
                      );
                    }),
                ],
              ),
            ),
    );
  }
}
