import '../domain/workout_place.dart';

class WorkoutPlaceService {
  Future<List<WorkoutPlace>> searchPlaces({
    required String query,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    final allPlaces = const [
      WorkoutPlace(
        id: '1',
        name: 'Athens Iron Gym',
        address: 'Patision 120, Athens',
        latitude: 37.9900,
        longitude: 23.7300,
        type: 'Gym',
        rating: 4.6,
      ),
      WorkoutPlace(
        id: '2',
        name: 'CityFit Studio',
        address: 'Panepistimiou 55, Athens',
        latitude: 37.9830,
        longitude: 23.7330,
        type: 'Fitness Studio',
        rating: 4.4,
      ),
      WorkoutPlace(
        id: '3',
        name: 'Olympus Cross Training',
        address: 'Kallidromiou 18, Athens',
        latitude: 37.9870,
        longitude: 23.7280,
        type: 'Cross Training',
        rating: 4.7,
      ),
    ];

    if (query.trim().isEmpty) {
      return allPlaces;
    }

    return allPlaces.where((place) {
      final q = query.toLowerCase();
      return place.name.toLowerCase().contains(q) ||
          place.address.toLowerCase().contains(q) ||
          place.type.toLowerCase().contains(q);
    }).toList();
  }
}