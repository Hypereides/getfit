class WorkoutPlace {
  final String id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String type;
  final bool? isOpenNow;
  final String? openingHours;
  final String? phoneNumber;
  final String? website;

  const WorkoutPlace({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.type,
    this.isOpenNow,
    this.openingHours,
    this.phoneNumber,
    this.website,
  });

  String get availableHours {
    if (openingHours != null && openingHours!.isNotEmpty) return openingHours!;
    if (isOpenNow == true) return 'Open now';
    if (isOpenNow == false) return 'Closed now';
    return 'Hours not listed';
  }
}

class WorkoutPlaceResult {
  final List<WorkoutPlace> open;
  final List<WorkoutPlace> closed;
  final List<WorkoutPlace> unknownHours;
  final double userLat;
  final double userLng;

  const WorkoutPlaceResult({
    required this.open,
    required this.closed,
    required this.unknownHours,
    required this.userLat,
    required this.userLng,
  });
}

class LocationPermissionDeniedException implements Exception {
  final bool isPermanent;
  const LocationPermissionDeniedException({this.isPermanent = false});
}

class PlacesApiException implements Exception {
  final String message;
  const PlacesApiException(this.message);
  @override
  String toString() => 'PlacesApiException: $message';
}