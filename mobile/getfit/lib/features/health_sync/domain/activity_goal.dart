class ActivityGoal {
  final int targetSteps;
  final int targetActiveMinutes;
  final double targetCaloriesBurned;
  final int targetWorkouts;
  final DateTime createdAt;
  final bool isSystemSuggested;

  const ActivityGoal({
    required this.targetSteps,
    required this.targetActiveMinutes,
    required this.targetCaloriesBurned,
    required this.targetWorkouts,
    required this.createdAt,
    required this.isSystemSuggested,
  });

  ActivityGoal copyWith({
    int? targetSteps,
    int? targetActiveMinutes,
    double? targetCaloriesBurned,
    int? targetWorkouts,
  }) {
    return ActivityGoal(
      targetSteps: targetSteps ?? this.targetSteps,
      targetActiveMinutes: targetActiveMinutes ?? this.targetActiveMinutes,
      targetCaloriesBurned: targetCaloriesBurned ?? this.targetCaloriesBurned,
      targetWorkouts: targetWorkouts ?? this.targetWorkouts,
      createdAt: createdAt,
      isSystemSuggested: false,
    );
  }
}