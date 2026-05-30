import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/state/session_controller.dart';
import 'features/auth/data/mock_auth_service.dart';
import 'features/barcode/state/food_log_controller.dart';
import 'features/coach_plans/state/coach_plan_controller.dart';
import 'features/health_sync/state/google_fit_connector.dart';
import 'features/meals/state/my_meals_controller.dart';
import 'features/meals/state/shopping_list_controller.dart';
import 'features/progress/state/progress_controller.dart';
import 'features/workouts/state/workout_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sessionController = SessionController(MockAuthService());
  await sessionController.initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: sessionController),
        ChangeNotifierProvider(create: (_) => WorkoutController()),
        ChangeNotifierProvider(create: (_) => CoachPlanController()),
        ChangeNotifierProvider(create: (_) => ProgressController()),
        ChangeNotifierProvider(create: (_) => FoodLogController()),
        ChangeNotifierProvider(create: (_) => GoogleFitConnector()),
        ChangeNotifierProvider(create: (_) => MyMealsController()),
        ChangeNotifierProvider(create: (_) => ShoppingListController()),
      ],
      child: const GetFitApp(),
    ),
  );
}