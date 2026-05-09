import '../domain/meal_recommendation.dart';

class MealRecommendationService {
  Future<List<MealRecommendation>> getRecommendations({
    required String goal,
  }) async {
    await Future.delayed(const Duration(milliseconds: 700));

    if (goal == 'gain_weight') {
      return const [
        MealRecommendation(
          id: '1',
          title: 'Chicken Rice Bowl',
          category: 'Lunch',
          calories: 720,
          proteinGrams: 48,
          carbsGrams: 72,
          fatsGrams: 18,
          description: 'High-protein bowl for muscle gain and post-workout recovery.',
        ),
        MealRecommendation(
          id: '2',
          title: 'Greek Yogurt Oats',
          category: 'Breakfast',
          calories: 560,
          proteinGrams: 30,
          carbsGrams: 58,
          fatsGrams: 14,
          description: 'Dense breakfast with oats, yogurt, banana, and peanut butter.',
        ),
      ];
    }

    if (goal == 'maintain_weight') {
      return const [
        MealRecommendation(
          id: '3',
          title: 'Salmon with Potatoes',
          category: 'Dinner',
          calories: 610,
          proteinGrams: 40,
          carbsGrams: 42,
          fatsGrams: 24,
          description: 'Balanced dinner with protein, healthy fats, and complex carbs.',
        ),
        MealRecommendation(
          id: '4',
          title: 'Turkey Wrap',
          category: 'Lunch',
          calories: 430,
          proteinGrams: 29,
          carbsGrams: 35,
          fatsGrams: 14,
          description: 'A balanced wrap for steady daily energy and good satiety.',
        ),
      ];
    }

    return const [
      MealRecommendation(
        id: '5',
        title: 'Grilled Chicken Salad',
        category: 'Lunch',
        calories: 380,
        proteinGrams: 36,
        carbsGrams: 18,
        fatsGrams: 14,
        description: 'Lean protein meal for fat loss with good volume and low calories.',
      ),
      MealRecommendation(
        id: '6',
        title: 'Egg White Breakfast Plate',
        category: 'Breakfast',
        calories: 320,
        proteinGrams: 28,
        carbsGrams: 20,
        fatsGrams: 9,
        description: 'Light breakfast focused on protein and controlled calories.',
      ),
    ];
  }
}