import 'package:flutter/material.dart';
import '../features/auth/presentation/login_screen.dart';

class GetFitApp extends StatelessWidget {
  const GetFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GetFit',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
      ),
      home: const LoginScreen(),
    );
  }
}