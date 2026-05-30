import 'fitness_profile.dart';

class AppUser {
  final String id;
  final String username;
  final String email;
  final String password;
  final String role;
  final bool premiumEnabled;
  final String? selectedCoachId;
  final FitnessProfile profile;

  const AppUser({
    required this.id,
    required this.username,
    required this.email,
    required this.password,
    required this.role,
    required this.premiumEnabled,
    required this.selectedCoachId,
    required this.profile,
  });

  bool get isCoach => role == 'coach';
  bool get isUser => role == 'user';

  factory AppUser.fromJson(Map<String, dynamic> json) {
    final email = json['email'] as String;
    final username = json['username'] as String? ??
        email.split('@').first.replaceAll(RegExp(r'[^a-zA-Z0-9_]'), '');
    return AppUser(
      id: json['id'] as String,
      username: username,
      email: email,
      password: json['password'] as String,
      role: json['role'] as String,
      premiumEnabled: json['premiumEnabled'] as bool? ?? false,
      selectedCoachId: json['selectedCoachId'] as String?,
      profile:
          FitnessProfile.fromJson(json['profile'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        'email': email,
        'password': password,
        'role': role,
        'premiumEnabled': premiumEnabled,
        'selectedCoachId': selectedCoachId,
        'profile': profile.toJson(),
      };

  AppUser copyWith({
    String? id,
    String? username,
    String? email,
    String? password,
    String? role,
    bool? premiumEnabled,
    Object? selectedCoachId = _noValue,
    FitnessProfile? profile,
  }) {
    return AppUser(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      premiumEnabled: premiumEnabled ?? this.premiumEnabled,
      selectedCoachId: selectedCoachId == _noValue
          ? this.selectedCoachId
          : selectedCoachId as String?,
      profile: profile ?? this.profile,
    );
  }
}

const Object _noValue = Object();