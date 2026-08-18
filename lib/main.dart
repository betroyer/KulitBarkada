import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/repositories.dart';
import 'screens/auth/login_screen.dart';
import 'screens/groups/groups_screen.dart';
import 'state/auth_state.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const BarkadaPlanApp());
}

class BarkadaPlanApp extends StatelessWidget {
  const BarkadaPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState(AuthRepository())..restore(),
      child: MaterialApp(
        title: 'Barkada Plan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        home: const _AuthGate(),
      ),
    );
  }
}

class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthState>();
    if (!auth.ready) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (auth.isLoggedIn) return const GroupsScreen();
    return const LoginScreen();
  }
}
