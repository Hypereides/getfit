class FoodProduct {
  final String barcode;
  final String name;
  final String brand;
  final double caloriesPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatsPer100g;
  final double fiberPer100g;
  final double sugarPer100g;
  final String servingUnit; // grams or lml
  final double typicalServingG;

  const FoodProduct({
    required this.barcode,
    required this.name,
    required this.brand,
    required this.caloriesPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatsPer100g,
    this.fiberPer100g = 0,
    this.sugarPer100g = 0,
    this.servingUnit = 'g',
    this.typicalServingG = 100,
  });

  double caloriesFor(double quantity) => caloriesPer100g * quantity / 100;
  double proteinFor(double quantity) => proteinPer100g * quantity / 100;
  double carbsFor(double quantity) => carbsPer100g * quantity / 100;
  double fatFor(double quantity) => fatsPer100g * quantity / 100;
}