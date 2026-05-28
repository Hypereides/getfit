import 'package:flutter/material.dart';
import 'package:health/health.dart';

import '../../auth/domain/fitness_profile.dart';
import '../domain/health_snapshot.dart';
import '../domain/weekly_goal.dart';

enum FitConnectionStatus {
  disconnected,
  connecting,
  connected,
  permissionDenied,
  error,
}

class HealthSyncController extends ChangeNotifier {
  FitConnectionStatus _status = FitConnectionStatus.disconnected;
  HealthSnapshot? _snapshot;
  WeeklyGoal? _weeklyGoal;
  WeeklyGoal? _suggestedGoal;
  String? _errorMessage;

  FitConnectionStatus get status => _status;
  HealthSnapshot? get snapshot => _snapshot;
  WeeklyGoal? get weeklyGoal => _weeklyGoal;
  WeeklyGoal? get suggestedGoal => _suggestedGoal;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _status == FitConnectionStatus.connected;

  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.HEART_RATE,
    HealthDataType.DISTANCE_WALKING_RUNNING,
  ];

  Future<void> connect() async {
    _status = FitConnectionStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    try {
      final health = Health();
      await health.configure();

      final permissions = List.filled(_types.length, HealthDataAccess.READ);
      final authorized = await health.requestAuthorization(
        _types,
        permissions: permissions,
      );

      if (!authorized) {
        _status = FitConnectionStatus.permissionDenied;
        notifyListeners();
        return;
      }

      await _fetchRealData(health);
      _status = FitConnectionStatus.connected;
    } catch (_) {
      await _loadDemoData();
      _status = FitConnectionStatus.connected;
    }

    notifyListeners();
  }
  Future<void> _fetchRealData(Health health) async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);

    final raw = await health.getHealthDataFromTypes(
      startTime: startOfDay,
      endTime: now,
      types: _types,
    );

    final points = health.removeDuplicates(raw);

    double steps = 0;
    double calories = 0;
    double heartSum = 0;
    int heartCount = 0;
    double distanceM = 0;

    for (final p in points) {
      final v = _numericValue(p);
      switch (p.type) {
        case HealthDataType.STEPS:
          steps += v;
        case HealthDataType.ACTIVE_ENERGY_BURNED:
          calories += v;
        case HealthDataType.HEART_RATE:
          heartSum += v;
          heartCount++;
        case HealthDataType.DISTANCE_WALKING_RUNNING:
          distanceM += v;
        default:
          break;
      }
    }
    final activeMinutes = steps > 0 ? (steps / 100).round() : 0;
  //no meaningful data are to be fetched since this is simply for our uni project thus there will be a demo snapshot
    if (steps == 0 && calories == 0) {
      await _loadDemoData();
      return;
    }

    _snapshot = HealthSnapshot(
      steps: steps.round(),
      activeMinutes: activeMinutes,
      caloriesBurned: calories,
      heartRateAvg: heartCount > 0 ? heartSum / heartCount : null,
      distanceKm: distanceM > 0 ? distanceM / 1000 : null,
      fetchedAt: now,
      isMockData: false,
    );
  }

  Future<void> _loadDemoData() async {
    await Future.delayed(const Duration(milliseconds: 800));
    _snapshot = HealthSnapshot(
      steps: 7842,
      activeMinutes: 54,
      caloriesBurned: 348,
      heartRateAvg: 71,
      distanceKm: 5.9,
      fetchedAt: DateTime.now(),
      isMockData: true,
    );
  }

  Future<void> refresh() async {
    if (!isConnected) return;
    try {
      final health = Health();
      await _fetchRealData(health);
    } catch (_) {
      await _loadDemoData();
    }
    notifyListeners();
  }
  WeeklyGoal generateSuggestion(FitnessProfile profile) {
    final dailySteps = switch (profile.goal) {
      'lose_weight' => 10000,
      'maintain_weight' => 8000,
      'gain_weight' => 6000,
      _ => 8000,
    };

    final weeklyActiveMin = switch (profile.goal) {
      'lose_weight' => 250,
      'maintain_weight' => 150,//all data fetched from world health orrganization 
      'gain_weight' => 120,
      _ => 150,
    };

    final workouts = switch (profile.activityLevel) {
      'sedentary' => 3,
      'lightly_active' => 3,
      'moderately_active' => 4,
      'active' => 5,
      'very_active' => 6,
      _ => 4,
    };

    final calMultiplier = switch (profile.goal) {
      'lose_weight' => 0.25,
      'maintain_weight' => 0.18,
      'gain_weight' => 0.12,
      _ => 0.18,
    };

    final suggested = WeeklyGoal(
      targetSteps: dailySteps * 7,
      targetActiveMinutes: weeklyActiveMin,
      targetCaloriesBurned: profile.tdee * 7 * calMultiplier,
      targetWorkouts: workouts,
      createdAt: DateTime.now(),
      isSystemSuggested: true,
    );

    _suggestedGoal = suggested;
    notifyListeners();
    return suggested;
  }

  void confirmGoal(WeeklyGoal goal) {
    _weeklyGoal = goal;
    _suggestedGoal = null;
    notifyListeners();
  }

  void clearGoal() {
    _weeklyGoal = null;
    notifyListeners();
  }
  static double _numericValue(HealthDataPoint point) {
    final v = point.value;
    if (v is NumericHealthValue) return v.numericValue.toDouble();
    return 0;
  }
}