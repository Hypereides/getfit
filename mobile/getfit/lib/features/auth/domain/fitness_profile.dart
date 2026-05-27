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