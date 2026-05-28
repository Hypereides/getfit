import 'package:flutter/cupertino.dart';
import 'package:getfit/core/models/food_metric.dart';

class FoodMetricsAmounts extends ChangeNotifier {
  final Map<FoodMetric, int> _metricsAmounts = {};

  FoodMetricsAmounts();

  Map<FoodMetric, int> getAmounts() {
    return _metricsAmounts;
  }

  void addAmount(FoodMetric metric, int amount) {
    if (_metricsAmounts[metric] != null) {
      _metricsAmounts[metric] = _metricsAmounts[metric]! + amount;
    } else {
      _metricsAmounts[metric] = amount;
    }
    notifyListeners();
  }

  int getAmount(FoodMetric metric) {
    return _metricsAmounts[metric] ?? 0;
  }
}
