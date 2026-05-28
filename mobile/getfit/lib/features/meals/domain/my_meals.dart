import 'package:flutter/cupertino.dart';
import 'package:getfit/features/meals/domain/meal.dart';

class MyMeals extends ChangeNotifier {
  final List<Meal> _meals = [];

  List<Meal> getMeals() {
    return _meals;
  }

  void addMeal(Meal meal) {
    _meals.add(meal);
    notifyListeners();
  }
}
