import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/models/food_metric.dart';
import 'core/models/food_metrics_amounts.dart';
import 'core/models/ingredient.dart';
import 'core/models/nutrition_goal.dart';
import 'core/state/session_controller.dart';
import 'features/auth/data/mock_auth_service.dart';
import 'features/barcode/state/food_log_controller.dart';
import 'features/coach_plans/state/coach_plan_controller.dart';
import 'features/health_sync/state/health_sync_controller.dart';
import 'features/progress/state/progress_controller.dart';
import 'features/workouts/state/workout_controller.dart';
import 'features/meals/domain/my_meals.dart';
import 'features/meals/domain/shopping_list.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionController = SessionController(MockAuthService());
  await sessionController.initialize();

  final dailyNutrition = FoodMetricsAmounts();
  dailyNutrition.addAmount(FoodMetric.calories, 400);

  final dailyNutritionGoal = NutritionGoal();
  dailyNutritionGoal.addAmount(FoodMetric.calories, 700);

  final shoppingList = ShoppingList();

  final MyMeals myMeals = MyMeals();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionController),
        ChangeNotifierProvider(create: (_) => WorkoutController()),
        ChangeNotifierProvider(create: (_) => CoachPlanController()),
        ChangeNotifierProvider(create: (_) => ProgressController()),
        ChangeNotifierProvider(create: (_) => FoodLogController()),
        ChangeNotifierProvider(create: (_) => HealthSyncController()),
        ChangeNotifierProvider(create: (_) => dailyNutrition),
        ChangeNotifierProvider(create: (_) => dailyNutritionGoal),
        ChangeNotifierProvider(create: (_) => shoppingList),
        ChangeNotifierProvider(create: (_) => myMeals),
      ],
      child: const GetFitApp(),
    ),
  );
}
