import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/session_controller.dart';
import '../../../core/widgets/app_dropdown_field.dart';
import '../../home/presentation/home_shell.dart';
import '../../auth/domain/fitness_profile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  String _sex = 'male';
  String _goal = 'lose_weight';
  String _activityLevel = 'moderately_active';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }

  double _calculateBmi(double heightCm, double weightKg) {
    final heightM = heightCm / 100;
    if (heightM <= 0) return 0;
    return weightKg / (heightM * heightM);
  }

  double _activityMultiplier(String activityLevel) {
    switch (activityLevel) {
      case 'sedentary':
        return 1.2;
      case 'lightly_active':
        return 1.375;
      case 'moderately_active':
        return 1.55;
      case 'active':
        return 1.725;
      case 'very_active':
        return 1.9;
      default:
        return 1.55;
    }
  }

  double _calculateTdee({
    required String sex,
    required int age,
    required double heightCm,
    required double weightKg,
    required String activityLevel,
  }) {
    final bmr = sex == 'male'
        ? 10 * weightKg + 6.25 * heightCm - 5 * age + 5
        : 10 * weightKg + 6.25 * heightCm - 5 * age - 161;

    return bmr * _activityMultiplier(activityLevel);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    final age = int.tryParse(_ageController.text.trim()) ?? 0;
    final heightCm = double.tryParse(_heightController.text.trim()) ?? 0;
    final weightKg = double.tryParse(_weightController.text.trim()) ?? 0;

    final bmi = _calculateBmi(heightCm, weightKg);
    final tdee = _calculateTdee(
      sex: _sex,
      age: age,
      heightCm: heightCm,
      weightKg: weightKg,
      activityLevel: _activityLevel,
    );

    final profile = FitnessProfile(
      name: name.isEmpty ? 'User' : name,
      age: age,
      sex: _sex,
      heightCm: heightCm,
      weightKg: weightKg,
      goal: _goal,
      activityLevel: _activityLevel,
      bmi: bmi,
      tdee: tdee,
    );

    setState(() => _isSubmitting = true);

    try {
      final email = '${profile.name.toLowerCase().replaceAll(' ', '')}@getfit.local';
      const password = '123456';

      await context.read<SessionController>().register(
            email: email,
            password: password,
            profile: profile,
          );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: const Text(
          'GetFit Onboarding',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 24,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(48),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFE8F5E9),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.person_outline,
                            color: Color(0xFF2E7D32),
                            size: 32,
                          ),
                        ),
                        const SizedBox(width: 16),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Profile setup',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Fill in your metrics for personalized fitness recommendations.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Wrap(
                      runSpacing: 24,
                      spacing: 24,
                      children: [
                        _fieldBox(
                          child: TextFormField(
                            controller: _nameController,
                            decoration: _inputDecoration('Full name', Icons.badge_outlined),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Enter your name' : null,
                          ),
                        ),
                        _fieldBox(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: _inputDecoration('Age', Icons.cake_outlined),
                            keyboardType: TextInputType.number,
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Enter your age' : null,
                          ),
                        ),
                        _fieldBox(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: _inputDecoration('Height (cm)', Icons.height),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Enter your height' : null,
                          ),
                        ),
                        _fieldBox(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: _inputDecoration('Weight (kg)', Icons.monitor_weight_outlined),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: (value) =>
                                value == null || value.trim().isEmpty ? 'Enter your weight' : null,
                          ),
                        ),
                        AppDropdownField<String>(
                          label: 'Sex',
                          value: _sex,
                          items: const [
                            DropdownMenuItem(value: 'male', child: Text('Male')),
                            DropdownMenuItem(value: 'female', child: Text('Female')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _sex = value);
                          },
                        ),
                        AppDropdownField<String>(
                          label: 'Goal',
                          value: _goal,
                          items: const [
                            DropdownMenuItem(value: 'lose_weight', child: Text('Lose weight')),
                            DropdownMenuItem(value: 'maintain_weight', child: Text('Maintain weight')),
                            DropdownMenuItem(value: 'gain_weight', child: Text('Gain weight')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _goal = value);
                          },
                        ),
                        AppDropdownField<String>(
                          label: 'Activity level',
                          value: _activityLevel,
                          items: const [
                            DropdownMenuItem(value: 'sedentary', child: Text('Sedentary')),
                            DropdownMenuItem(value: 'lightly_active', child: Text('Lightly active')),
                            DropdownMenuItem(value: 'moderately_active', child: Text('Moderately active')),
                            DropdownMenuItem(value: 'active', child: Text('Active')),
                            DropdownMenuItem(value: 'very_active', child: Text('Very active')),
                          ],
                          onChanged: (value) {
                            if (value == null) return;
                            setState(() => _activityLevel = value);
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 32),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                        onPressed: _isSubmitting ? null : _submit,
                        icon: const Icon(Icons.arrow_forward),
                        label: Text(
                          _isSubmitting ? 'Saving...' : 'Finish setup',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _fieldBox({required Widget child}) {
    return SizedBox(width: 280, child: child);
  }
}