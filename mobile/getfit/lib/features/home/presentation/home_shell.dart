import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/session_controller.dart';
import '../../coach_plans/presentation/coach_clients_screen.dart';
import '../../coach_selection/presentation/get_coach_screen.dart';
import '../../meals/presentation/meal_recommendation_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../progress/presentation/progress_screen.dart';
import '../../workout_places/presentation/workout_place_screen.dart';
import '../../workouts/presentation/my_plan_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionController>();
    final user = session.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No logged in user found.'),
        ),
      );
    }

    final isCoach = user.role.toLowerCase() == 'coach';

    final userScreens = <Widget>[
      const _DashboardScreen(isCoach: false),
      const MyPlanScreen(),
      const ProgressScreen(),
      const MealRecommendationScreen(),
      const WorkoutPlaceScreen(),
      const ProfileScreen(),
    ];

    final coachScreens = <Widget>[
      const _DashboardScreen(isCoach: true),
      const CoachClientsScreen(),
      const ProfileScreen(),
    ];

    final screens = isCoach ? coachScreens : userScreens;

    if (_selectedIndex >= screens.length) {
      _selectedIndex = 0;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 900;

        if (isMobile) {
          return Scaffold(
            backgroundColor: const Color(0xFFF5F7F6),
            body: screens[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              currentIndex: _selectedIndex,
              onTap: (index) {
                setState(() => _selectedIndex = index);
              },
              selectedItemColor: const Color(0xFF2E7D32),
              unselectedItemColor: Colors.grey,
              type: BottomNavigationBarType.fixed,
              items: isCoach
                  ? const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_outlined),
                        label: 'Dashboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.groups_outlined),
                        label: 'Clients',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        label: 'Profile',
                      ),
                    ]
                  : const [
                      BottomNavigationBarItem(
                        icon: Icon(Icons.dashboard_outlined),
                        label: 'Dashboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.assignment_outlined),
                        label: 'My Plan',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.show_chart_outlined),
                        label: 'Progress',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.restaurant_menu_outlined),
                        label: 'Meals',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.place_outlined),
                        label: 'Places',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(Icons.person_outline),
                        label: 'Profile',
                      ),
                    ],
            ),
          );
        }

        return Scaffold(
          backgroundColor: const Color(0xFFF5F7F6),
          body: Row(
            children: [
              Container(
                width: 110,
                color: Colors.white,
                child: NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: Colors.white,
                  selectedIconTheme: const IconThemeData(
                    color: Color(0xFF2E7D32),
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedIconTheme: IconThemeData(
                    color: Colors.grey[600],
                  ),
                  unselectedLabelTextStyle: TextStyle(
                    color: Colors.grey[700],
                  ),
                  destinations: isCoach
                      ? const [
                          NavigationRailDestination(
                            icon: Icon(Icons.dashboard_outlined),
                            selectedIcon: Icon(Icons.dashboard),
                            label: Text('Dashboard'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.groups_outlined),
                            selectedIcon: Icon(Icons.groups),
                            label: Text('Clients'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person_outline),
                            selectedIcon: Icon(Icons.person),
                            label: Text('Profile'),
                          ),
                        ]
                      : const [
                          NavigationRailDestination(
                            icon: Icon(Icons.dashboard_outlined),
                            selectedIcon: Icon(Icons.dashboard),
                            label: Text('Dashboard'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.assignment_outlined),
                            selectedIcon: Icon(Icons.assignment),
                            label: Text('My Plan'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.show_chart_outlined),
                            selectedIcon: Icon(Icons.show_chart),
                            label: Text('Progress'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.restaurant_menu_outlined),
                            selectedIcon: Icon(Icons.restaurant_menu),
                            label: Text('Meals'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.place_outlined),
                            selectedIcon: Icon(Icons.place),
                            label: Text('Places'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.person_outline),
                            selectedIcon: Icon(Icons.person),
                            label: Text('Profile'),
                          ),
                        ],
                ),
              ),
              Expanded(
                child: screens[_selectedIndex],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DashboardScreen extends StatelessWidget {
  const _DashboardScreen({
    required this.isCoach,
  });

  final bool isCoach;

  @override
  Widget build(BuildContext context) {
    final user = context.watch<SessionController>().currentUser;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Container(
            width: double.infinity,
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
                      child: Icon(
                        isCoach ? Icons.groups_rounded : Icons.dashboard_rounded,
                        color: const Color(0xFF2E7D32),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        isCoach ? 'Coach Dashboard' : 'Dashboard',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  isCoach
                      ? 'Welcome back, ${user?.profile.name ?? 'Coach'}. Open Clients to view the premium users who selected you as their coach.'
                      : 'Welcome back, ${user?.profile.name ?? 'User'}. Use My Plan, Progress, Meals, Places, and Profile to manage your fitness journey.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (!isCoach) ...[
            const SizedBox(height: 20),
            _GetCoachCard(),
            const SizedBox(height: 16),
            _MealRecommendationCard(),
            const SizedBox(height: 16),
            _WorkoutPlaceCard(),
          ],
        ],
      ),
    );
  }
}
class _GetCoachCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashboardShortcutCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF2E7D32), Color(0xFF43A047)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0xFF2E7D32),
      icon: Icons.sports_outlined,
      title: 'Get a Coach',
      subtitle:
          'Browse coaches, view their profile, and request a personalised fitness plan.',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const CoachListScreen()),
        );
      },
    );
  }
}
class _MealRecommendationCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashboardShortcutCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0xFF1565C0),
      icon: Icons.restaurant_menu_rounded,
      title: 'Meal Recommendations',
      subtitle:
          'Get personalised meal suggestions based on your remaining daily calories and fitness goal.',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              backgroundColor: const Color(0xFFF7F8FA),
              appBar: AppBar(
                title: const Text('Meals & Nutrition'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
              body: const MealRecommendationScreen(),
            ),
          ),
        );
      },
    );
  }
}

class _WorkoutPlaceCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return _DashboardShortcutCard(
      gradient: const LinearGradient(
        colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      shadowColor: const Color(0xFF6A1B9A),
      icon: Icons.place_rounded,
      title: 'Find a Workout Place',
      subtitle:
          'Discover nearby gyms, CrossFit boxes and outdoor tracks that are open right now.',
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => Scaffold(
              backgroundColor: const Color(0xFFF7F8FA),
              appBar: AppBar(
                title: const Text('Find a Workout Place'),
                backgroundColor: Colors.white,
                foregroundColor: Colors.black87,
                elevation: 0,
              ),
              body: const WorkoutPlaceScreen(),
            ),
          ),
        );
      },
    );
  }
}

class _DashboardShortcutCard extends StatelessWidget {
  const _DashboardShortcutCard({
    required this.gradient,
    required this.shadowColor,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final LinearGradient gradient;
  final Color shadowColor;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withValues(alpha: 0.30),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          borderRadius: BorderRadius.circular(24),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.20),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Icon(Icons.arrow_forward_ios_rounded,
                    color: Colors.white70, size: 18),
              ],
            ),
          ),
        ),
      ),
    );
  }
}