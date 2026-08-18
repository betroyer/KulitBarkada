import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/auth_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/formatters.dart';
import '../../widgets/widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _profileKey = GlobalKey<FormState>();
  final _passwordKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _username;
  final _current = TextEditingController();
  final _next = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthState>().user!;
    _fullName = TextEditingController(text: user.fullName);
    _username = TextEditingController(text: user.username);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _username.dispose();
    _current.dispose();
    _next.dispose();
    _confirm.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_profileKey.currentState!.validate()) return;
    final error = await context.read<AuthState>().updateProfile(
          fullName: _fullName.text,
          username: _username.text,
        );
    if (!mounted) return;
    showSnack(context, error ?? 'Profile updated.', error: error != null);
  }

  Future<void> _savePassword() async {
    if (!_passwordKey.currentState!.validate()) return;
    final error = await context.read<AuthState>().changePassword(
          currentPassword: _current.text,
          newPassword: _next.text,
        );
    if (!mounted) return;
    if (error != null) {
      showSnack(context, error, error: true);
      return;
    }
    _current.clear();
    _next.clear();
    _confirm.clear();
    showSnack(context, 'Password changed.');
  }

  Future<void> _logout() async {
    final ok = await confirmAction(
      context,
      title: 'Log out?',
      message: 'You can sign back in anytime using this device account.',
      confirmLabel: 'Logout',
    );
    if (!ok || !mounted) return;
    await context.read<AuthState>().logout();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthState>().user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          SectionCard(
            child: Row(
              children: [
                AvatarCircle(initials: initials(user.fullName), color: AppColors.primary),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.fullName, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                      Text('@${user.username}', style: const TextStyle(color: AppColors.muted)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text('Edit profile', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          Form(
            key: _profileKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _fullName,
                  decoration: const InputDecoration(labelText: 'Full name'),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _username,
                  decoration: const InputDecoration(labelText: 'Username'),
                  validator: (v) => (v == null || v.trim().length < 3) ? 'At least 3 characters' : null,
                ),
                const SizedBox(height: 12),
                FilledButton(onPressed: _saveProfile, child: const Text('Save profile')),
              ],
            ),
          ),
          const SizedBox(height: 28),
          const Text('Change password', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          const SizedBox(height: 10),
          Form(
            key: _passwordKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _current,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Current password'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _next,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'New password'),
                  validator: (v) => (v == null || v.length < 4) ? 'At least 4 characters' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirm,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: 'Confirm new password'),
                  validator: (v) => v != _next.text ? 'Passwords do not match' : null,
                ),
                const SizedBox(height: 12),
                OutlinedButton(onPressed: _savePassword, child: const Text('Update password')),
              ],
            ),
          ),
          const SizedBox(height: 28),
          OutlinedButton(
            onPressed: _logout,
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
