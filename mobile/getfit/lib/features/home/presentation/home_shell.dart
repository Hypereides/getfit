import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/session_controller.dart';
import '../../dashboard/presentation/dashboard_screen.dart';
import '../../meals/presentation/meal_recommendation_screen.dart';
import '../../plans/presentation/my_plan_screen.dart';
import '../../profile/presentation/profile_screen.dart';
import '../../progress/presentation/progress_screen.dart';
import '../../workout_places/presentation/workout_place_screen.dart';

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

    final screens = [
      DashboardScreen(userName: user.profile.name),
      const MyPlanScreen(),
      const ProgressScreen(),
      const MealRecommendationScreen(),
      const WorkoutPlaceScreen(),
      const ProfileScreen(),
    ];

    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      bottomNavigationBar: isMobile
          ? NavigationBar(
              backgroundColor: Colors.white,
              selectedIndex: _selectedIndex,
              onDestinationSelected: (index) =>
                  setState(() => _selectedIndex = index),
              indicatorColor: const Color(0xFFE8F5E9),
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.dashboard_outlined),
                  selectedIcon: Icon(
                    Icons.dashboard_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                  label: 'Dashboard',
                ),
                NavigationDestination(
                  icon: Icon(Icons.assignment_outlined),
                  selectedIcon: Icon(
                    Icons.assignment_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                  label: 'My Plan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.trending_up_outlined),
                  selectedIcon: Icon(
                    Icons.trending_up_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                  label: 'Progress',
                ),
                NavigationDestination(
                  icon: Icon(Icons.restaurant_menu_outlined),
                  selectedIcon: Icon(
                    Icons.restaurant_menu_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                  label: 'Meals',
                ),
                NavigationDestination(
                  icon: Icon(Icons.place_outlined),
                  selectedIcon: Icon(
                    Icons.place_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                  label: 'Places',
                ),
                NavigationDestination(
                  icon: Icon(Icons.person_outline),
                  selectedIcon: Icon(
                    Icons.person_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                  label: 'Profile',
                ),
              ],
            )
          : null,
      body: isMobile
          ? screens[_selectedIndex]
          : Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(2, 0),
                      ),
                    ],
                  ),
                  child: NavigationRail(
                    backgroundColor: Colors.white,
                    selectedIndex: _selectedIndex,
                    onDestinationSelected: (index) =>
                        setState(() => _selectedIndex = index),
                    labelType: NavigationRailLabelType.all,
                    minWidth: 100,
                    indicatorColor: const Color(0xFFE8F5E9),
                    selectedIconTheme: const IconThemeData(
                      color: Color(0xFF2E7D32),
                      size: 28,
                    ),
                    unselectedIconTheme: IconThemeData(
                      color: Colors.grey[400],
                      size: 28,
                    ),
                    selectedLabelTextStyle: const TextStyle(
                      color: Color(0xFF2E7D32),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                    unselectedLabelTextStyle: TextStyle(
                      color: Colors.grey[500],
                      fontWeight: FontWeight.w500,
                      fontSize: 13,
                    ),
                    leading: Padding(
                      padding: const EdgeInsets.only(top: 32, bottom: 24),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fitness_center_rounded,
                          size: 32,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    destinations: const [
                      NavigationRailDestination(
                        icon: Icon(Icons.dashboard_outlined),
                        selectedIcon: Icon(Icons.dashboard_rounded),
                        label: Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text('Dashboard'),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.assignment_outlined),
                        selectedIcon: Icon(Icons.assignment_rounded),
                        label: Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text('My Plan'),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.trending_up_outlined),
                        selectedIcon: Icon(Icons.trending_up_rounded),
                        label: Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text('Progress'),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.restaurant_menu_outlined),
                        selectedIcon: Icon(Icons.restaurant_menu_rounded),
                        label: Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text('Meals'),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.place_outlined),
                        selectedIcon: Icon(Icons.place_rounded),
                        label: Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text('Places'),
                        ),
                      ),
                      NavigationRailDestination(
                        icon: Icon(Icons.person_outline),
                        selectedIcon: Icon(Icons.person_rounded),
                        label: Padding(
                          padding: EdgeInsets.only(top: 4.0),
                          child: Text('Profile'),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: screens[_selectedIndex]),
              ],
            ),
    );
  }
}