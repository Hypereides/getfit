import 'meal_recommendation.dart';

class MyMeal {
  final String id;
  final MealRecommendation meal;
  final DateTime savedAt;

  const MyMeal({
    required this.id,
    required this.meal,
    required this.savedAt,
  });
}