import 'package:flutter/material.dart';

import '../domain/workout_session.dart';

class WorkoutController extends ChangeNotifier {
  final List<WorkoutSession> _sessions = [];

  List<WorkoutSession> get sessions => List.unmodifiable(_sessions);

  int get totalSessions => _sessions.length;

  int get totalActivities {
    return _sessions.fold(0, (sum, session) => sum + session.totalActivities);
  }

  double get totalCaloriesBurned {
    return _sessions.fold(0, (sum, session) => sum + session.totalEstimatedCalories);
  }

  WorkoutSession? get latestSession {
    if (_sessions.isEmpty) return null;
    return _sessions.first;
  }

  void addSession(WorkoutSession session) {
    _sessions.insert(0, session);
    notifyListeners();
  }

  void clearSessions() {
    _sessions.clear();
    notifyListeners();
  }
}