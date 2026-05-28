import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/state/session_controller.dart';
import 'features/auth/data/mock_auth_service.dart';
import 'features/coach_plans/state/coach_plan_controller.dart';
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
      ],
      child: const GetFitApp(),
    ),
  );
}