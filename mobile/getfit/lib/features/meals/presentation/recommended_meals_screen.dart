import 'package:flutter/material.dart';
import 'package:getfit/core/models/food_metrics_amounts.dart';
import 'package:getfit/core/models/ingredient.dart';
import 'package:getfit/core/models/nutrition_goal.dart';
import 'package:getfit/features/meals/presentation/shopping_list_screen.dart';
import 'package:provider/provider.dart';

import '../../../core/models/food_metric.dart';
import '../data/meals_api_connector.dart';
import '../domain/meal.dart';
import '../domain/my_meals.dart';
import '../domain/shopping_list.dart';
import 'meal_details_screen.dart';

class RecommendedMealsScreen extends StatefulWidget {
  const RecommendedMealsScreen({super.key});

  @override
  State<RecommendedMealsScreen> createState() => _RecommendedMealsScreenState();
}

class _RecommendedMealsScreenState extends State<RecommendedMealsScreen> {
  final MealsApiConnector mealsApiConnector = MealsApiConnector();

  bool _isLoading = false;
  late FoodMetricsAmounts neededMetrics;
  List<Meal> _meals = [];

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  Future<void> _loadMeals() async {
    setState(() {
      _isLoading = true;
    });

    if (!mounted) return;

    final dailyNutrition = context.read<FoodMetricsAmounts>();
    final dailyNutritionGoal = context.read<NutritionGoal>();

    final neededMetrics = dailyNutritionGoal.calcNeeded(dailyNutrition);
    final neededCalories = neededMetrics.getAmount(FoodMetric.calories);

    _meals = await mealsApiConnector.getMealsWithConstraints(
      minCalories: (neededCalories / 2).floor(),
      maxCalories: neededCalories,
    );

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final cardWidth = MediaQuery.of(context).size.width < 900
        ? double.infinity
        : 340.0;

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
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_meals.isEmpty)
              _EmptyStateCard(
                icon: Icons.restaurant_outlined,
                title: 'No meals found',
                description: 'No saved meals',
              )
            else
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: _meals
                    .map(
                      (meal) => SizedBox(
                        width: cardWidth,
                        child: GestureDetector(
                          child: _MealCard(meal: meal),
                          onTap: () async {
                            final Meal? mealToAdd = await Navigator.push<Meal>(
                              context,
                              MaterialPageRoute(
                                builder: (_) => MealDetailsScreen(meal: meal),
                              ),
                            );

                            if (mealToAdd != null) {
                              context.read<ShoppingList>().addIngredients(
                                mealToAdd.ingredients as List<Ingredient>,
                              );

                              context.read<MyMeals>().addMeal(meal);
                              debugPrint("Added to MyMeals ${mealToAdd.title}");

                              // Show shopping list
                              Navigator.push<void>(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => ShoppingListScreen(),
                                ),
                              );
                            }
                          },
                        ),
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

class _MealCard extends StatelessWidget {
  final Meal meal;

  const _MealCard({required this.meal});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(meal.imageUrl),
          const SizedBox(height: 20),
          Text(
            meal.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MacroChip(
                icon: Icons.fitness_center_rounded,
                label: 'Protein ${meal.proteinGrams}g',
                color: const Color(0xFF2E7D32),
              ),
              _MacroChip(
                icon: Icons.grain_rounded,
                label: 'Carbs ${meal.carbsGrams}g',
                color: Colors.orange,
              ),
              _MacroChip(
                icon: Icons.opacity_rounded,
                label: 'Fats ${meal.fatsGrams}g',
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MacroChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _EmptyStateCard({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42, color: Colors.grey[500]),
          const SizedBox(height: 14),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            description,
            style: TextStyle(color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
