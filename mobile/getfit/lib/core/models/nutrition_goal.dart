import 'food_metrics_amounts.dart';

class NutritionGoal extends FoodMetricsAmounts {
  FoodMetricsAmounts calcNeeded(FoodMetricsAmounts consumed) {
    final needed = FoodMetricsAmounts();

    for (var entry in getAmounts().entries) {
      var neededAmount = entry.value - consumed.getAmount(entry.key);

      if (neededAmount > 0) {
        needed.addAmount(entry.key, neededAmount);
      }
    }

    return needed;
  }
}
