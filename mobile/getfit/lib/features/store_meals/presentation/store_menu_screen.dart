import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../barcode/domain/food_product.dart';
import '../../barcode/state/food_log_controller.dart';
import '../domain/store.dart';
import '../domain/store_meal_item.dart';

class StoreMenuScreen extends StatefulWidget {
  const StoreMenuScreen({super.key, required this.store});
  final Store store;

  @override
  State<StoreMenuScreen> createState() => _StoreMenuScreenState();
}

class _StoreMenuScreenState extends State<StoreMenuScreen> {
  String _selectedCategory = 'All';

  List<String> get _categories => ['All', ...widget.store.categories];

  List<StoreMealItem> get _filtered {
    if (_selectedCategory == 'All') return widget.store.menu;
    return widget.store.menu.where((i) => i.category == _selectedCategory).toList();
  }

  void _showItemDetail(StoreMealItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ItemDetailSheet(
        item: item,
        storeName: widget.store.name,
        onConfirm: () {
          Navigator.pop(context);
          _logItem(item);
        },
        onCancel: () => Navigator.pop(context),
      ),
    );
  }

  void _logItem(StoreMealItem item) {
    final foodLog = context.read<FoodLogController>();
    final scaleFactor = 100.0 / item.servingGrams;
    final product = FoodProduct(
      barcode: 'store_${widget.store.id}_${item.id}',
      name: '${widget.store.name} – ${item.name}',
      brand: widget.store.name,
      caloriesPer100g: item.calories * scaleFactor,
      proteinPer100g: item.proteinGrams * scaleFactor,
      carbsPer100g: item.carbsGrams * scaleFactor,
      fatsPer100g: item.fatsGrams * scaleFactor,
      typicalServingG: item.servingGrams.toDouble(),
    );

    foodLog.logFood(product: product, quantityG: item.servingGrams.toDouble());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF2E7D32),
        content: Row(children: [
          const Icon(Icons.check_circle_outline, color: Colors.white),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${item.name} logged — ${item.calories} kcal added to today\'s diary.',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ]),
      ),
    );
    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Row(children: [
          Text(widget.store.emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(widget.store.name,
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis),
          ),
        ]),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Divider(height: 1),
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (_, i) {
                      final cat = _categories[i];
                      final selected = cat == _selectedCategory;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? const Color(0xFF2E7D32) : Colors.grey[100],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: selected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
                            ),
                          ),
                          child: Text(
                            cat,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                              color: selected ? Colors.white : Colors.grey[700],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.all(isMobile ? 12 : 20),
              itemCount: _filtered.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, i) => _MenuItemCard(
                item: _filtered[i],
                onTap: () => _showItemDetail(_filtered[i]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item, required this.onTap});
  final StoreMealItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 24))),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(item.category,
                        style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                    const SizedBox(height: 8),
                    Wrap(spacing: 6, runSpacing: 4, children: [
                      _macroChip('${item.calories} kcal', Colors.orange),
                      _macroChip('${item.proteinGrams.toStringAsFixed(0)}g P', const Color(0xFF2E7D32)),
                      _macroChip('${item.carbsGrams.toStringAsFixed(0)}g C', Colors.blue),
                      _macroChip('${item.fatsGrams.toStringAsFixed(0)}g F', Colors.purple),
                    ]),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.add_circle_outline_rounded, color: Color(0xFF2E7D32), size: 26),
            ],
          ),
        ),
      ),
    );
  }

  Widget _macroChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.1),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color)),
  );
}


class _ItemDetailSheet extends StatelessWidget {
  const _ItemDetailSheet({
    required this.item,
    required this.storeName,
    required this.onConfirm,
    required this.onCancel,
  });
  final StoreMealItem item;
  final String storeName;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.6,
      maxChildSize: 0.85,
      minChildSize: 0.4,
      builder: (_, ctrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(children: [
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(4)),
          ),
          Expanded(
            child: ListView(controller: ctrl, padding: const EdgeInsets.all(24), children: [
              Row(children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(child: Text(item.emoji, style: const TextStyle(fontSize: 34))),
                ),
                const SizedBox(width: 16),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(storeName, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                  Text(item.category, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
                ])),
              ]),
              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFA5D6A7)),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.info_outline_rounded, color: Color(0xFF2E7D32), size: 16),
                    const SizedBox(width: 8),
                    Text(
                      'Nutritional values · serving ${item.servingGrams.toStringAsFixed(0)} g',
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF2E7D32)),
                    ),
                  ]),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    Flexible(child: _nutriStat('Calories', '${item.calories}', 'kcal', Colors.orange)),
                    Flexible(child: _nutriStat('Protein', item.proteinGrams.toStringAsFixed(1), 'g', const Color(0xFF2E7D32))),
                    Flexible(child: _nutriStat('Carbs', item.carbsGrams.toStringAsFixed(1), 'g', Colors.blue)),
                    Flexible(child: _nutriStat('Fat', item.fatsGrams.toStringAsFixed(1), 'g', Colors.purple)),
                  ]),
                ]),
              ),

              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Row(children: [
                  Icon(Icons.bolt_rounded, color: Colors.orange[600], size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Confirming will add this item to your food diary and update your daily calorie total.',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600], height: 1.4),
                    ),
                  ),
                ]),
              ),

              const SizedBox(height: 28),
              Row(children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onCancel,
                    child: Text('Cancel', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600)),
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
                    icon: const Icon(Icons.check_circle_outline_rounded),
                    label: const Text('Log This Meal', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _nutriStat(String label, String value, String unit, Color color) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(value,
          style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
      Text(unit, style: TextStyle(fontSize: 10, color: color)),
      const SizedBox(height: 2),
      Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
    ],
  );
}