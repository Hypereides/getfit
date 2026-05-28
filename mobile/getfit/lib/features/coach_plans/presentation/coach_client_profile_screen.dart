import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/domain/app_user.dart';
import '../state/coach_plan_controller.dart';
import 'coach_plan_form_screen.dart';

class CoachClientProfileScreen extends StatelessWidget {
  const CoachClientProfileScreen({
    super.key,
    required this.client,
  });

  final AppUser client;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<CoachPlanController>();
    final latestPlan = controller.latestPlanForClient(client.id);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Client Profile'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                client.profile.name,
                style: const TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _InfoCard(label: 'Age', value: '${client.profile.age}'),
                  _InfoCard(label: 'Height', value: '${client.profile.heightCm} cm'),
                  _InfoCard(label: 'Weight', value: '${client.profile.weightKg} kg'),
                  _InfoCard(label: 'Goal', value: client.profile.goal),
                  _InfoCard(label: 'Activity', value: client.profile.activityLevel),
                  _InfoCard(label: 'BMI', value: client.profile.bmi.toStringAsFixed(1)),
                  _InfoCard(label: 'TDEE', value: client.profile.tdee.toStringAsFixed(0)),
                  _InfoCard(label: 'Email', value: client.email),
                ],
              ),
              const SizedBox(height: 32),
              if (latestPlan != null) ...[
                const Text(
                  'Latest Assigned Plan',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        latestPlan.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(latestPlan.description),
                      const SizedBox(height: 10),
                      Text('Weekly workouts: ${latestPlan.weeklyWorkouts}'),
                      Text('Cardio days: ${latestPlan.cardioDays}'),
                      Text('Duration: ${latestPlan.durationWeeks} weeks'),
                    ],
                  ),
                ),
                const SizedBox(height: 28),
              ],
              Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CoachPlanFormScreen(
                            client: client,
                            isUpdate: false,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.add_task_rounded),
                    label: const Text('Create Plan'),
                  ),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFF2E7D32)),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 22,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => CoachPlanFormScreen(
                            client: client,
                            isUpdate: true,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Update Plan'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}