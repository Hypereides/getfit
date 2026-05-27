import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app/app.dart';
import 'core/state/session_controller.dart';
import 'features/auth/data/mock_auth_service.dart';
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
      ],
      child: const GetFitApp(),
    ),
  );
}