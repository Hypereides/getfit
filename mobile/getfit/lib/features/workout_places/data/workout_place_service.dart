import '../../../core/data/country_city_data.dart';
import '../domain/workout_place.dart';

class WorkoutPlaceService {
  Future<WorkoutPlaceResult> getWorkoutPlacesWithinDistanceFromLocation({
    required String city,
  }) async {
    await Future.delayed(const Duration(milliseconds: 900));

    final userLat = CountryCityData.latitudeFor(city);
    final userLng = CountryCityData.longitudeFor(city);

    final allPlaces = _placesFor(city);
    final now = DateTime.now().hour;

    return WorkoutPlaceResult(
      open: allPlaces.where((p) => p.isOpenAt(now)).toList(),
      closed: allPlaces.where((p) => !p.isOpenAt(now)).toList(),
      userLat: userLat,
      userLng: userLng,
    );
  }

  static List<WorkoutPlace> _placesFor(String city) {
    final c = city.toLowerCase();

    if (['athens', 'thessaloniki', 'patras', 'heraklion', 'larissa'].contains(c)) {
      return _athensPlaces;
    }
    if (['nicosia', 'limassol', 'larnaca', 'paphos'].contains(c)) {
      return _cyprusPlaces;
    }
    if (['london', 'manchester', 'birmingham', 'edinburgh', 'glasgow'].contains(c)) {
      return _londonPlaces;
    }
    if (['berlin', 'munich', 'hamburg', 'frankfurt', 'cologne'].contains(c)) {
      return _berlinPlaces;
    }
    if (['paris', 'lyon', 'marseille', 'toulouse', 'nice'].contains(c)) {
      return _parisPlaces;
    }
    return _genericPlaces;
  }

  static const _athensPlaces = [
    WorkoutPlace(
      id: 'ath1',
      name: 'Iron Gym Athens',
      address: 'Patision 120, Athens',
      latitude: 37.9900, longitude: 23.7300,
      type: 'Gym', rating: 4.6,
      openingHour: 6, closingHour: 23,
      phone: '+30 210 555 0101',
      description: 'Full-equipped commercial gym with free weights, machines, cardio equipment and personal training services.',
      amenities: ['Free Weights', 'Machines', 'Cardio Zone', 'Showers', 'Lockers', 'Personal Training'],
    ),
    WorkoutPlace(
      id: 'ath2',
      name: 'CityFit Studio',
      address: 'Panepistimiou 55, Athens',
      latitude: 37.9830, longitude: 23.7330,
      type: 'Fitness Studio', rating: 4.4,
      openingHour: 7, closingHour: 21,
      phone: '+30 210 555 0202',
      description: 'Boutique fitness studio offering group classes including HIIT, yoga, pilates and spin cycling.',
      amenities: ['Group Classes', 'Yoga', 'HIIT', 'Spinning', 'Showers'],
    ),
    WorkoutPlace(
      id: 'ath3',
      name: 'Olympus CrossFit',
      address: 'Kallidromiou 18, Athens',
      latitude: 37.9870, longitude: 23.7280,
      type: 'CrossFit Box', rating: 4.8,
      openingHour: 6, closingHour: 22,
      phone: '+30 210 555 0303',
      description: 'Certified CrossFit affiliate with experienced coaches, daily WODs and open gym sessions.',
      amenities: ['CrossFit', 'Olympic Lifting', 'Open Gym', 'Coaching', 'Showers'],
    ),
    WorkoutPlace(
      id: 'ath4',
      name: 'Acropolis Running Track',
      address: 'Filopappou Hill, Athens',
      latitude: 37.9680, longitude: 23.7220,
      type: 'Outdoor Track', rating: 4.9,
      openingHour: 6, closingHour: 20,
      phone: '',
      description: 'Free outdoor running track with stunning views of the Acropolis. Popular with morning and evening runners.',
      amenities: ['Running Track', 'Outdoor', 'Free Access', 'Scenic Views'],
    ),
    WorkoutPlace(
      id: 'ath5',
      name: 'Late Night Fitness 24',
      address: 'Vouliagmenis 200, Athens',
      latitude: 37.9750, longitude: 23.7400,
      type: 'Gym', rating: 4.2,
      openingHour: 16, closingHour: 2,
      phone: '+30 210 555 0505',
      description: 'Night-owl friendly gym open late. Full free weights area, cardio and functional training zone.',
      amenities: ['Free Weights', 'Cardio Zone', 'Functional Training', 'Lockers'],
    ),
  ];

  static const _cyprusPlaces = [
    WorkoutPlace(
      id: 'cy1',
      name: 'Aphrodite Fitness Club',
      address: 'Makariou Ave 45, Limassol',
      latitude: 34.6841, longitude: 33.0464,
      type: 'Gym', rating: 4.5,
      openingHour: 6, closingHour: 23,
      phone: '+357 25 555 001',
      description: 'Premium fitness club with state-of-the-art equipment, swimming pool and spa facilities.',
      amenities: ['Free Weights', 'Pool', 'Spa', 'Cardio Zone', 'Personal Training', 'Showers'],
    ),
    WorkoutPlace(
      id: 'cy2',
      name: 'Nicosia Urban Gym',
      address: 'Ledra St 88, Nicosia',
      latitude: 35.1856, longitude: 33.3823,
      type: 'Gym', rating: 4.3,
      openingHour: 7, closingHour: 22,
      phone: '+357 22 555 002',
      description: 'Central city gym catering to all fitness levels with strength, cardio and group class areas.',
      amenities: ['Free Weights', 'Machines', 'Group Classes', 'Showers', 'Lockers'],
    ),
  ];

  static const _londonPlaces = [
    WorkoutPlace(
      id: 'lon1',
      name: 'PureGym London Central',
      address: 'Oxford St 200, London',
      latitude: 51.5145, longitude: -0.1442,
      type: 'Gym', rating: 4.3,
      openingHour: 5, closingHour: 23,
      phone: '+44 20 7946 0001',
      description: '24-hour accessible gym with extensive equipment, no contracts required. Great for all levels.',
      amenities: ['Free Weights', 'Machines', 'Cardio Zone', 'Classes', 'Showers'],
    ),
    WorkoutPlace(
      id: 'lon2',
      name: 'Battersea Park Athletics Track',
      address: 'Battersea Park, London',
      latitude: 51.4815, longitude: -0.1564,
      type: 'Outdoor Track', rating: 4.7,
      openingHour: 7, closingHour: 20,
      phone: '+44 20 7946 0002',
      description: 'Outdoor athletics track within Battersea Park, open to the public for running and training.',
      amenities: ['Running Track', 'Outdoor', 'Free Access', 'Park Views'],
    ),
  ];

  static const _berlinPlaces = [
    WorkoutPlace(
      id: 'ber1',
      name: 'McFit Berlin Mitte',
      address: 'Alexanderplatz 5, Berlin',
      latitude: 52.5219, longitude: 13.4132,
      type: 'Gym', rating: 4.1,
      openingHour: 24, closingHour: 24,
      phone: '+49 30 555 0001',
      description: 'Budget-friendly 24-hour gym with all essential equipment. No frills, just results.',
      amenities: ['Free Weights', 'Machines', 'Cardio Zone', 'Showers', '24h Access'],
    ),
    WorkoutPlace(
      id: 'ber2',
      name: 'Tempelhof Outdoor Track',
      address: 'Tempelhofer Feld, Berlin',
      latitude: 52.4733, longitude: 13.4016,
      type: 'Outdoor Track', rating: 4.9,
      openingHour: 6, closingHour: 20,
      phone: '',
      description: 'Massive outdoor space at the former Tempelhof airport — perfect for running, cycling and calisthenics.',
      amenities: ['Running Track', 'Outdoor', 'Free Access', 'Calisthenics', 'Cycling'],
    ),
  ];

  static const _parisPlaces = [
    WorkoutPlace(
      id: 'par1',
      name: 'KeepCool Paris République',
      address: 'Bd Voltaire 30, Paris',
      latitude: 48.8637, longitude: 2.3714,
      type: 'Gym', rating: 4.2,
      openingHour: 7, closingHour: 23,
      phone: '+33 1 55 00 01 01',
      description: 'Modern chain gym with extensive equipment, virtual coaching and unlimited group classes.',
      amenities: ['Free Weights', 'Machines', 'Group Classes', 'Sauna', 'Showers'],
    ),
    WorkoutPlace(
      id: 'par2',
      name: 'CrossFit Paris Nation',
      address: 'Rue de la Nation 15, Paris',
      latitude: 48.8484, longitude: 2.3958,
      type: 'CrossFit Box', rating: 4.7,
      openingHour: 6, closingHour: 21,
      phone: '+33 1 55 00 02 02',
      description: 'Top-rated CrossFit box with experienced bilingual coaches and a warm community atmosphere.',
      amenities: ['CrossFit', 'Olympic Lifting', 'Open Gym', 'Coaching'],
    ),
  ];

  static const _genericPlaces = [
    WorkoutPlace(
      id: 'gen1',
      name: 'City Fitness Center',
      address: 'Main Street 1, City Center',
      latitude: 37.9838, longitude: 23.7275,
      type: 'Gym', rating: 4.3,
      openingHour: 6, closingHour: 22,
      phone: '+1 555 000 0001',
      description: 'Well-equipped gym serving the local community with strength, cardio and group fitness options.',
      amenities: ['Free Weights', 'Machines', 'Cardio Zone', 'Showers'],
    ),
    WorkoutPlace(
      id: 'gen2',
      name: 'Urban CrossFit',
      address: 'Industrial Zone 5, City',
      latitude: 37.9900, longitude: 23.7400,
      type: 'CrossFit Box', rating: 4.6,
      openingHour: 7, closingHour: 21,
      phone: '+1 555 000 0002',
      description: 'Community-driven CrossFit box with daily programming and all-level coaching.',
      amenities: ['CrossFit', 'Olympic Lifting', 'Open Gym'],
    ),
    WorkoutPlace(
      id: 'gen3',
      name: 'Riverside Running Park',
      address: 'Riverside Promenade, City',
      latitude: 37.9750, longitude: 23.7100,
      type: 'Outdoor Track', rating: 4.8,
      openingHour: 5, closingHour: 21,
      phone: '',
      description: 'Scenic riverside outdoor running track and calisthenics park, free and open to all.',
      amenities: ['Running Track', 'Outdoor', 'Free Access', 'Calisthenics'],
    ),
  ];
}