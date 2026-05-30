import 'meal_ingredient.dart';

class MealRecommendation {
  final String id;
  final String title;
  final String category;
  final int calories;
  final int proteinGrams;
  final int carbsGrams;
  final int fatsGrams;
  final String description;
  final String imageEmoji;
  final List<MealIngredient> ingredients;

  const MealRecommendation({
    required this.id,
    required this.title,
    required this.category,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.description,
    this.imageEmoji = '🍽️',
    this.ingredients = const [],
  });
}