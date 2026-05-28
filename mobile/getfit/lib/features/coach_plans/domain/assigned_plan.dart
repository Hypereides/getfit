class AssignedPlan {
  final String id;
  final String clientId;
  final String clientName;
  final String title;
  final String description;
  final int weeklyWorkouts;
  final int cardioDays;
  final int durationWeeks;
  final String nutritionNotes;
  final DateTime createdAt;
  final bool isUpdated;

  AssignedPlan({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.title,
    required this.description,
    required this.weeklyWorkouts,
    required this.cardioDays,
    required this.durationWeeks,
    required this.nutritionNotes,
    required this.createdAt,
    required this.isUpdated,
  });
}
class PlanRequest {
  final String clientId;
  final String clientName;
  final String coachId;
  final DateTime requestedAt;

  PlanRequest({
    required this.clientId,
    required this.clientName,
    required this.coachId,
    required this.requestedAt,
  });
}