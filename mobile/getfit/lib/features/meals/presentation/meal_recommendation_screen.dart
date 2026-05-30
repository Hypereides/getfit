import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/session_controller.dart';
import '../../barcode/data/mock_food_database.dart';
import '../../barcode/domain/food_product.dart';
import '../../barcode/presentation/barcode_scan_screen.dart';
import '../../barcode/presentation/food_detail_screen.dart';
import '../../barcode/state/food_log_controller.dart';
import '../../store_meals/presentation/store_list_screen.dart';
import '../data/meal_recommendation_service.dart';
import '../domain/meal_recommendation.dart';
import '../state/my_meals_controller.dart';
import '../state/shopping_list_controller.dart';

class MealRecommendationScreen extends StatefulWidget {
  const MealRecommendationScreen({super.key});

  @override
  State<MealRecommendationScreen> createState() =>
      _MealRecommendationScreenState();
}

class _MealRecommendationScreenState extends State<MealRecommendationScreen> {
  final MealRecommendationService _service = MealRecommendationService();

  bool _isLoading = false;
  List<MealRecommendation> _meals = [];
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadMeals());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMeals() async {
    final session = context.read<SessionController>();
    final foodLog = context.read<FoodLogController>();
    final profile = session.currentUser?.profile;

    final targetCal = profile?.targetDailyCalories ?? 2000;
    final todayCal = foodLog.todayCalories;
    final todayProt = foodLog.todayProtein;

    final targetProt = ((profile?.tdee ?? 2000) * 0.25 / 4);

    setState(() => _isLoading = true);
    final meals = await _service.getRecommendations(
      city: profile?.city ?? 'Athens',
      goal: profile?.goal ?? 'maintain_weight',
      remainingCalories: (targetCal - todayCal).clamp(0, 5000),
      remainingProtein: (targetProt - todayProt).clamp(0, 300),
    );
    if (!mounted) return;
    setState(() {
      _meals = meals;
      _isLoading = false;
    });
  }

  void _showMealDetail(MealRecommendation meal) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MealDetailSheet(
        meal: meal,
        onConfirm: () {
          Navigator.pop(context);
          _onConfirmMeal(meal);
        },
        onDismiss: () => Navigator.pop(context),
      ),
    );
  }
  void _onConfirmMeal(MealRecommendation meal) {
    final myMeals = context.read<MyMealsController>();
    final shopping = context.read<ShoppingListController>();
    final foodLog = context.read<FoodLogController>();
    final mealProduct = FoodProduct(
      barcode: 'meal_rec_${meal.id}',
      name: meal.title,
      brand: 'Meal Recommendation',
      caloriesPer100g: meal.calories.toDouble(),
      proteinPer100g: meal.proteinGrams.toDouble(),
      carbsPer100g: meal.carbsGrams.toDouble(),
      fatsPer100g: meal.fatsGrams.toDouble(),
      typicalServingG: 100,
    );
    foodLog.logFood(product: mealProduct, quantityG: 100);
    shopping.addFromIngredients(meal.ingredients);
    myMeals.saveMeal(meal);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ShoppingListSheet(
        onDone: () => Navigator.pop(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final foodLog = context.watch<FoodLogController>();
    final session = context.watch<SessionController>();
    final myMeals = context.watch<MyMealsController>();
    final profile = session.currentUser?.profile;
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 600;
    final cardWidth = sw < 900 ? double.infinity : 340.0;

    final targetCal = profile?.targetDailyCalories ?? 2000;
    final remainingCal = (targetCal - foodLog.todayCalories).clamp(0, 10000);
    final calPct = (foodLog.todayCalories / targetCal).clamp(0.0, 1.0);

    return SingleChildScrollView(
      padding: EdgeInsets.all(isMobile ? 12 : 24),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 12))],
        ),
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 16 : 40,
          vertical: isMobile ? 24 : 40,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
              child: const Icon(Icons.restaurant_menu_rounded, color: Color(0xFF2E7D32), size: 32),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Meals & Nutrition', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -0.5, height: 1.2)),
                Text('Track food, scan barcodes and get personalised recommendations', style: TextStyle(fontSize: 14, color: Colors.black54)),
              ]),
            ),
          ]),
          const SizedBox(height: 36),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF43A047)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.bolt_rounded, color: Colors.white, size: 20),
                SizedBox(width: 8),
                Text("Today's Remaining Calories", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
              ]),
              const SizedBox(height: 12),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(
                  child: Text(
                    '${remainingCal.toStringAsFixed(0)} kcal remaining',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w800),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Text('of ${targetCal.toStringAsFixed(0)} kcal', style: const TextStyle(color: Colors.white70, fontSize: 13)),
              ]),
              const SizedBox(height: 10),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: calPct,
                  minHeight: 8,
                  backgroundColor: Colors.white.withValues(alpha: 0.25),
                  valueColor: const AlwaysStoppedAnimation(Colors.white),
                ),
              ),
              const SizedBox(height: 14),
              Wrap(spacing: 20, runSpacing: 8, children: [
                _macroStat('Protein', '${foodLog.todayProtein.toStringAsFixed(1)}g', Colors.greenAccent),
                _macroStat('Carbs', '${foodLog.todayCarbs.toStringAsFixed(1)}g', Colors.amberAccent),
                _macroStat('Fat', '${foodLog.todayFat.toStringAsFixed(1)}g', Colors.orangeAccent),
              ]),
            ]),
          ),
          const SizedBox(height: 36),

          _BarcodeScanCard(),
          const SizedBox(height: 16),
          _StoreMealCard(),
          const SizedBox(height: 36),
          _sectionTitle('Search Food Database'),
          const SizedBox(height: 4),
          Text('Manually find a product and log your intake.', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          const SizedBox(height: 14),
          TextField(
            controller: _searchCtrl,
            decoration: InputDecoration(
              hintText: 'Search by name (e.g. Nutella, Oats…)',
              prefixIcon: const Icon(Icons.search_rounded),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey[300]!)),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          if (_searchQuery.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _FoodSearchResults(query: _searchQuery.trim()),
          ],
          const SizedBox(height: 40),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 36),
          _sectionTitle("Today's Food Log"),
          const SizedBox(height: 16),
          if (foodLog.todaysEntries.isEmpty)
            _emptyCard(Icons.no_meals_rounded, 'No meals logged yet today. Scan a barcode or search above.')
          else ...[
            _DailyMacroBar(controller: foodLog),
            const SizedBox(height: 16),
            ...foodLog.todaysEntries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FoodLogCard(entry: e, onDelete: () => foodLog.removeEntry(e.id)),
            )),
          ],
          const SizedBox(height: 40),
          Divider(color: Colors.grey[200]),
          const SizedBox(height: 36),

          Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              _sectionTitle('Meal Recommendations'),
              Text('Ranked by how well they match your remaining macros.', style: TextStyle(fontSize: 14, color: Colors.grey[600])),
            ])),
            const SizedBox(width: 12),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _loadMeals,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Refresh', style: TextStyle(fontWeight: FontWeight.w600)),
            ),
          ]),
          const SizedBox(height: 24),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Center(child: CircularProgressIndicator()),
            )
          else if (_meals.isEmpty)
            _emptyCard(Icons.restaurant_outlined, 'No meals found. Tap Refresh to try again.')
          else
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: _meals.map((m) => SizedBox(
                width: cardWidth,
                child: _MealCard(
                  meal: m,
                  onTap: () => _showMealDetail(m),
                ),
              )).toList(),
            ),

          if (myMeals.meals.isNotEmpty) ...[
            const SizedBox(height: 40),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 36),
            _sectionTitle('My Saved Meals'),
            const SizedBox(height: 16),
            Wrap(spacing: 16, runSpacing: 16, children: myMeals.meals.take(6).map((m) =>
              Container(
                width: cardWidth,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[200]!)),
                child: Row(children: [
                  Text(m.meal.imageEmoji, style: const TextStyle(fontSize: 28)),
                  const SizedBox(width: 12),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(m.meal.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    Text('${m.meal.calories} kcal · ${m.meal.proteinGrams}g protein', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                  ])),
                  IconButton(
                    icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                    tooltip: 'Remove',
                    onPressed: () => myMeals.removeMeal(m.meal.id),
                  ),
                ]),
              )
            ).toList()),
          ],
        ]),
      ),
    );
  }

  Widget _macroStat(String label, String value, Color color) => Row(mainAxisSize: MainAxisSize.min, children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text('$label: $value', style: const TextStyle(color: Colors.white, fontSize: 13)),
      ]);

  Widget _sectionTitle(String text) =>
      Text(text, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600));

  Widget _emptyCard(IconData icon, String text) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey[200]!)),
        child: Row(children: [
          Icon(icon, color: Colors.grey[400]),
          const SizedBox(width: 14),
          Expanded(child: Text(text, style: TextStyle(color: Colors.grey[600], fontSize: 14))),
        ]),
      );
}


class _MealDetailSheet extends StatelessWidget {
  const _MealDetailSheet({required this.meal, required this.onConfirm, required this.onDismiss});
  final MealRecommendation meal;
  final VoidCallback onConfirm;
  final VoidCallback onDismiss;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      maxChildSize: 0.95,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
          Expanded(child: ListView(controller: ctrl, padding: const EdgeInsets.all(24), children: [
            Row(children: [
              Text(meal.imageEmoji, style: const TextStyle(fontSize: 48)),
              const SizedBox(width: 16),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(meal.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                Text('${meal.category} · ${meal.calories} kcal', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
              ])),
            ]),
            const SizedBox(height: 20),
            Text(meal.description, style: TextStyle(color: Colors.grey[700], height: 1.5, fontSize: 15)),
            const SizedBox(height: 20),
            Wrap(spacing: 10, runSpacing: 8, children: [
              _macroChip('Protein', '${meal.proteinGrams}g', const Color(0xFF2E7D32)),
              _macroChip('Carbs', '${meal.carbsGrams}g', Colors.orange),
              _macroChip('Fat', '${meal.fatsGrams}g', Colors.blue),
            ]),
            if (meal.ingredients.isNotEmpty) ...[
              const SizedBox(height: 24),
              const Text('Ingredients', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...meal.ingredients.map((ing) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(children: [
                  const Icon(Icons.circle, size: 7, color: Color(0xFF2E7D32)),
                  const SizedBox(width: 10),
                  Expanded(child: Text(ing.name, style: const TextStyle(fontSize: 14))),
                  Text(
                    '${ing.amount % 1 == 0 ? ing.amount.toStringAsFixed(0) : ing.amount.toStringAsFixed(1)} ${ing.unit}',
                    style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w600),
                  ),
                ]),
              )),
            ],
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F5E9),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFA5D6A7)),
              ),
              child: Row(children: [
                const Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 16),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Adding this meal will log it to your daily food diary and update your remaining calories.',
                    style: TextStyle(fontSize: 12, color: Color(0xFF2E7D32), height: 1.4),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onDismiss,
                  child: Text('Dismiss', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onConfirm,
                  icon: const Icon(Icons.add_shopping_cart_rounded),
                  label: const Text('Add to My Meals', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
            ]),
          ])),
        ]),
      ),
    );
  }
}

Widget _macroChip(String label, String value, Color color) => Container(
  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
  decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
  child: Column(children: [
    Text(value, style: TextStyle(fontWeight: FontWeight.bold, color: color)),
    Text(label, style: TextStyle(fontSize: 11, color: color)),
  ]),
);


class _ShoppingListSheet extends StatelessWidget {
  const _ShoppingListSheet({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.65,
      maxChildSize: 0.92,
      minChildSize: 0.3,
      builder: (_, ctrl) {
        final shopping = context.watch<ShoppingListController>();
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(children: [
            Container(margin: const EdgeInsets.only(top: 12, bottom: 8), width: 40, height: 4,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4))),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(children: [
                const Icon(Icons.shopping_cart_rounded, color: Color(0xFF2E7D32)),
                const SizedBox(width: 10),
                const Text('Shopping List', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (shopping.items.any((i) => i.isChecked))
                  TextButton.icon(
                    onPressed: () => context.read<ShoppingListController>().clearChecked(),
                    icon: const Icon(Icons.remove_done_rounded, size: 16),
                    label: const Text('Clear checked'),
                    style: TextButton.styleFrom(foregroundColor: Colors.grey[600]),
                  ),
              ]),
            ),
            const Divider(height: 1),
            Expanded(
              child: shopping.isEmpty
                  ? Center(child: Text('No items yet.', style: TextStyle(color: Colors.grey[500])))
                  : ListView.separated(
                      controller: ctrl,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      itemCount: shopping.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 8),
                      itemBuilder: (_, i) {
                        final item = shopping.items[i];
                        return Container(
                          decoration: BoxDecoration(
                            color: item.isChecked ? Colors.grey[100] : Colors.grey[50],
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.grey[200]!),
                          ),
                          child: ListTile(
                            leading: Checkbox(
                              value: item.isChecked,
                              activeColor: const Color(0xFF2E7D32),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                              onChanged: (_) => context.read<ShoppingListController>().toggleItem(item.id),
                            ),
                            title: Text(
                              item.name,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                decoration: item.isChecked ? TextDecoration.lineThrough : null,
                                color: item.isChecked ? Colors.grey : Colors.black87,
                              ),
                            ),
                            subtitle: Text(
                              '${item.amount % 1 == 0 ? item.amount.toStringAsFixed(0) : item.amount.toStringAsFixed(1)} ${item.unit}',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20),
                              onPressed: () => context.read<ShoppingListController>().removeItem(item.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(24, 12, 24, MediaQuery.of(context).viewInsets.bottom + 24),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: onDone,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text('Done', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}
class _StoreMealCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const StoreListScreen()),
        ),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF6A1B9A), Color(0xFFAB47BC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF6A1B9A).withValues(alpha: 0.28),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.storefront_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 18),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Log Store Meal', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text(
                'Browse local restaurants and log a meal directly from their menu.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
              ),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white60, size: 16),
          ]),
        ),
      ),
    );
  }
}

class _BarcodeScanCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const BarcodeScanScreen())),
        child: Container(
          decoration: BoxDecoration(
            gradient: const LinearGradient(colors: [Color(0xFF1B5E20), Color(0xFF43A047)], begin: Alignment.topLeft, end: Alignment.bottomRight),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: const Color(0xFF2E7D32).withValues(alpha: 0.28), blurRadius: 20, offset: const Offset(0, 10))],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.18), borderRadius: BorderRadius.circular(14)),
              child: const Icon(Icons.qr_code_scanner_rounded, color: Colors.white, size: 28),
            ),
            const SizedBox(width: 18),
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Scan a Barcode', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 4),
              Text('Point your camera at any food product barcode to instantly log calories and macros.', style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4)),
            ])),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white60, size: 16),
          ]),
        ),
      ),
    );
  }
}

class _FoodSearchResults extends StatelessWidget {
  const _FoodSearchResults({required this.query});
  final String query;

  @override
  Widget build(BuildContext context) {
    final results = MockFoodDatabase.all.where((p) {
      final q = query.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.brand.toLowerCase().contains(q);
    }).toList();

    if (results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text('No products found for "$query".', style: TextStyle(color: Colors.grey[600])),
      );
    }

    return Column(children: results.map((p) => Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => FoodDetailScreen(product: p))),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey[200]!)),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
              child: const Icon(Icons.fastfood_rounded, color: Color(0xFF2E7D32), size: 20)),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
              Text('${p.brand}  ·  ${p.caloriesPer100g.toStringAsFixed(0)} kcal / 100${p.servingUnit}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ])),
            const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF2E7D32)),
          ]),
        ),
      ),
    )).toList());
  }
}

class _DailyMacroBar extends StatelessWidget {
  const _DailyMacroBar({required this.controller});
  final FoodLogController controller;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(14), border: Border.all(color: const Color(0xFFA5D6A7))),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
      Flexible(child: _macroTile('Calories', '${controller.todayCalories.toStringAsFixed(0)} kcal', Colors.orange)),
      Flexible(child: _macroTile('Protein', '${controller.todayProtein.toStringAsFixed(1)} g', const Color(0xFF2E7D32))),
      Flexible(child: _macroTile('Carbs', '${controller.todayCarbs.toStringAsFixed(1)} g', Colors.blue)),
      Flexible(child: _macroTile('Fat', '${controller.todayFat.toStringAsFixed(1)} g', Colors.purple)),
    ]),
  );

  Widget _macroTile(String label, String value, Color color) => Column(children: [
    Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: color)),
    const SizedBox(height: 3),
    Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
  ]);
}

class _FoodLogCard extends StatelessWidget {
  const _FoodLogCard({required this.entry, required this.onDelete});
  final dynamic entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: Colors.grey[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey[200]!)),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(10)),
        child: const Icon(Icons.fastfood_rounded, color: Color(0xFF2E7D32), size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(entry.product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        Text('${entry.quantityG.toStringAsFixed(0)} ${entry.product.servingUnit}  ·  ${entry.calories.toStringAsFixed(0)} kcal', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ])),
      IconButton(icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent, size: 20), onPressed: onDelete),
    ]),
  );
}

class _MealCard extends StatelessWidget {
  const _MealCard({required this.meal, required this.onTap});
  final MealRecommendation meal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final myMeals = context.watch<MyMealsController>();
    final saved = myMeals.isSaved(meal.id);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: saved ? const Color(0xFFA5D6A7) : Colors.grey[200]!, width: saved ? 2 : 1),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Text(meal.imageEmoji, style: const TextStyle(fontSize: 36)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(meal.title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text('${meal.category} · ${meal.calories} kcal', style: TextStyle(color: Colors.grey[600], fontSize: 13)),
              ])),
              if (saved)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(20)),
                  child: const Text('Saved', style: TextStyle(fontSize: 11, color: Color(0xFF2E7D32), fontWeight: FontWeight.w700)),
                ),
            ]),
            const SizedBox(height: 12),
            Text(meal.description, style: TextStyle(color: Colors.grey[700], fontSize: 13, height: 1.4)),
            const SizedBox(height: 14),
            Wrap(spacing: 8, runSpacing: 8, children: [
              _chip('${meal.proteinGrams}g protein', const Color(0xFF2E7D32)),
              _chip('${meal.carbsGrams}g carbs', Colors.orange),
              _chip('${meal.fatsGrams}g fat', Colors.blue),
            ]),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: Text('Tap for details →', style: TextStyle(fontSize: 12, color: Colors.grey[500], fontStyle: FontStyle.italic)),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _chip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: color.withValues(alpha: 0.09), borderRadius: BorderRadius.circular(10)),
    child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}