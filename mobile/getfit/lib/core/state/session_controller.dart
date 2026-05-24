import 'package:flutter/foundation.dart';
import '../../features/auth/data/mock_auth_service.dart';
import '../../features/auth/domain/app_user.dart';

class SessionController extends ChangeNotifier {
  SessionController(this._authService);

  final MockAuthService _authService;

  AppUser? _currentUser;
  AppUser? get currentUser => _currentUser;

  List<AppUser> get coaches => _authService.getCoaches();

  Future<bool> login(String email, String password) async {
    final user = await _authService.login(email: email, password: password);
    if (user == null) return false;

    _currentUser = user;
    notifyListeners();
    return true;
  }

  Future<void> register({
    required String email,
    required String password,
    required FitnessProfile profile,
  }) async {
    _currentUser = await _authService.register(
      email: email,
      password: password,
      profile: profile,
    );
    notifyListeners();
  }

  void logout() {
    _currentUser = null;
    notifyListeners();
  }

  void togglePremium(bool enabled) {
    if (_currentUser == null) return;

    _currentUser = _authService.updateUser(
      _currentUser!.copyWith(
        premiumEnabled: enabled,
        selectedCoachId: enabled ? _currentUser!.selectedCoachId : null,
      ),
    );
    notifyListeners();
  }

  void selectCoach(String coachId) {
    if (_currentUser == null || !_currentUser!.premiumEnabled) return;

    _currentUser = _authService.updateUser(
      _currentUser!.copyWith(selectedCoachId: coachId),
    );
    notifyListeners();
  }

  List<AppUser> clientsForCurrentCoach() {
    if (_currentUser == null || !_currentUser!.isCoach) return [];
    return _authService.getCoachClients(_currentUser!.id);
  }
}