import 'package:flutter/material.dart';
import '../domain/meal_recommendation.dart';
import '../domain/my_meal.dart';

class MyMealsController extends ChangeNotifier {
  final List<MyMeal> _meals = [];

  List<MyMeal> get meals => List.unmodifiable(_meals);

  bool isSaved(String mealId) => _meals.any((m) => m.meal.id == mealId);

  void saveMeal(MealRecommendation meal) {
    if (isSaved(meal.id)) return;
    _meals.insert(0, MyMeal(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      meal: meal,
      savedAt: DateTime.now(),
    ));
    notifyListeners();
  }

  void removeMeal(String mealId) {
    _meals.removeWhere((m) => m.meal.id == mealId);
    notifyListeners();
  }
}