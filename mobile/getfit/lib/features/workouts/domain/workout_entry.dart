class WorkoutEntry {
  final String id;
  final String category;
  final String exercise;
  final int? sets;
  final int? reps;
  final double? weightKg;
  final int? durationMinutes;
  final String? intensity;
  final String? notes;
  final double estimatedCalories;

  const WorkoutEntry({
    required this.id,
    required this.category,
    required this.exercise,
    required this.estimatedCalories,
    this.sets,
    this.reps,
    this.weightKg,
    this.durationMinutes,
    this.intensity,
    this.notes,
  });

  bool get isStrength => category == 'Strength';
  bool get isCardio => category == 'Cardio';
}