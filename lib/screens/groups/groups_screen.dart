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
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, MediaQuery.of(context).viewInsets.bottom + 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('Search', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
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
    final user = context.watch<AuthState>().user;
    final firstName = user?.fullName.split(' ').first ?? 'friend';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: KulitAppHeader(onProfileTap: () => pushPage(context, const ProfileScreen())),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: WireframeCreateFab(onPressed: _create),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _reload,
              color: AppColors.accent,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                children: [
                  Text(
                    'Hello, $firstName!',
                    style: const TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                      letterSpacing: -0.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text.rich(
                    TextSpan(
                      style: TextStyle(color: AppColors.muted, fontSize: 15, height: 1.35),
                      children: [
                        TextSpan(text: 'Level up your plans with '),
                        TextSpan(
                          text: 'Kulit Barkada!',
                          style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.accent),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: AppColors.heroGradient,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: AppColors.softShadow,
                    ),
                    child: Row(
                      children: [
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Plan smarter with your barkada',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 18,
                                  color: AppColors.ink,
                                  height: 1.25,
                                ),
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Spin, split, and play — all offline.',
                                style: TextStyle(color: AppColors.muted, height: 1.35),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 12),
                        FilledButton(
                          onPressed: _create,
                          style: FilledButton.styleFrom(
                            minimumSize: const Size(0, 44),
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                          ),
                          child: const Text('Create'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'My Barkada',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppColors.ink),
                        ),
                      ),
                      WireframePill(label: 'Search', icon: Icons.search, onTap: _openSearch),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (_filtered.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 32),
                      child: EmptyState(
                        emoji: '👥',
                        title: 'No barkada yet',
                        subtitle: 'Tap Create to start a group outing.',
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
