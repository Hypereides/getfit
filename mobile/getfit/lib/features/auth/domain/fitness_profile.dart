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
  final double? bodyFatPercent;
  final String workoutPreferences;
  final double targetRateOfChange;
  final String country;
  final String city;

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
    this.bodyFatPercent,
    this.workoutPreferences = 'both',
    this.targetRateOfChange = 0.0,
    this.country = 'Greece',
    this.city = 'Athens',
  });

  double get targetDailyCalories {
    final dailyDelta = targetRateOfChange * 7700 / 7;
    return (tdee + dailyDelta).clamp(800.0, 6000.0);
  }

  factory FitnessProfile.fromJson(Map<String, dynamic> json) {
    final goal = json['goal'] as String? ?? 'maintain_weight';
    double defaultRate = 0.0;
    if (goal == 'lose_weight') defaultRate = -0.5;
    if (goal == 'gain_weight') defaultRate = 0.5;

    return FitnessProfile(
      name: json['name'] as String? ?? '',
      age: (json['age'] as num?)?.toInt() ?? 25,
      sex: json['sex'] as String? ?? 'male',
      heightCm: (json['heightCm'] as num?)?.toDouble() ?? 170,
      weightKg: (json['weightKg'] as num?)?.toDouble() ?? 70,
      goal: goal,
      activityLevel: json['activityLevel'] as String? ?? 'moderately_active',
      bmi: (json['bmi'] as num?)?.toDouble() ?? 22.0,
      tdee: (json['tdee'] as num?)?.toDouble() ?? 2000.0,
      bodyFatPercent: (json['bodyFatPercent'] as num?)?.toDouble(),
      workoutPreferences: json['workoutPreferences'] as String? ?? 'both',
      targetRateOfChange:
          (json['targetRateOfChange'] as num?)?.toDouble() ?? defaultRate,
      country: json['country'] as String? ?? 'Greece',
      city: json['city'] as String? ?? 'Athens',
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
        'bodyFatPercent': bodyFatPercent,
        'workoutPreferences': workoutPreferences,
        'targetRateOfChange': targetRateOfChange,
        'country': country,
        'city': city,
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
    Object? bodyFatPercent = _noValue,
    String? workoutPreferences,
    double? targetRateOfChange,
    String? country,
    String? city,
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
      bodyFatPercent: bodyFatPercent == _noValue
          ? this.bodyFatPercent
          : bodyFatPercent as double?,
      workoutPreferences: workoutPreferences ?? this.workoutPreferences,
      targetRateOfChange: targetRateOfChange ?? this.targetRateOfChange,
      country: country ?? this.country,
      city: city ?? this.city,
    );
  }
}

const Object _noValue = Object();