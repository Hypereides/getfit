import 'package:flutter/material.dart';

import '../../auth/domain/app_user.dart';
import '../domain/assigned_plan.dart';

class CoachPlanController extends ChangeNotifier {
  final List<AssignedPlan> _plans = [];

  List<AssignedPlan> get plans => List.unmodifiable(_plans);

  List<AppUser> clientsForCoach({
    required AppUser coach,
    required List<AppUser> allUsers,
  }) {
    return allUsers.where((user) {
      return user.isUser &&
          user.premiumEnabled &&
          user.selectedCoachId == coach.id;
    }).toList();
  }

  List<AssignedPlan> plansForClient(String clientId) {
    return _plans.where((plan) => plan.clientId == clientId).toList();
  }

  AssignedPlan? latestPlanForClient(String clientId) {
    final clientPlans = plansForClient(clientId);
    if (clientPlans.isEmpty) return null;
    return clientPlans.last;
  }

  void createOrUpdatePlan({
    required AppUser client,
    required String title,
    required String description,
    required int weeklyWorkouts,
    required int cardioDays,
    required int durationWeeks,
    required String nutritionNotes,
    required bool isUpdate,
  }) {
    final plan = AssignedPlan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      clientId: client.id,
      clientName: client.profile.name,
      title: title,
      description: description,
      weeklyWorkouts: weeklyWorkouts,
      cardioDays: cardioDays,
      durationWeeks: durationWeeks,
      nutritionNotes: nutritionNotes,
      createdAt: DateTime.now(),
      isUpdated: isUpdate,
    );

    _plans.add(plan);
    notifyListeners();
  }
}