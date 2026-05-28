import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/session_controller.dart';
import '../../auth/domain/app_user.dart';
import '../domain/assigned_plan.dart';
import '../state/coach_plan_controller.dart';
import 'coach_client_profile_screen.dart';

class CoachClientsScreen extends StatelessWidget {
  const CoachClientsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final planController = context.watch<CoachPlanController>();
    final coach = session.currentUser;

    if (coach == null) {
      return const Scaffold(
        body: Center(child: Text('No logged in coach found.')),
      );
    }

    final clients = session.users.where((user) {
      return user.isUser &&
          user.premiumEnabled &&
          user.selectedCoachId == coach.id;
    }).toList();

    final pendingRequests = planController.pendingRequestsForCoach(coach.id);

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
                Icon(Icons.groups_rounded, color: Color(0xFF2E7D32), size: 30),
                SizedBox(width: 12),
                Text(
                  'Clients',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Premium users who selected you as their coach.',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),

            if (pendingRequests.isNotEmpty) ...[
              const SizedBox(height: 36),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF6F00),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${pendingRequests.length} new',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Pending Plan Requests',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'These clients are waiting for you to create a plan.',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              ...pendingRequests.map((request) {
                AppUser? clientUser;
                try {
                  clientUser = session.users
                      .firstWhere((u) => u.id == request.clientId);
                } catch (_) {
                  clientUser = null;
                }
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _PendingRequestCard(
                    request: request,
                    clientUser: clientUser,
                  ),
                );
              }),
            ],
            const SizedBox(height: 36),
            const Text(
              'Active Clients',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

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
                    Icon(Icons.groups_outlined,
                        size: 42, color: Colors.grey[500]),
                    const SizedBox(height: 14),
                    const Text(
                      'No active clients yet',
                      style: TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'When premium users choose you and you create a plan for them, they will appear here.',
                      style: TextStyle(color: Colors.grey[600], height: 1.5),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              )
            else
              ...clients.map(
                (client) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _ClientCard(client: client),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _PendingRequestCard extends StatelessWidget {
  const _PendingRequestCard({
    required this.request,
    required this.clientUser,
  });

  final PlanRequest request;
  final AppUser? clientUser;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFFCC02)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: const Color(0xFFFF6F00),
            child: Text(
              request.clientName.trim().isNotEmpty
                  ? request.clientName.trim()[0].toUpperCase()
                  : 'U',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  request.clientName,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  'Requested a plan · ${_timeAgo(request.requestedAt)}',
                  style: TextStyle(fontSize: 13, color: Colors.orange[800]),
                ),
              ],
            ),
          ),
          if (clientUser != null)
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFFF6F00),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        CoachClientProfileScreen(client: clientUser!),
                  ),
                );
              },
              icon: const Icon(Icons.assignment_add, size: 18),
              label: const Text(
                'Create Plan',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
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
                    '${client.profile.goal} · ${client.profile.activityLevel}',
                    style: TextStyle(color: Colors.grey[700]),
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