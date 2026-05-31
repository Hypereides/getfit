import 'dart:convert';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart' show MissingPluginException;
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import '../domain/location.dart';
import '../domain/workout_place.dart';

class WorkoutPlaceService {
  static const String _overpassUrl =
      'https://overpass-api.de/api/interpreter';
  static const int _radiusMeters = 3000;
  Future<WorkoutPlaceResult> getWorkoutPlacesWithinDistanceFromLocation() async {
    final location = await _getCurrentLocation();
    final (lat, lng) = location.getCoordinates();
    final places = await _fetchNearbyWorkoutPlaces(lat, lng);

    return WorkoutPlaceResult(
      open: places.where((p) => p.isOpenNow == true).toList(),
      closed: places.where((p) => p.isOpenNow == false).toList(),
      unknownHours: places.where((p) => p.isOpenNow == null).toList(),
      userLat: lat,
      userLng: lng,
    );
  }

  Future<WorkoutPlace> fetchPlaceDetails(WorkoutPlace place) async => place;

  Future<Location> _getCurrentLocation() async {
    try {
      if (!kIsWeb) {
        final serviceEnabled = await Geolocator.isLocationServiceEnabled();
        if (!serviceEnabled) throw LocationServiceDisabledException();
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationPermissionDeniedException(isPermanent: true);
      }
      if (permission == LocationPermission.denied) {
        throw const LocationPermissionDeniedException(isPermanent: false);
      }

      final pos = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );

      final location = Location();
      location.setCoordinates(pos.latitude, pos.longitude);
      return location;

    } on LocationServiceDisabledException {
      rethrow;
    } on LocationPermissionDeniedException {
      rethrow;
    } on MissingPluginException {
      throw const PlacesApiException(
        'GPS is not available in the browser.\n'
        'Please open GetFit on an Android or iOS device.',
      );
    }
  }

  Future<List<WorkoutPlace>> _fetchNearbyWorkoutPlaces(
    double lat,
    double lng,
  ) async {
    final query = '''
[out:json][timeout:30];
(
  node["leisure"="fitness_centre"](around:$_radiusMeters,$lat,$lng);
  way["leisure"="fitness_centre"](around:$_radiusMeters,$lat,$lng);
  node["leisure"="sports_centre"](around:$_radiusMeters,$lat,$lng);
  way["leisure"="sports_centre"](around:$_radiusMeters,$lat,$lng);
  node["sport"="crossfit"](around:$_radiusMeters,$lat,$lng);
  way["sport"="crossfit"](around:$_radiusMeters,$lat,$lng);
  node["sport"="fitness"](around:$_radiusMeters,$lat,$lng);
  way["sport"="fitness"](around:$_radiusMeters,$lat,$lng);
);
out center tags;
''';

    final uri = Uri.parse(_overpassUrl)
        .replace(queryParameters: {'data': query});

    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
      'User-Agent': 'GetFitApp/1.0 (Flutter)',
    }).timeout(const Duration(seconds: 35));

    if (response.statusCode != 200) {
      throw PlacesApiException('HTTP ${response.statusCode}');
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final elements = body['elements'] as List<dynamic>? ?? [];

    final seen = <String>{};
    final places = <WorkoutPlace>[];

    for (final el in elements) {
      final place = _parseElement(el as Map<String, dynamic>);
      if (place != null && seen.add(place.id)) {
        places.add(place);
      }
    }

    places.sort((a, b) {
      int rank(bool? v) => v == true ? 0 : v == null ? 1 : 2;
      return rank(a.isOpenNow).compareTo(rank(b.isOpenNow));
    });

    return places;
  }

  WorkoutPlace? _parseElement(Map<String, dynamic> el) {
    final tags = (el['tags'] as Map<String, dynamic>?) ?? {};
    final name = (tags['name'] as String? ?? '').trim();
    if (name.isEmpty) return null;

    double? lat, lng;
    if (el['type'] == 'node') {
      lat = (el['lat'] as num?)?.toDouble();
      lng = (el['lon'] as num?)?.toDouble();
    } else {
      final center = el['center'] as Map<String, dynamic>?;
      lat = (center?['lat'] as num?)?.toDouble();
      lng = (center?['lon'] as num?)?.toDouble();
    }
    if (lat == null || lng == null) return null;

    final openingHoursStr = tags['opening_hours'] as String?;

    final houseNo = tags['addr:housenumber'] as String?;
    final street  = tags['addr:street']      as String?;
    final city    = tags['addr:city']        as String?;
    final address = [
      if (street != null) '${houseNo != null ? '$houseNo ' : ''}$street',
      ?city,
    ].join(', ');

    return WorkoutPlace(
      id: '${el['type']}_${el['id']}',
      name: name,
      address: address,
      latitude: lat,
      longitude: lng,
      type: _inferType(tags),
      isOpenNow: _isCurrentlyOpen(openingHoursStr),
      openingHours: openingHoursStr,
      phoneNumber: (tags['phone']          as String?) ??
                   (tags['contact:phone']  as String?),
      website:     (tags['website']         as String?) ??
                   (tags['contact:website'] as String?),
    );
  }

  String _inferType(Map<String, dynamic> tags) {
    final sport   = tags['sport']   as String? ?? '';
    final leisure = tags['leisure'] as String? ?? '';
    if (sport.contains('crossfit'))  return 'CrossFit Box';
    if (leisure == 'sports_centre')  return 'Sports Centre';
    if (leisure == 'fitness_centre') return 'Gym';
    if (sport.contains('fitness'))   return 'Fitness Centre';
    return 'Fitness Facility';
  }

  bool? _isCurrentlyOpen(String? hoursStr) {
    if (hoursStr == null || hoursStr.trim().isEmpty) return null;
    final s = hoursStr.trim().toLowerCase();
    if (s == '24/7')   return true;
    if (s == 'closed') return false;

    final now      = DateTime.now();
    final todayIdx = now.weekday - 1;
    final nowMin   = now.hour * 60 + now.minute;

    for (final rule in s.split(';')) {
      final r = rule.trim();
      if (r.isEmpty) continue;
      final timeRx = RegExp(r'(\d{1,2}:\d{2})-(\d{1,2}:\d{2})');
      final tm = timeRx.firstMatch(r);
      if (tm == null) continue;
      final openMin  = _toMinutes(tm.group(1)!);
      var   closeMin = _toMinutes(tm.group(2)!);
      if (closeMin == 0) closeMin = 24 * 60;
      if (_dayApplies(r.substring(0, tm.start).trim(), todayIdx)) {
        return nowMin >= openMin && nowMin < closeMin;
      }
    }
    return null;
  }

  bool _dayApplies(String dayPart, int todayIdx) {
    if (dayPart.isEmpty) return true;
    const abbr = ['mo', 'tu', 'we', 'th', 'fr', 'sa', 'su'];
    final rm = RegExp(r'^([a-z]{2})-([a-z]{2})$').firstMatch(dayPart);
    if (rm != null) {
      final from = abbr.indexOf(rm.group(1)!);
      final to   = abbr.indexOf(rm.group(2)!);
      if (from != -1 && to != -1) {
        if (from <= to) return todayIdx >= from && todayIdx <= to;
        return todayIdx >= from || todayIdx <= to;
      }
    }
    return dayPart.split(',').map((d) => d.trim())
        .any((d) => abbr.indexOf(d) == todayIdx);
  }

  int _toMinutes(String hhmm) {
    final parts = hhmm.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }
}