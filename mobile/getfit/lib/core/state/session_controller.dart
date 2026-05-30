import 'package:flutter/material.dart';

import '../../features/auth/data/mock_auth_service.dart';
import '../../features/auth/domain/app_user.dart';
import '../../features/auth/domain/fitness_profile.dart';

class SessionController extends ChangeNotifier {
  final MockAuthService _authService;

  SessionController(this._authService);

  AppUser? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;
  List<AppUser> _coaches = [];

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<AppUser> get coaches => List.unmodifiable(_coaches);
  List<AppUser> get users => _authService.users;
  bool get isLoggedIn => _currentUser != null;

  Future<void> initialize() async {
    await _authService.loadSeedUsers();
    _coaches = _authService.getCoaches();
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(email: email, password: password);
      _currentUser = user;
      _coaches = _authService.getCoaches();
      _isLoading = false;
      notifyListeners();
      return user != null;
    } catch (e) {
      _errorMessage = 'Login failed.';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
    required bool premiumEnabled,
    required FitnessProfile profile,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.register(
        email: email,
        password: password,
        username: username,
        premiumEnabled: premiumEnabled,
        profile: profile,
      );
      _currentUser = user;
      _coaches = _authService.getCoaches();
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  void logout() {
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }

  void togglePremium(bool enabled) {
    if (_currentUser == null) return;
    final updatedUser = _currentUser!.copyWith(
      premiumEnabled: enabled,
      selectedCoachId: enabled ? _currentUser!.selectedCoachId : null,
    );
    _currentUser = _authService.updateUser(updatedUser);
    _coaches = _authService.getCoaches();
    notifyListeners();
  }

  void selectCoach(String coachId) {
    if (_currentUser == null) return;
    final updatedUser = _currentUser!.copyWith(selectedCoachId: coachId);
    _currentUser = _authService.updateUser(updatedUser);
    _coaches = _authService.getCoaches();
    notifyListeners();
  }

  void updateProfile(FitnessProfile profile) {
    if (_currentUser == null) return;
    final updatedUser = _currentUser!.copyWith(profile: profile);
    _currentUser = _authService.updateUser(updatedUser);
    _coaches = _authService.getCoaches();
    notifyListeners();
  }
}