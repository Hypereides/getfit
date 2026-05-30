class WorkoutPlace {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type;
  final double rating;
  final int openingHour;
  final int closingHour;
  final String phone;
  final String description;
  final List<String> amenities;

  const WorkoutPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    required this.rating,
    this.openingHour = 6,
    this.closingHour = 22,
    this.phone = '',
    this.description = '',
    this.amenities = const [],
  });

  bool isOpenAt(int hour) {
    if (closingHour > openingHour) {
      return hour >= openingHour && hour < closingHour;
    }
    return hour >= openingHour || hour < closingHour;
  }

  String get availableHours {
    String fmt(int h) => '${h.toString().padLeft(2, '0')}:00';
    if (closingHour > openingHour) {
      return '${fmt(openingHour)} – ${fmt(closingHour)}';
    }
    return '${fmt(openingHour)} – ${fmt(closingHour)} (+1)';
  }
}

class WorkoutPlaceResult {
  final List<WorkoutPlace> open;
  final List<WorkoutPlace> closed;
  final double userLat;
  final double userLng;

  const WorkoutPlaceResult({
    required this.open,
    required this.closed,
    required this.userLat,
    required this.userLng,
  });
}