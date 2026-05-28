import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/session_controller.dart';
import '../../auth/domain/app_user.dart';
import 'coach_client_profile_screen.dart';

class CoachClientsScreen extends StatelessWidget {
  const CoachClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final coach = session.currentUser;

    if (coach == null) {
      return const Scaffold(
        body: Center(
          child: Text('No logged in coach found.'),
        ),
      );
    }

    final clients = session.users.where((user) {
      return user.isUser &&
          user.premiumEnabled &&
          user.selectedCoachId == coach.id;
    }).toList();

    return SingleChildScrollView(
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
            const Row(
              children: [
                Icon(
                  Icons.groups_rounded,
                  color: Color(0xFF2E7D32),
                  size: 30,
                ),
                SizedBox(width: 12),
                Text(
                  'Clients',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'These are the premium users who selected you as their coach.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 28),
            if (clients.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.groups_outlined,
                      size: 42,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'No clients assigned yet',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When premium users choose you from the profile coach selector, they will appear here.',
                      style: TextStyle(
                        color: Colors.grey[600],
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              Column(
                children: clients
                    .map(
                      (client) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _ClientCard(client: client),
                      ),
                    )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _ClientCard extends StatelessWidget {
  const _ClientCard({required this.client});

  final AppUser client;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => CoachClientProfileScreen(client: client),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: const Color(0xFFE8F5E9),
              child: Text(
                client.profile.name.trim().isNotEmpty
                    ? client.profile.name.trim()[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Color(0xFF2E7D32),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    client.profile.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${client.profile.goal} • ${client.profile.activityLevel}',
                    style: TextStyle(
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, size: 18),
          ],
        ),
      ),
    );
  }
}