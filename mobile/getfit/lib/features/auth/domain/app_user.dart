class FitnessProfile {
  final String name;
  final int age;
  final String sex;
  final double heightCm;
  final double weightKg;
  final String goal;
  final String activityLevel;
  final double bmi;
  final double tdee;

  const FitnessProfile({
    required this.name,
    required this.age,
    required this.sex,
    required this.heightCm,
    required this.weightKg,
    required this.goal,
    required this.activityLevel,
    required this.bmi,
    required this.tdee,
  });

  factory FitnessProfile.fromJson(Map<String, dynamic> json) {
    return FitnessProfile(
      name: json['name'] as String,
      age: json['age'] as int,
      sex: json['sex'] as String,
      heightCm: (json['heightCm'] as num).toDouble(),
      weightKg: (json['weightKg'] as num).toDouble(),
      goal: json['goal'] as String,
      activityLevel: json['activityLevel'] as String,
      bmi: (json['bmi'] as num).toDouble(),
      tdee: (json['tdee'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'sex': sex,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'goal': goal,
        'activityLevel': activityLevel,
        'bmi': bmi,
        'tdee': tdee,
      };

  FitnessProfile copyWith({
    String? name,
    int? age,
    String? sex,
    double? heightCm,
    double? weightKg,
    String? goal,
    String? activityLevel,
    double? bmi,
    double? tdee,
  }) {
    return FitnessProfile(
      name: name ?? this.name,
      age: age ?? this.age,
      sex: sex ?? this.sex,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      goal: goal ?? this.goal,
      activityLevel: activityLevel ?? this.activityLevel,
      bmi: bmi ?? this.bmi,
      tdee: tdee ?? this.tdee,
    );
  }
}

class AppUser {
  final String id;
  final String email;
  final String password;
  final String role;
  final bool premiumEnabled;
  final String? selectedCoachId;
  final FitnessProfile profile;

  const AppUser({
    required this.id,
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
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      password: json['password'] as String,
      role: json['role'] as String,
      premiumEnabled: json['premiumEnabled'] as bool? ?? false,
      selectedCoachId: json['selectedCoachId'] as String?,
      profile: FitnessProfile.fromJson(json['profile'] as Map<String, dynamic>),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'password': password,
        'role': role,
        'premiumEnabled': premiumEnabled,
        'selectedCoachId': selectedCoachId,
        'profile': profile.toJson(),
      };

  AppUser copyWith({
    String? id,
    String? email,
    String? password,
    String? role,
    bool? premiumEnabled,
    String? selectedCoachId,
    FitnessProfile? profile,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      password: password ?? this.password,
      role: role ?? this.role,
      premiumEnabled: premiumEnabled ?? this.premiumEnabled,
      selectedCoachId: selectedCoachId ?? this.selectedCoachId,
      profile: profile ?? this.profile,
    );
  }
}