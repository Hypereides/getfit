import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../domain/app_user.dart';

class MockAuthService {
  List<AppUser> _users = [];

  List<AppUser> get users => List.unmodifiable(_users);

  Future<void> loadSeedUsers() async {
    if (_users.isNotEmpty) return;

    final jsonString = await rootBundle.loadString('assets/mock/users.json');
    final List<dynamic> decoded = jsonDecode(jsonString) as List<dynamic>;

    _users = decoded
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AppUser?> login({
    required String email,
    required String password,
  }) async {
    await loadSeedUsers();

    try {
      return _users.firstWhere(
        (u) => u.email == email.trim() && u.password == password.trim(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<AppUser> register({
    required String email,
    required String password,
    required FitnessProfile profile,
  }) async {
    await loadSeedUsers();

    final exists = _users.any((u) => u.email.toLowerCase() == email.toLowerCase());
    if (exists) {
      throw Exception('Email already exists');
    }

    final user = AppUser(
      id: 'user_${_users.length + 1}',
      email: email.trim(),
      password: password.trim(),
      role: 'user',
      premiumEnabled: false,
      selectedCoachId: null,
      profile: profile,
    );

    _users.add(user);
    return user;
  }

  List<AppUser> getCoaches() {
    return _users.where((u) => u.role == 'coach').toList();
  }

  List<AppUser> getCoachClients(String coachId) {
    return _users
        .where((u) =>
            u.role == 'user' &&
            u.premiumEnabled &&
            u.selectedCoachId == coachId)
        .toList();
  }

  AppUser updateUser(AppUser updatedUser) {
    final index = _users.indexWhere((u) => u.id == updatedUser.id);
    if (index == -1) throw Exception('User not found');

    _users[index] = updatedUser;
    return _users[index];
  }
}