//saved weeklygoal.
class WeeklyGoal {
  final int targetSteps;
  final int targetActiveMinutes;
  final double targetCaloriesBurned;
  final int targetWorkouts;

  final DateTime createdAt;
  final bool isSystemSuggested;

  const WeeklyGoal({
    required this.targetSteps,
    required this.targetActiveMinutes,
    required this.targetCaloriesBurned,
    required this.targetWorkouts,
    required this.createdAt,
    required this.isSystemSuggested,
  });

  WeeklyGoal copyWith({
    int? targetSteps,
    int? targetActiveMinutes,
    double? targetCaloriesBurned,
    int? targetWorkouts,
  }) {
    return WeeklyGoal(
      targetSteps: targetSteps ?? this.targetSteps,
      targetActiveMinutes: targetActiveMinutes ?? this.targetActiveMinutes,
      targetCaloriesBurned: targetCaloriesBurned ?? this.targetCaloriesBurned,
      targetWorkouts: targetWorkouts ?? this.targetWorkouts,
      createdAt: createdAt,
      isSystemSuggested: false,
    );
  }
}