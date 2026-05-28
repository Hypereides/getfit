import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_dropdown_field.dart';
import '../../barcode/data/mock_food_database.dart';
import '../../barcode/presentation/barcode_scan_screen.dart';
import '../../barcode/presentation/food_detail_screen.dart';
import '../../barcode/state/food_log_controller.dart';
import '../data/meal_recommendation_service.dart';
import '../domain/meal_recommendation.dart';

class MealRecommendationScreen extends StatefulWidget {
  const MealRecommendationScreen({super.key});

  @override
  State<MealRecommendationScreen> createState() =>
      _MealRecommendationScreenState();
}

class _MealRecommendationScreenState extends State<MealRecommendationScreen> {
  final MealRecommendationService _service = MealRecommendationService();

  String _selectedGoal = 'lose_weight';
  bool _isLoading = false;
  List<MealRecommendation> _meals = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    setState(() => _isLoading = true);
    final meals = await _service.getRecommendations(goal: _selectedGoal);
    if (!mounted) return;
    setState(() {
      _meals = meals;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final foodLog = context.watch<FoodLogController>();
    final cardWidth =
        MediaQuery.of(context).size.width < 900 ? double.infinity : 340.0;

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
                    Icons.restaurant_menu_rounded,
                    color: Color(0xFF2E7D32),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meals & Nutrition',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                          height: 1.2,
                        ),
                      ),
                      Text(
                        'Track food, scan barcodes and get recommendations',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _BarcodeScanCard(),
            const SizedBox(height: 40),
            _sectionTitle('Search Food Database'),
            const SizedBox(height: 4),
            Text(
              'Manually find a product and log your intake.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    decoration: InputDecoration(
                      hintText: 'Search by name (e.g. Nutella, Oats…)',
                      prefixIcon: const Icon(Icons.search_rounded),
                      filled: true,
                      fillColor: Colors.grey[50],
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12)),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
              ],
            ),
            if (_searchQuery.trim().isNotEmpty) ...[
              const SizedBox(height: 12),
              _FoodSearchResults(
                query: _searchQuery.trim(),
                cardWidth: cardWidth,
              ),
            ],

            const SizedBox(height: 48),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 40),
            _sectionTitle("Today's Food Log"),
            const SizedBox(height: 16),

            if (foodLog.todaysEntries.isEmpty)
              _emptyLogCard()
            else ...[
              _DailyMacroBar(controller: foodLog),
              const SizedBox(height: 20),
              ...foodLog.todaysEntries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _FoodLogEntryCard(
                    entry: entry,
                    onDelete: () => foodLog.removeEntry(entry.id),
                  ),
                ),
              ),
            ],

            const SizedBox(height: 48),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 40),
            _sectionTitle('Meal Recommendations'),
            const SizedBox(height: 4),
            Text(
              'Suggested meals based on the selected goal.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                AppDropdownField<String>(
                  label: 'Goal',
                  value: _selectedGoal,
                  width: 280,
                  items: const [
                    DropdownMenuItem(
                        value: 'lose_weight', child: Text('Lose weight')),
                    DropdownMenuItem(
                        value: 'maintain_weight',
                        child: Text('Maintain weight')),
                    DropdownMenuItem(
                        value: 'gain_weight', child: Text('Gain weight')),
                  ],
                  onChanged: (value) {
                    if (value == null) return;
                    setState(() => _selectedGoal = value);
                    _loadMeals();
                  },
                ),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16, horizontal: 24),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  onPressed: _loadMeals,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Refresh',
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_meals.isEmpty)
              _EmptyStateCard(
                icon: Icons.restaurant_outlined,
                title: 'No meals found',
                description:
                    'Try another goal or refresh the recommendations.',
              )
            else
              Wrap(
                spacing: 24,
                runSpacing: 24,
                children: _meals
                    .map((meal) => SizedBox(
                          width: cardWidth,
                          child: _MealCard(meal: meal),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style:
            const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      );

  Widget _emptyLogCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.no_meals_rounded, color: Colors.grey[400]),
            const SizedBox(width: 14),
            Text(
              'No meals logged yet today. Scan a barcode or search above.',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      );
}


class _BarcodeScanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => const BarcodeScanScreen(),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1B5E20), Color(0xFF43A047)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2E7D32).withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(28),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Scan a Barcode',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Point your camera at any food product barcode to instantly log calories and macros.',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: Colors.white60, size: 18),
            ],
          ),
        ),
      ),
    );
  }
}

class _FoodSearchResults extends StatelessWidget {
  const _FoodSearchResults(
      {required this.query, required this.cardWidth});

  final String query;
  final double cardWidth;

  @override
  Widget build(BuildContext context) {
    final results = MockFoodDatabase.all.where((p) {
      final q = query.toLowerCase();
      return p.name.toLowerCase().contains(q) ||
          p.brand.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('No products found for "$query".',
            style: TextStyle(color: Colors.grey[600])),
      );
    }

    return Column(
      children: results
          .map(
            (p) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => FoodDetailScreen(product: p)),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.fastfood_rounded,
                            color: Color(0xFF2E7D32), size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15)),
                            Text(
                              '${p.brand}  ·  ${p.caloriesPer100g.toStringAsFixed(0)} kcal / 100${p.servingUnit}',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.add_circle_outline_rounded,
                          color: Color(0xFF2E7D32)),
                    ],
                  ),
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

class _DailyMacroBar extends StatelessWidget {
  const _DailyMacroBar({required this.controller});

  final FoodLogController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFA5D6A7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _MacroTotal(
              label: 'Calories',
              value:
                  '${controller.todayCalories.toStringAsFixed(0)} kcal',
              color: Colors.orange),
          _MacroTotal(
              label: 'Protein',
              value: '${controller.todayProtein.toStringAsFixed(1)} g',
              color: const Color(0xFF2E7D32)),
          _MacroTotal(
              label: 'Carbs',
              value: '${controller.todayCarbs.toStringAsFixed(1)} g',
              color: Colors.blue),
          _MacroTotal(
              label: 'Fat',
              value: '${controller.todayFat.toStringAsFixed(1)} g',
              color: Colors.purple),
        ],
      ),
    );
  }
}

class _MacroTotal extends StatelessWidget {
  const _MacroTotal(
      {required this.label, required this.value, required this.color});

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color)),
        const SizedBox(height: 3),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}

class _FoodLogEntryCard extends StatelessWidget {
  const _FoodLogEntryCard(
      {required this.entry, required this.onDelete});

  final dynamic entry; // FoodLogEntry
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.fastfood_rounded,
                color: Color(0xFF2E7D32), size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.product.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(
                  '${entry.quantityG.toStringAsFixed(0)} ${entry.product.servingUnit}  ·  ${entry.calories.toStringAsFixed(0)} kcal  ·  P: ${entry.protein.toStringAsFixed(1)}g  C: ${entry.carbs.toStringAsFixed(1)}g  F: ${entry.fat.toStringAsFixed(1)}g',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.redAccent,
            tooltip: 'Remove',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}


class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal});

  final MealRecommendation meal;

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
          Text(meal.title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          const SizedBox(height: 8),
          Text(
            '${meal.category} · ${meal.calories} kcal',
            style: TextStyle(
                color: Colors.grey[600],
                fontSize: 14,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          Text(meal.description,
              style: TextStyle(color: Colors.grey[700], height: 1.5)),
          const SizedBox(height: 20),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _MacroChip(
                  icon: Icons.fitness_center_rounded,
                  label: 'Protein ${meal.proteinGrams}g',
                  color: const Color(0xFF2E7D32)),
              _MacroChip(
                  icon: Icons.grain_rounded,
                  label: 'Carbs ${meal.carbsGrams}g',
                  color: Colors.orange),
              _MacroChip(
                  icon: Icons.opacity_rounded,
                  label: 'Fats ${meal.fatsGrams}g',
                  color: Colors.blue),
            ],
          ),
        ],
      ),
    );
  }
}

class _MacroChip extends StatelessWidget {
  const _MacroChip(
      {required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

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
          Text(label,
              style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _EmptyStateCard extends StatelessWidget {
  const _EmptyStateCard(
      {required this.icon,
      required this.title,
      required this.description});

  final IconData icon;
  final String title;
  final String description;

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
          Text(title,
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(description,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}