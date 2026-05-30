class StoreMealItem {
  final String id;
  final String name;
  final String category;
  final String emoji;
  final int calories;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final double servingGrams;

  const StoreMealItem({
    required this.id,
    required this.name,
    required this.category,
    required this.calories,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    this.emoji = '🍽️',
    this.servingGrams = 100,
  });
}