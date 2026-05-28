import 'package:flutter/material.dart';
import '../../auth/domain/app_user.dart';
import '../domain/assigned_plan.dart';

class CoachPlanController extends ChangeNotifier {
  final List<AssignedPlan> _plans = [];

  List<AssignedPlan> get plans => List.unmodifiable(_plans);

  final List<PlanRequest> _requests = [];

  List<PlanRequest> get requests => List.unmodifiable(_requests);
  List<AppUser> clientsForCoach({
    required AppUser coach,
    required List<AppUser> allUsers,
  }) {
    return allUsers
        .where(
          (user) =>
              user.isUser &&
              user.premiumEnabled &&
              user.selectedCoachId == coach.id,
        )
        .toList();
  }

  List<AssignedPlan> plansForClient(String clientId) =>
      _plans.where((p) => p.clientId == clientId).toList();

  AssignedPlan? latestPlanForClient(String clientId) {
    final clientPlans = plansForClient(clientId);
    return clientPlans.isEmpty ? null : clientPlans.last;
  }


  List<PlanRequest> pendingRequestsForCoach(String coachId) =>
      _requests.where((r) => r.coachId == coachId).toList();

  void requestPlan({
    required String clientId,
    required String clientName,
    required String coachId,
  }) {
    final alreadyPending = _requests.any(
      (r) => r.clientId == clientId && r.coachId == coachId,
    );
    if (alreadyPending) return;

    _requests.add(
      PlanRequest(
        clientId: clientId,
        clientName: clientName,
        coachId: coachId,
        requestedAt: DateTime.now(),
      ),
    );
    notifyListeners();
  }

  void dismissRequest(String clientId) {
    _requests.removeWhere((r) => r.clientId == clientId);
    notifyListeners();
  }

  //create te assigned plan or updtae it 
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
    // if = pending 
    dismissRequest(client.id);
    notifyListeners();
  }
}