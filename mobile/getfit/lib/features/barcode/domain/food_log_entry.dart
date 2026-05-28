import 'food_product.dart';

class FoodLogEntry {
  final String id;
  final DateTime date;
  final FoodProduct product;
  final double quantityG;

  const FoodLogEntry({
    required this.id,
    required this.date,
    required this.product,
    required this.quantityG,
  });

  double get calories => product.caloriesFor(quantityG);
  double get protein  => product.proteinFor(quantityG);
  double get carbs    => product.carbsFor(quantityG);
  double get fat      => product.fatFor(quantityG);
}