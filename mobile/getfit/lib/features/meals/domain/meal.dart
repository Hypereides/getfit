import 'package:getfit/core/models/ingredient.dart';

class Meal {
  final String id;
  final String title;
  final String imageUrl;

  int? calories;
  int? proteinGrams;
  int? carbsGrams;
  int? fatsGrams;

  String? summary;
  String? instructions;
  List<Ingredient>? ingredients;

  Meal({
    required this.id,
    required this.title,
    required this.imageUrl,

    this.calories,
    this.proteinGrams,
    this.carbsGrams,
    this.fatsGrams,

    this.summary,
    this.instructions,
    this.ingredients,
  });
}
