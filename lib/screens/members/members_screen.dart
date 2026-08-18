import 'package:flutter/material.dart';

import '../../data/models.dart';
import '../../data/repositories.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key, required this.groupId});

  final int groupId;

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  final _repo = MemberRepository();
  List<GroupMember> _items = [];

  @override
  void initState() {
    super.initState();
    _reload();
  }

  Future<void> _reload() async {
    final items = await _repo.list(widget.groupId);
    if (!mounted) return;
    setState(() => _items = items);
  }

  Future<void> _openForm({GroupMember? member}) async {
    final saved = await pushPage<bool>(
      context,
      MemberFormScreen(groupId: widget.groupId, member: member),
    );
    if (saved == true) _reload();
  }

  Future<void> _delete(GroupMember member) async {
    final ok = await confirmAction(
      context,
      title: 'Remove ${member.name}?',
      message: 'They will be removed from this group.',
    );
    if (!ok) return;
    await _repo.delete(member.id!);
    _reload();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${_items.length} Members')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.person_add_alt_1),
        label: const Text('Add member'),
      ),
      body: _items.isEmpty
          ? const EmptyState(
              emoji: '👤',
              title: 'No members yet',
              subtitle: 'Add your barkada manually. Invitation links are not needed offline.',
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
              itemCount: _items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final member = _items[index];
                return SectionCard(
                  child: ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: AvatarCircle(initials: initials(member.name), color: AppColors.members),
                    title: Text(member.name, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text(
                      [
                        member.role,
                        if (member.contact.isNotEmpty) member.contact,
                      ].join(' · '),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _openForm(member: member);
                        if (value == 'delete') _delete(member);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Edit')),
                        PopupMenuItem(value: 'delete', child: Text('Delete')),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}

class MemberFormScreen extends StatefulWidget {
  const MemberFormScreen({super.key, required this.groupId, this.member});

  final int groupId;
  final GroupMember? member;

  @override
  State<MemberFormScreen> createState() => _MemberFormScreenState();
}

class _MemberFormScreenState extends State<MemberFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _contact;
  late String _role;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.member?.name ?? '');
    _contact = TextEditingController(text: widget.member?.contact ?? '');
    _role = widget.member?.role ?? 'Member';
  }

  @override
  void dispose() {
    _name.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final member = GroupMember(
      id: widget.member?.id,
      groupId: widget.groupId,
      name: _name.text.trim(),
      contact: _contact.text.trim(),
      role: _role,
    );
    final repo = MemberRepository();
    if (widget.member == null) {
      await repo.insert(member);
    } else {
      await repo.update(member);
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.member == null ? 'Add member' : 'Edit member')),
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
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Name is required' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _contact,
                  decoration: const InputDecoration(labelText: 'Contact (optional)'),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: _role,
                  decoration: const InputDecoration(labelText: 'Role'),
                  items: const [
                    DropdownMenuItem(value: 'Organizer', child: Text('Organizer')),
                    DropdownMenuItem(value: 'Member', child: Text('Member')),
                  ],
                  onChanged: (value) => setState(() => _role = value ?? 'Member'),
                ),
                const SizedBox(height: 24),
                FilledButton(onPressed: _save, child: const Text('Save')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
