import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/session_controller.dart';
import '../../coach_plans/state/coach_plan_controller.dart';

class CoachListScreen extends StatelessWidget {
  const CoachListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get a Coach'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Consumer2<SessionController, CoachPlanController>(
          builder: (context, session, planController, _) {
            final coaches = session.coaches;
            final currentUser = session.currentUser;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Browse Available Coaches',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select a coach to view their profile and request a personalised fitness plan.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
                if (currentUser != null && currentUser.selectedCoachId != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFA5D6A7)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'You already have a coach assigned. Requesting a new one will replace your current selection.',
                            style: TextStyle(
                              color: Colors.green[800],
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 32),
                if (coaches.isEmpty)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Text(
                        'No coaches available at this time.',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ),
                  )
                else
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: coaches.length,
                    itemBuilder: (context, index) {
                      final coach = coaches[index];
                      final isCurrentCoach =
                          currentUser?.selectedCoachId == coach.id;
                      final hasPendingRequest = planController
                          .pendingRequestsForCoach(coach.id)
                          .any((r) => r.clientId == currentUser?.id);

                      return _CoachCard(
                        coach: coach,
                        isCurrentCoach: isCurrentCoach,
                        hasPendingRequest: hasPendingRequest,
                      );
                    },
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CoachCard extends StatelessWidget {
  const _CoachCard({
    required this.coach,
    required this.isCurrentCoach,
    required this.hasPendingRequest,
  });

  final dynamic coach;
  final bool isCurrentCoach;
  final bool hasPendingRequest;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentCoach
              ? const Color(0xFF2E7D32)
              : Colors.grey[200]!,
          width: isCurrentCoach ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          radius: 32,
          backgroundColor: const Color(0xFF2E7D32),
          child: Text(
            coach.profile.name[0].toUpperCase(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        title: Row(
          children: [
            Flexible(
              child: Text(
                coach.profile.name,
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (isCurrentCoach) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Your coach',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        subtitle: Text(coach.email, style: TextStyle(color: Colors.grey[600])),
        trailing: hasPendingRequest
            ? Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Text(
                  'Pending',
                  style: TextStyle(
                    color: Colors.orange[800],
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              )
            : ElevatedButton(
                onPressed: () {
                  final session = Provider.of<SessionController>(
                      context,
                      listen: false);
                  final coachPlanController =
                      Provider.of<CoachPlanController>(context,
                          listen: false);
                  final currentUser = session.currentUser;

                  if (currentUser == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Please log in first')),
                    );
                    return;
                  }

                  if (!currentUser.premiumEnabled) {
                    session.togglePremium(true);
                  }

                  session.selectCoach(coach.id);

                  coachPlanController.requestPlan(
                    clientId: currentUser.id,
                    clientName: currentUser.profile.name,
                    coachId: coach.id,
                  );

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: const Color(0xFF2E7D32),
                      content: Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.white),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Request sent to ${coach.profile.name}!',
                              style:
                                  const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                      duration: const Duration(seconds: 3),
                    ),
                  );
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Request',
                    style: TextStyle(color: Colors.white)),
              ),
      ),
    );
  }
}