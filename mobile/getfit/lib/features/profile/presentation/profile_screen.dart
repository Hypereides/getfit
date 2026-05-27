import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/session_controller.dart';
import '../../auth/domain/app_user.dart';
import '../../../core/widgets/app_dropdown_field.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final user = session.currentUser;
    final coaches = session.coaches;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No logged in user found.'),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        padding: const EdgeInsets.all(48),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.person_outline,
                    color: Color(0xFF2E7D32),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF2E7D32),
                  child: Text(
                    user.profile.name.trim().isNotEmpty
                        ? user.profile.name.trim()[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      fontSize: 32,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 24),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello,',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    Text(
                      user.profile.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Your saved profile data, goal, activity level, BMI, TDEE, and premium coaching settings are shown below.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 48),
            const Text(
              'Your Stats Overview',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _buildStatCard('Current Goal', user.profile.goal, Icons.flag_outlined),
                _buildStatCard(
                  'Activity Level',
                  user.profile.activityLevel,
                  Icons.directions_run,
                ),
                _buildStatCard(
                  'Estimated BMI',
                  user.profile.bmi.toStringAsFixed(1),
                  Icons.monitor_weight_outlined,
                ),
                _buildStatCard(
                  'Daily TDEE',
                  '${user.profile.tdee.toStringAsFixed(0)} kcal',
                  Icons.local_fire_department_outlined,
                ),
              ],
            ),
            const SizedBox(height: 48),
            if (user.isUser) ...[
              const Text(
                'Premium Coaching',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Enable Premium',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text(
                        'Unlock coach selection and premium coaching features.',
                      ),
                      value: user.premiumEnabled,
                      onChanged: (value) {
                        session.togglePremium(value);
                      },
                    ),
                    if (user.premiumEnabled) ...[
                      const SizedBox(height: 20),
                      AppDropdownField<String>(
                      label: 'Select Coach',
                      value: user.selectedCoachId,
                      width: 280,
                      items: coaches
                          .map(
                            (coach) => DropdownMenuItem<String>(
                              value: coach.id,
                              child: Text(coach.profile.name),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        session.selectCoach(value);
                      },
                    ),
                      const SizedBox(height: 16),
                      Text(
                        user.selectedCoachId == null
                            ? 'No coach selected yet.'
                            : 'Selected coach: ${_coachNameFromId(coaches, user.selectedCoachId!)}',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 48),
            ],
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 16),
            TextButton.icon(
              onPressed: () {},
              icon: Icon(Icons.settings_outlined, color: Colors.grey[700]),
              label: Text(
                'Account Settings',
                style: TextStyle(color: Colors.grey[700], fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _coachNameFromId(List<AppUser> coaches, String coachId) {
    try {
      return coaches.firstWhere((coach) => coach.id == coachId).profile.name;
    } catch (_) {
      return 'Unknown coach';
    }
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.grey[500], size: 24),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B1B1B),
            ),
          ),
        ],
      ),
    );
  }
}