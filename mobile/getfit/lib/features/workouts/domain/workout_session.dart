import 'workout_entry.dart';

class WorkoutSession {
  final String id;
  final DateTime createdAt;
  final List<WorkoutEntry> entries;

  const WorkoutSession({
    required this.id,
    required this.createdAt,
    required this.entries,
  });

  double get totalEstimatedCalories {
    return entries.fold(0, (sum, item) => sum + item.estimatedCalories);
  }

  int get totalActivities => entries.length;
}