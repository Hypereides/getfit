import 'package:flutter/cupertino.dart';
import 'package:getfit/core/models/ingredient.dart';

class ShoppingList extends ChangeNotifier {
  final List<Ingredient> _ingredients = [];

  List<Ingredient> getList() {
    return _ingredients;
  }

  void addIngredient(Ingredient ingredient) {
    _ingredients.add(ingredient);
    notifyListeners();
  }

  void addIngredients(List<Ingredient> ingredients) {
    _ingredients.addAll(ingredients);
  }

  bool isEmpty() {
    return _ingredients.isEmpty;
  }
}
