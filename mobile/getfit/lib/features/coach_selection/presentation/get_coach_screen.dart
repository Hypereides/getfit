import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/state/session_controller.dart';
import '../../coach_plans/state/coach_plan_controller.dart';

class GetCoachScreen extends StatefulWidget {
  const GetCoachScreen({super.key});

  @override
  State<GetCoachScreen> createState() => _GetCoachScreenState();
}

class _GetCoachScreenState extends State<GetCoachScreen> {
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
        child: Consumer<SessionController>(
          builder: (context, session, _) {
            final coaches = session.coaches;

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
                  'Select a coach to view their profile and request a personalized fitness plan.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
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
                      return _CoachCard(coach: coach);
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
  const _CoachCard({required this.coach});

  final dynamic coach;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
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
        title: Text(
          coach.profile.name,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(coach.email, style: TextStyle(color: Colors.grey[600])),
        trailing: ElevatedButton(
          onPressed: () {
            final session = Provider.of<SessionController>(context, listen: false);
            final coachPlanController = Provider.of<CoachPlanController>(context, listen: false);
            final currentUser = session.currentUser;
            
            if (currentUser == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Please log in first')),
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
                content: Text('Coach request sent to ${coach.profile.name}'),
                duration: const Duration(seconds: 2),
              ),
            );
            
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2E7D32),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        child: const Text('Request', style: TextStyle(color: Colors.white)),
      ),
      ),
    );
  }
}
