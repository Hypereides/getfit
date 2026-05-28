class ProgressEntry {
  final String id;
  final DateTime date;
  final double weightKg;
  final double? bodyFatPercent;

  const ProgressEntry({
    required this.id,
    required this.date,
    required this.weightKg,
    this.bodyFatPercent,
  });
}