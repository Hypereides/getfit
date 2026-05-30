import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/data/country_city_data.dart';
import '../../../core/state/session_controller.dart';
import '../../auth/domain/fitness_profile.dart';
import '../../home/presentation/home_shell.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  bool _isSubmitting = false;

  final _credKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  bool _isPremium = false;

  final _statsKey = GlobalKey<FormState>();
  final _ageCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  String _sex = 'male';
  String? _selectedBodyFat;

  static const _bodyFatOptions = [
    'Under 10%', '10–15%', '15–20%', '20–25%', '25–30%',
    'Over 30%', 'Prefer not to say',
  ];

  String _goal = 'lose_weight';
  String _activityLevel = 'moderately_active';
  String _workoutPref = 'both';
  String _country = 'Greece';
  String _city = 'Athens';
  double _suggestedRate = -0.5;
  double _chosenRate = -0.5;
  double _bmi = 0;
  double _tdee = 0;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _ageCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    super.dispose();
  }

  double _calcBmi(double h, double w) {
    final hm = h / 100;
    if (hm <= 0) return 0;
    return w / (hm * hm);
  }

  double _actMult(String level) => switch (level) {
        'sedentary' => 1.2,
        'lightly_active' => 1.375,
        'moderately_active' => 1.55,
        'active' => 1.725,
        'very_active' => 1.9,
        _ => 1.55,
      };

  double _calcTdee(String sex, int age, double h, double w, String level) {
    final bmr = sex == 'male'
        ? 10 * w + 6.25 * h - 5 * age + 5
        : 10 * w + 6.25 * h - 5 * age - 161;
    return bmr * _actMult(level);
  }

  double _defaultRate(String goal) => switch (goal) {
        'lose_weight' => -0.5,
        'gain_weight' => 0.5,
        _ => 0.0,
      };

  double _targetCalories(double rate) {
    final delta = rate * 7700 / 7;
    return (_tdee + delta).clamp(800, 6000);
  }

  double? get _parsedBodyFat {
    if (_selectedBodyFat == null || _selectedBodyFat == 'Prefer not to say') {
      return null;
    }
    return switch (_selectedBodyFat) {
      'Under 10%' => 8.0,
      '10–15%' => 12.5,
      '15–20%' => 17.5,
      '20–25%' => 22.5,
      '25–30%' => 27.5,
      'Over 30%' => 32.0,
      _ => null,
    };
  }

  void _next() {
    if (_currentStep == 0) {
      if (!_credKey.currentState!.validate()) return;
    }
    if (_currentStep == 2) {
      if (!_statsKey.currentState!.validate()) return;
      final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
      final h = double.tryParse(_heightCtrl.text.trim()) ?? 0;
      final w = double.tryParse(_weightCtrl.text.trim()) ?? 0;
      _bmi = _calcBmi(h, w);
      _tdee = _calcTdee(_sex, age, h, w, _activityLevel);
    }
    if (_currentStep == 3) {
      _suggestedRate = _defaultRate(_goal);
      _chosenRate = _suggestedRate;
    }
    setState(() => _currentStep++);
  }

  void _back() => setState(() => _currentStep--);

  Future<void> _submit() async {
    setState(() => _isSubmitting = true);

    final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
    final h = double.tryParse(_heightCtrl.text.trim()) ?? 0;
    final w = double.tryParse(_weightCtrl.text.trim()) ?? 0;

    final profile = FitnessProfile(
      name: _nameCtrl.text.trim(),
      age: age,
      sex: _sex,
      heightCm: h,
      weightKg: w,
      goal: _goal,
      activityLevel: _activityLevel,
      bmi: _bmi,
      tdee: _tdee,
      bodyFatPercent: _parsedBodyFat,
      workoutPreferences: _workoutPref,
      targetRateOfChange: _chosenRate,
      country: _country,
      city: _city,
    );

    try {
      await context.read<SessionController>().register(
            email: _emailCtrl.text.trim(),
            password: _passCtrl.text.trim(),
            username: _usernameCtrl.text.trim(),
            premiumEnabled: _isPremium,
            profile: profile,
          );

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeShell()),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: Colors.red[700],
          content: Text('Registration failed: ${e.toString().replaceAll('Exception: ', '')}'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  InputDecoration _dec(String label, IconData icon, {Widget? suffix}) =>
      InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w500),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffix: suffix,
        filled: true,
        fillColor: Colors.grey[50],
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
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      );

  Widget _field({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
    String? Function(String?)? validator,
  }) =>
      SizedBox(
        width: 300,
        child: TextFormField(
          controller: ctrl,
          keyboardType: keyboard,
          obscureText: obscure,
          decoration: _dec(label, icon, suffix: suffix),
          validator: validator,
        ),
      );

  Widget _dropdownSmall<T>({
    required String label,
    required T value,
    required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged,
    double width = 300,
  }) =>
      SizedBox(
        width: width,
        child: DropdownButtonFormField<T>(
          initialValue: value,
          icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Color(0xFF2E7D32)),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(16),
          style: const TextStyle(color: Colors.black87, fontSize: 15, fontWeight: FontWeight.w600),
          decoration: _dec(label, Icons.arrow_drop_down_circle_outlined),
          items: items,
          onChanged: onChanged,
        ),
      );

  Widget _buildStep0() => Form(
        key: _credKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _stepHeader('Create your account', 'Enter your login details to get started.', Icons.person_add_outlined),
          const SizedBox(height: 32),
          Wrap(spacing: 20, runSpacing: 20, children: [
            _field(
              ctrl: _nameCtrl,
              label: 'Full name',
              icon: Icons.badge_outlined,
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Enter your name' : null,
            ),
            _field(
              ctrl: _usernameCtrl,
              label: 'Username',
              icon: Icons.alternate_email_rounded,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a username';
                if (v.trim().length < 3) return 'At least 3 characters';
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(v.trim())) {
                  return 'Only letters, numbers and underscore';
                }
                return null;
              },
            ),
            _field(
              ctrl: _emailCtrl,
              label: 'Email address',
              icon: Icons.email_outlined,
              keyboard: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your email';
                if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                return null;
              },
            ),
            _field(
              ctrl: _passCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              obscure: _obscurePass,
              suffix: GestureDetector(
                onTap: () => setState(() => _obscurePass = !_obscurePass),
                child: Icon(
                  _obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                  color: Colors.grey[600],
                  size: 20,
                ),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter a password';
                if (v.trim().length < 6) return 'At least 6 characters';
                return null;
              },
            ),
          ]),
        ]),
      );

  Widget _buildStep1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        _stepHeader('Choose your plan', 'Select the account type that fits you best.', Icons.workspace_premium_outlined),
        const SizedBox(height: 32),
        Wrap(spacing: 20, runSpacing: 20, children: [
          _PlanCard(
            title: 'Free',
            subtitle: 'Track workouts, meals, and progress.',
            icon: Icons.fitness_center_outlined,
            price: 'Free forever',
            selected: !_isPremium,
            onTap: () => setState(() => _isPremium = false),
          ),
          _PlanCard(
            title: 'Premium',
            subtitle: 'Everything in Free + personalised coaching plans from a certified coach.',
            icon: Icons.workspace_premium_rounded,
            price: '\$9.99 / month',
            selected: _isPremium,
            accent: true,
            onTap: () => setState(() => _isPremium = true),
          ),
        ]),
      ]);

  Widget _buildStep2() => Form(
        key: _statsKey,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _stepHeader('Your body stats', 'We need these to calculate your BMI and calorie needs.', Icons.monitor_weight_outlined),
          const SizedBox(height: 32),
          Wrap(spacing: 20, runSpacing: 20, children: [
            _field(
              ctrl: _ageCtrl,
              label: 'Age',
              icon: Icons.cake_outlined,
              keyboard: TextInputType.number,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your age';
                final n = int.tryParse(v.trim());
                if (n == null || n < 10 || n > 120) return 'Enter a valid age';
                return null;
              },
            ),
            _field(
              ctrl: _heightCtrl,
              label: 'Height (cm)',
              icon: Icons.height,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your height';
                final n = double.tryParse(v.trim());
                if (n == null || n < 50 || n > 280) return 'Enter a valid height';
                return null;
              },
            ),
            _field(
              ctrl: _weightCtrl,
              label: 'Weight (kg)',
              icon: Icons.monitor_weight_outlined,
              keyboard: const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Enter your weight';
                final n = double.tryParse(v.trim());
                if (n == null || n < 20 || n > 500) return 'Enter a valid weight';
                return null;
              },
            ),
            _dropdownSmall<String>(
              label: 'Sex',
              value: _sex,
              items: const [
                DropdownMenuItem(value: 'male', child: Text('Male')),
                DropdownMenuItem(value: 'female', child: Text('Female')),
              ],
              onChanged: (v) { if (v != null) setState(() => _sex = v); },
            ),
          ]),
          const SizedBox(height: 28),
          Text('Body fat % (optional)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
          const SizedBox(height: 4),
          Text('Select the range that best describes you.', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _bodyFatOptions.map((opt) {
              final selected = _selectedBodyFat == opt;
              return GestureDetector(
                onTap: () => setState(() {
                  _selectedBodyFat = selected ? null : opt;
                }),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: selected ? const Color(0xFF2E7D32) : Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: selected ? const Color(0xFF2E7D32) : Colors.grey[300]!,
                    ),
                  ),
                  child: Text(
                    opt,
                    style: TextStyle(
                      color: selected ? Colors.white : Colors.grey[800],
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ]),
      );

  Widget _buildStep3() {
    final cities = CountryCityData.citiesForCountry(_country);
    if (!cities.contains(_city)) _city = cities.isNotEmpty ? cities.first : '';

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _stepHeader('Goals & location', 'Tell us what you want to achieve and where you are.', Icons.flag_outlined),
      const SizedBox(height: 32),
      Wrap(spacing: 20, runSpacing: 20, children: [
        _dropdownSmall<String>(
          label: 'Fitness goal',
          value: _goal,
          items: const [
            DropdownMenuItem(value: 'lose_weight', child: Text('Lose weight')),
            DropdownMenuItem(value: 'maintain_weight', child: Text('Maintain weight')),
            DropdownMenuItem(value: 'gain_weight', child: Text('Gain muscle')),
          ],
          onChanged: (v) { if (v != null) setState(() => _goal = v); },
        ),
        _dropdownSmall<String>(
          label: 'Activity level',
          value: _activityLevel,
          items: const [
            DropdownMenuItem(value: 'sedentary', child: Text('Sedentary')),
            DropdownMenuItem(value: 'lightly_active', child: Text('Lightly active')),
            DropdownMenuItem(value: 'moderately_active', child: Text('Moderately active')),
            DropdownMenuItem(value: 'active', child: Text('Active')),
            DropdownMenuItem(value: 'very_active', child: Text('Very active')),
          ],
          onChanged: (v) { if (v != null) setState(() => _activityLevel = v); },
        ),
        _dropdownSmall<String>(
          label: 'Country',
          value: _country,
          items: CountryCityData.countries
              .map((c) => DropdownMenuItem(value: c, child: Text(c)))
              .toList(),
          onChanged: (v) {
            if (v == null) return;
            setState(() {
              _country = v;
              final c = CountryCityData.citiesForCountry(v);
              _city = c.isNotEmpty ? c.first : '';
            });
          },
        ),
        if (cities.isNotEmpty)
          _dropdownSmall<String>(
            label: 'City',
            value: _city,
            items: cities.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
            onChanged: (v) { if (v != null) setState(() => _city = v); },
          ),
      ]),
      const SizedBox(height: 28),
      Text('Workout preference', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey[800])),
      const SizedBox(height: 14),
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: [
          ('weightlifting', 'Weightlifting', Icons.fitness_center_rounded),
          ('cardio', 'Cardio', Icons.directions_run_rounded),
          ('both', 'Both', Icons.swap_horiz_rounded),
        ].map((t) {
          final selected = _workoutPref == t.$1;
          return GestureDetector(
            onTap: () => setState(() => _workoutPref = t.$1),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: selected ? const Color(0xFF2E7D32) : Colors.grey[100],
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: selected ? const Color(0xFF2E7D32) : Colors.grey[300]!),
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(t.$3, size: 18, color: selected ? Colors.white : Colors.grey[700]),
                const SizedBox(width: 8),
                Text(t.$2, style: TextStyle(
                  color: selected ? Colors.white : Colors.grey[800],
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 14,
                )),
              ]),
            ),
          );
        }).toList(),
      ),
    ]);
  }

  Widget _buildStep4() {
    final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
    final h = double.tryParse(_heightCtrl.text.trim()) ?? 0;
    final w = double.tryParse(_weightCtrl.text.trim()) ?? 0;
    _bmi = _calcBmi(h, w);
    _tdee = _calcTdee(_sex, age, h, w, _activityLevel);

    final target = _targetCalories(_chosenRate);
    final bool isFast = _chosenRate.abs() > 1.0;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _stepHeader('Rate of change', 'Choose how fast you want to reach your goal.', Icons.speed_rounded),
      const SizedBox(height: 24),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFFE8F5E9),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFA5D6A7)),
        ),
        child: Row(children: [
          const Icon(Icons.auto_awesome_rounded, color: Color(0xFF2E7D32)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('System suggestion', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              Text(
                'Based on your goal, we suggest ${_suggestedRate == 0 ? 'maintaining your weight' : '${_suggestedRate > 0 ? '+' : ''}${_suggestedRate.toStringAsFixed(1)} kg/week'}.',
                style: TextStyle(fontSize: 13, color: Colors.grey[700]),
              ),
            ]),
          ),
          TextButton(
            onPressed: () => setState(() => _chosenRate = _suggestedRate),
            child: const Text('Reset', style: TextStyle(color: Color(0xFF2E7D32))),
          ),
        ]),
      ),
      const SizedBox(height: 28),
      Text(
        '${_chosenRate > 0 ? '+' : ''}${_chosenRate.toStringAsFixed(2)} kg / week',
        style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
      ),
      const SizedBox(height: 4),
      Text(
        _chosenRate < -0.05
            ? 'Weight loss mode'
            : _chosenRate > 0.05
                ? 'Weight gain mode'
                : 'Maintenance mode',
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
      const SizedBox(height: 12),
      SliderTheme(
        data: SliderThemeData(
          activeTrackColor: const Color(0xFF2E7D32),
          thumbColor: const Color(0xFF2E7D32),
          overlayColor: const Color(0xFF2E7D32).withValues(alpha: 0.15),
          inactiveTrackColor: Colors.grey[300],
          trackHeight: 5,
        ),
        child: Slider(
          value: _chosenRate,
          min: -1.5,
          max: 1.5,
          divisions: 30,
          onChanged: (v) => setState(() => _chosenRate = v),
        ),
      ),
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text('−1.5 kg/wk', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
        Text('+1.5 kg/wk', style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ]),
      const SizedBox(height: 24),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
          _rateMetric('Daily calories', '${target.toStringAsFixed(0)} kcal', Colors.orange),
          _rateMetric('TDEE', '${_tdee.toStringAsFixed(0)} kcal', Colors.grey),
          _rateMetric('Daily delta', '${(_chosenRate * 7700 / 7) >= 0 ? '+' : ''}${(_chosenRate * 7700 / 7).toStringAsFixed(0)} kcal', const Color(0xFF2E7D32)),
        ]),
      ),
      if (isFast) ...[
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: Colors.orange[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange[300]!),
          ),
          child: Row(children: [
            Icon(Icons.warning_amber_rounded, color: Colors.orange[700]),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Rates above ±1.0 kg/week may be hard to sustain and can affect muscle mass. Consider a more moderate pace.',
                style: TextStyle(color: Colors.orange[900], fontSize: 13, height: 1.4),
              ),
            ),
          ]),
        ),
      ],
    ]);
  }

  Widget _rateMetric(String label, String value, Color color) => Column(children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
        const SizedBox(height: 3),
        Text(label, style: TextStyle(fontSize: 11, color: Colors.grey[600])),
      ]);

  Widget _buildStep5() {
    final age = int.tryParse(_ageCtrl.text.trim()) ?? 0;
    final h = double.tryParse(_heightCtrl.text.trim()) ?? 0;
    final w = double.tryParse(_weightCtrl.text.trim()) ?? 0;
    _bmi = _calcBmi(h, w);
    _tdee = _calcTdee(_sex, age, h, w, _activityLevel);
    final target = _targetCalories(_chosenRate);

    final bmiCategory = _bmi < 18.5
        ? 'Underweight'
        : _bmi < 25
            ? 'Normal weight'
            : _bmi < 30
                ? 'Overweight'
                : 'Obese';

    final goalLabel = switch (_goal) {
      'lose_weight' => 'Lose weight',
      'maintain_weight' => 'Maintain weight',
      'gain_weight' => 'Gain muscle',
      _ => _goal,
    };
    final actLabel = switch (_activityLevel) {
      'sedentary' => 'Sedentary',
      'lightly_active' => 'Lightly active',
      'moderately_active' => 'Moderately active',
      'active' => 'Active',
      'very_active' => 'Very active',
      _ => _activityLevel,
    };
    final prefLabel = switch (_workoutPref) {
      'weightlifting' => 'Weightlifting',
      'cardio' => 'Cardio',
      'both' => 'Weightlifting & Cardio',
      _ => _workoutPref,
    };

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _stepHeader('Your profile summary', 'Everything looks good — review and create your account.', Icons.checklist_rounded),
      const SizedBox(height: 24),
      Wrap(spacing: 16, runSpacing: 16, children: [
        _summaryMetric('BMI', '${_bmi.toStringAsFixed(1)} — $bmiCategory', Icons.speed_rounded, Colors.blue),
        _summaryMetric('TDEE', '${_tdee.toStringAsFixed(0)} kcal/day', Icons.local_fire_department_outlined, Colors.orange),
        _summaryMetric('Target calories', '${target.toStringAsFixed(0)} kcal/day', Icons.restaurant_menu_outlined, const Color(0xFF2E7D32)),
        _summaryMetric('Rate of change', '${_chosenRate >= 0 ? '+' : ''}${_chosenRate.toStringAsFixed(2)} kg/week', Icons.trending_up_rounded, Colors.purple),
      ]),
      const SizedBox(height: 24),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Wrap(spacing: 32, runSpacing: 12, children: [
          _summaryDetail('Name', _nameCtrl.text.trim()),
          _summaryDetail('Username', '@${_usernameCtrl.text.trim()}'),
          _summaryDetail('Email', _emailCtrl.text.trim()),
          _summaryDetail('Plan', _isPremium ? 'Premium' : 'Free'),
          _summaryDetail('Age', '${_ageCtrl.text.trim()} years'),
          _summaryDetail('Sex', _sex[0].toUpperCase() + _sex.substring(1)),
          _summaryDetail('Height', '${_heightCtrl.text.trim()} cm'),
          _summaryDetail('Weight', '${_weightCtrl.text.trim()} kg'),
          if (_selectedBodyFat != null && _selectedBodyFat != 'Prefer not to say')
            _summaryDetail('Body fat', _selectedBodyFat!),
          _summaryDetail('Goal', goalLabel),
          _summaryDetail('Activity', actLabel),
          _summaryDetail('Workout pref', prefLabel),
          _summaryDetail('Location', '$_city, $_country'),
        ]),
      ),
    ]);
  }

  Widget _summaryMetric(String label, String value, IconData icon, Color color) =>
      Container(
        width: 220,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Row(children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
              Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
            ]),
          ),
        ]),
      );

  Widget _summaryDetail(String label, String value) => SizedBox(
        width: 180,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[500], fontWeight: FontWeight.w500)),
          const SizedBox(height: 2),
          Text(value, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
        ]),
      );

  Widget _stepHeader(String title, String subtitle, IconData icon) => Row(children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: const Color(0xFFE8F5E9), borderRadius: BorderRadius.circular(12)),
          child: Icon(icon, color: const Color(0xFF2E7D32), size: 28),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.3)),
            Text(subtitle, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
          ]),
        ),
      ]);

  @override
  Widget build(BuildContext context) {
    const steps = ['Account', 'Plan', 'Body', 'Goals', 'Rate', 'Summary'];

    Widget stepContent;
    switch (_currentStep) {
      case 0: stepContent = _buildStep0(); break;
      case 1: stepContent = _buildStep1(); break;
      case 2: stepContent = _buildStep2(); break;
      case 3: stepContent = _buildStep3(); break;
      case 4: stepContent = _buildStep4(); break;
      default: stepContent = _buildStep5();
    }

    final isLast = _currentStep == 5;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
        title: Row(children: [
          const Icon(Icons.fitness_center_rounded, color: Color(0xFF2E7D32), size: 22),
          const SizedBox(width: 8),
          const Text('GetFit', style: TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF2E7D32))),
          const SizedBox(width: 4),
          Text('— Registration', style: TextStyle(color: Colors.grey[600], fontWeight: FontWeight.w400)),
        ]),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 12))],
              ),
              padding: const EdgeInsets.all(40),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                SizedBox(
                  height: 52,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    shrinkWrap: true,
                    itemCount: steps.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 4),
                    itemBuilder: (_, i) {
                      final done = i < _currentStep;
                      final active = i == _currentStep;
                      return _StepDot(label: steps[i], index: i + 1, done: done, active: active);
                    },
                  ),
                ),
                const SizedBox(height: 36),

                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  child: KeyedSubtree(key: ValueKey(_currentStep), child: stepContent),
                ),

                const SizedBox(height: 40),

                Row(children: [
                  if (_currentStep > 0)
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: Colors.grey[400]!),
                        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _back,
                      icon: const Icon(Icons.arrow_back_rounded, color: Color(0xFF2E7D32)),
                      label: const Text('Back', style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w600)),
                    ),
                  const Spacer(),
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 28),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: _isSubmitting ? null : (isLast ? _submit : _next),
                    icon: _isSubmitting
                        ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                        : Icon(isLast ? Icons.check_circle_outline : Icons.arrow_forward_rounded),
                    label: Text(
                      _isSubmitting ? 'Creating…' : (isLast ? 'Create My Account' : 'Continue'),
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ]),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
class _StepDot extends StatelessWidget {
  const _StepDot({required this.label, required this.index, required this.done, required this.active});
  final String label;
  final int index;
  final bool done;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final Color bg = done
        ? const Color(0xFF2E7D32)
        : active
            ? const Color(0xFFE8F5E9)
            : Colors.grey[200]!;
    final Color border = (done || active) ? const Color(0xFF2E7D32) : Colors.grey[300]!;
    final Color textColor = done
        ? Colors.white
        : active
            ? const Color(0xFF2E7D32)
            : Colors.grey[500]!;

    return Row(mainAxisSize: MainAxisSize.min, children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: border, width: 2),
        ),
        child: Center(
          child: done
              ? const Icon(Icons.check, color: Colors.white, size: 16)
              : Text('$index', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor)),
        ),
      ),
      const SizedBox(width: 4),
      Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: active ? FontWeight.w700 : FontWeight.w500,
          color: active ? const Color(0xFF2E7D32) : Colors.grey[600],
        ),
      ),
    ]);
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.price,
    required this.selected,
    required this.onTap,
    this.accent = false,
  });
  final String title, subtitle, price;
  final IconData icon;
  final bool selected, accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final borderColor = selected ? const Color(0xFF2E7D32) : Colors.grey[300]!;
    final bg = selected ? const Color(0xFFE8F5E9) : Colors.grey[50]!;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 280,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderColor, width: selected ? 2.5 : 1.5),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: selected ? const Color(0xFF2E7D32) : Colors.grey[600], size: 28),
            const Spacer(),
            if (selected)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: Color(0xFF2E7D32), shape: BoxShape.circle),
                child: const Icon(Icons.check, color: Colors.white, size: 14),
              ),
          ]),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[600], height: 1.4)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF2E7D32) : Colors.grey[200],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(price, style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: selected ? Colors.white : Colors.grey[700])),
          ),
        ]),
      ),
    );
  }
}