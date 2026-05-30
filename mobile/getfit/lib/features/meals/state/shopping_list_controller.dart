import 'package:flutter/material.dart';
import '../domain/meal_ingredient.dart';
import '../domain/shopping_list_item.dart';

class ShoppingListController extends ChangeNotifier {
  final List<ShoppingListItem> _items = [];

  List<ShoppingListItem> get items => List.unmodifiable(_items);
  bool get isEmpty => _items.isEmpty;

  void addFromIngredients(List<MealIngredient> ingredients) {
    for (final ing in ingredients) {
      final existing = _items.indexWhere(
          (i) => i.name.toLowerCase() == ing.name.toLowerCase() && i.unit == ing.unit);
      if (existing >= 0) {
        _items[existing] = _items[existing].copyWith(
          amount: _items[existing].amount + ing.amount,
        );
      } else {
        _items.add(ShoppingListItem(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: ing.name,
          amount: ing.amount,
          unit: ing.unit,
        ));
      }
    }
    notifyListeners();
  }

  void toggleItem(String id) {
    final i = _items.indexWhere((item) => item.id == id);
    if (i < 0) return;
    _items[i] = _items[i].copyWith(isChecked: !_items[i].isChecked);
    notifyListeners();
  }

  void removeItem(String id) {
    _items.removeWhere((i) => i.id == id);
    notifyListeners();
  }

  void clearChecked() {
    _items.removeWhere((i) => i.isChecked);
    notifyListeners();
  }

  void clearAll() {
    _items.clear();
    notifyListeners();
  }
}