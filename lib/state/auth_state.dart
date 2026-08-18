import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/models.dart';
import '../data/repositories.dart';
import '../utils/password.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._repo);

  final AuthRepository _repo;
  AppUser? _user;
  bool _ready = false;

  AppUser? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get ready => _ready;

  Future<void> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('user_id');
    if (id != null) {
      _user = await _repo.findById(id);
    }
    _ready = true;
    notifyListeners();
  }

  Future<void> _persist(int? id) async {
    final prefs = await SharedPreferences.getInstance();
    if (id == null) {
      await prefs.remove('user_id');
    } else {
      await prefs.setInt('user_id', id);
    }
  }

  Future<String?> register({
    required String fullName,
    required String username,
    required String password,
  }) async {
    if (await _repo.usernameTaken(username)) {
      return 'That username is already taken.';
    }
    final salt = PasswordHasher.randomSalt();
    final user = AppUser(
      fullName: fullName.trim(),
      username: username.trim(),
      passwordHash: PasswordHasher.hash(password, salt),
      salt: salt,
      createdAt: DateTime.now().toIso8601String(),
    );
    final id = await _repo.insert(user);
    _user = user.copyWith(id: id);
    await _persist(id);
    notifyListeners();
    return null;
  }

  Future<String?> login({
    required String username,
    required String password,
  }) async {
    final existing = await _repo.findByUsername(username);
    if (existing == null ||
        !PasswordHasher.verify(password, existing.salt, existing.passwordHash)) {
      return 'Incorrect username or password.';
    }
    _user = existing;
    await _persist(existing.id);
    notifyListeners();
    return null;
  }

  Future<String?> updateProfile({
    required String fullName,
    required String username,
  }) async {
    final current = _user;
    if (current == null || current.id == null) return 'Not logged in.';
    if (await _repo.usernameTaken(username, exceptId: current.id)) {
      return 'That username is already taken.';
    }
    final updated = current.copyWith(
      fullName: fullName.trim(),
      username: username.trim(),
    );
    await _repo.update(updated);
    _user = updated;
    notifyListeners();
    return null;
  }

  Future<String?> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final current = _user;
    if (current == null || current.id == null) return 'Not logged in.';
    if (!PasswordHasher.verify(currentPassword, current.salt, current.passwordHash)) {
      return 'Current password is incorrect.';
    }
    final salt = PasswordHasher.randomSalt();
    final updated = current.copyWith(
      salt: salt,
      passwordHash: PasswordHasher.hash(newPassword, salt),
    );
    await _repo.update(updated);
    _user = updated;
    notifyListeners();
    return null;
  }

  Future<void> logout() async {
    _user = null;
    await _persist(null);
    notifyListeners();
  }
}
