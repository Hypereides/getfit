//snapshot of health data
class HealthSnapshot {
  final int steps;
  final int activeMinutes;
  final double caloriesBurned;
  final double? heartRateAvg;
  final double? distanceKm;
  final DateTime fetchedAt;
  final bool isMockData;

  const HealthSnapshot({
    required this.steps,
    required this.activeMinutes,
    required this.caloriesBurned,
    this.heartRateAvg,
    this.distanceKm,
    required this.fetchedAt,
    this.isMockData = false,
  });
}