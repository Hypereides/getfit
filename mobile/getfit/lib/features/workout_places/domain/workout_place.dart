class WorkoutPlace {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type;
  final double rating;

  const WorkoutPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.rating,
  });
}