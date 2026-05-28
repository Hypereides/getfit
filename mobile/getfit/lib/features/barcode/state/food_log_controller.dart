import 'package:flutter/material.dart';
import '../domain/food_log_entry.dart';
import '../domain/food_product.dart';

class FoodLogController extends ChangeNotifier {
  final List<FoodLogEntry> _entries = [];

  List<FoodLogEntry> get entries => List.unmodifiable(_entries);
  List<FoodLogEntry> get todaysEntries {
    final now = DateTime.now();
    return _entries
        .where((e) =>
            e.date.year == now.year &&
            e.date.month == now.month &&
            e.date.day == now.day)
        .toList();
  }
  double get todayCalories =>
      todaysEntries.fold(0, (s, e) => s + e.calories);
  double get todayProtein =>
      todaysEntries.fold(0, (s, e) => s + e.protein);
  double get todayCarbs =>
      todaysEntries.fold(0, (s, e) => s + e.carbs);
  double get todayFat =>
      todaysEntries.fold(0, (s, e) => s + e.fat);

  void logFood({
    required FoodProduct product,
    required double quantityG,
  }) {
    _entries.add(
      FoodLogEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        product: product,
        quantityG: quantityG,
      ),
    );
    notifyListeners();
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}