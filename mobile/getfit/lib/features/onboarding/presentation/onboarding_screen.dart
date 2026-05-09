import 'package:flutter/material.dart';
import '../../home/presentation/home_shell.dart';

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

  InputDecoration _dropdownDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(
        color: Colors.grey[700],
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
        borderSide: BorderSide(color: Color(0xFF2E7D32), width: 2),
      ),
    );
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
                            decoration: _inputDecoration(
                              'Full name',
                              Icons.badge_outlined,
                            ),
                            validator: (value) =>
                                value == null || value.trim().isEmpty
                                ? 'Enter your name'
                                : null,
                          ),
                        ),
                        _fieldBox(
                          child: TextFormField(
                            controller: _ageController,
                            decoration: _inputDecoration(
                              'Age',
                              Icons.cake_outlined,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        _fieldBox(
                          child: TextFormField(
                            controller: _heightController,
                            decoration: _inputDecoration(
                              'Height (cm)',
                              Icons.height,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        _fieldBox(
                          child: TextFormField(
                            controller: _weightController,
                            decoration: _inputDecoration(
                              'Weight (kg)',
                              Icons.monitor_weight_outlined,
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        _fieldBox(
                          child: DropdownButtonFormField<String>(
                            initialValue: _sex,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF2E7D32),
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _dropdownDecoration(
                              'Sex',
                              Icons.wc_outlined,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'male',
                                child: Text('Male'),
                              ),
                              DropdownMenuItem(
                                value: 'female',
                                child: Text('Female'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _sex = value);
                            },
                          ),
                        ),
                        _fieldBox(
                          child: DropdownButtonFormField<String>(
                            initialValue: _goal,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF2E7D32),
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _dropdownDecoration(
                              'Goal',
                              Icons.flag_outlined,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'lose_weight',
                                child: Text('Lose weight'),
                              ),
                              DropdownMenuItem(
                                value: 'maintain_weight',
                                child: Text('Maintain weight'),
                              ),
                              DropdownMenuItem(
                                value: 'gain_weight',
                                child: Text('Gain weight'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _goal = value);
                            },
                          ),
                        ),
                        _fieldBox(
                          child: DropdownButtonFormField<String>(
                            initialValue: _activityLevel,
                            icon: const Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: Color(0xFF2E7D32),
                            ),
                            dropdownColor: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            style: const TextStyle(
                              color: Colors.black87,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _dropdownDecoration(
                              'Activity level',
                              Icons.directions_run_outlined,
                            ),
                            items: const [
                              DropdownMenuItem(
                                value: 'sedentary',
                                child: Text('Sedentary'),
                              ),
                              DropdownMenuItem(
                                value: 'lightly_active',
                                child: Text('Lightly active'),
                              ),
                              DropdownMenuItem(
                                value: 'moderately_active',
                                child: Text('Moderately active'),
                              ),
                              DropdownMenuItem(
                                value: 'active',
                                child: Text('Active'),
                              ),
                              DropdownMenuItem(
                                value: 'very_active',
                                child: Text('Very active'),
                              ),
                            ],
                            onChanged: (value) {
                              if (value == null) return;
                              setState(() => _activityLevel = value);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 48),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 32,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => HomeShell(
                                  userName: _nameController.text.trim().isEmpty
                                      ? 'User'
                                      : _nameController.text.trim(),
                                ),
                              ),
                            );
                          }
                        },
                        icon: const Icon(Icons.arrow_forward),
                        label: const Text(
                          'Finish setup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
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
