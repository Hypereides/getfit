import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_dropdown_field.dart';
import '../data/workout_catalog.dart';
import '../domain/workout_entry.dart';
import '../domain/workout_session.dart';
import '../state/workout_controller.dart';

class MyPlanScreen extends StatefulWidget {
  const MyPlanScreen({super.key});

  @override
  State<MyPlanScreen> createState() => _MyPlanScreenState();
}

class _MyPlanScreenState extends State<MyPlanScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _setsController = TextEditingController();
  final TextEditingController _repsController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  String? _selectedCategory;
  String? _selectedExercise;
  String? _selectedIntensity = 'Moderate';

  final List<WorkoutEntry> _draftEntries = [];
  bool _showSummary = false;

  @override
  void dispose() {
    _setsController.dispose();
    _repsController.dispose();
    _weightController.dispose();
    _durationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  List<String> get _exerciseList {
    if (_selectedCategory == null) return [];
    return WorkoutCatalog.byCategory(_selectedCategory!);
  }

  void _resetCurrentEntryFields() {
    _selectedExercise = null;
    _selectedIntensity = 'Moderate';
    _setsController.clear();
    _repsController.clear();
    _weightController.clear();
    _durationController.clear();
    _notesController.clear();
  }

  double _calculateEstimatedCaloriesForCurrentEntry() {
    if (_selectedCategory == 'Strength') {
      final sets = int.tryParse(_setsController.text.trim()) ?? 0;
      final reps = int.tryParse(_repsController.text.trim()) ?? 0;
      final weight = double.tryParse(_weightController.text.trim()) ?? 0;
      return (sets * reps * 0.45) + (weight * 0.12);
    }

    final duration = int.tryParse(_durationController.text.trim()) ?? 0;
    final factor = switch (_selectedIntensity) {
      'Light' => 4.5,
      'Moderate' => 6.5,
      'High' => 8.5,
      _ => 6.5,
    };
    return duration * factor;
  }

  void _addEntryToWorkout() {
    if (_selectedCategory == null || _selectedExercise == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select category and exercise first.')),
      );
      return;
    }

    if (!_formKey.currentState!.validate()) return;

    final entry = WorkoutEntry(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      category: _selectedCategory!,
      exercise: _selectedExercise!,
      sets: _selectedCategory == 'Strength'
          ? int.tryParse(_setsController.text.trim())
          : null,
      reps: _selectedCategory == 'Strength'
          ? int.tryParse(_repsController.text.trim())
          : null,
      weightKg: _selectedCategory == 'Strength'
          ? double.tryParse(_weightController.text.trim())
          : null,
      durationMinutes: _selectedCategory == 'Cardio'
          ? int.tryParse(_durationController.text.trim())
          : null,
      intensity: _selectedCategory == 'Cardio' ? _selectedIntensity : null,
      notes: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      estimatedCalories: _calculateEstimatedCaloriesForCurrentEntry(),
    );

    setState(() {
      _draftEntries.add(entry);
      _showSummary = false;
      _resetCurrentEntryFields();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity added to workout.')),
    );
  }

  void _removeDraftEntry(WorkoutEntry entry) {
    setState(() {
      _draftEntries.remove(entry);
      _showSummary = false;
    });
  }

  void _prepareSummary() {
    if (_draftEntries.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one activity first.')),
      );
      return;
    }

    setState(() {
      _showSummary = true;
    });
  }

  void _confirmWorkout() {
    final session = WorkoutSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      createdAt: DateTime.now(),
      entries: List.unmodifiable(_draftEntries),
    );

    context.read<WorkoutController>().addSession(session);

    setState(() {
      _draftEntries.clear();
      _showSummary = false;
      _selectedCategory = null;
      _resetCurrentEntryFields();
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Workout saved and progress updated successfully.'),
      ),
    );
  }

  double get _draftTotalCalories {
    return _draftEntries.fold(0, (sum, item) => sum + item.estimatedCalories);
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
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

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      width: 260,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: _inputDecoration(label, icon),
        validator: validator,
      ),
    );
  }

  Widget _buildInfoStat({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Container(
      width: 220,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F5E9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: const Color(0xFF2E7D32)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDraftEntryCard(WorkoutEntry entry) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.exercise} • ${entry.category}',
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  entry.isStrength
                      ? 'Sets: ${entry.sets ?? '-'} • Reps: ${entry.reps ?? '-'} • Weight: ${entry.weightKg == null ? '-' : '${entry.weightKg} kg'}'
                      : 'Duration: ${entry.durationMinutes ?? '-'} min • Intensity: ${entry.intensity ?? '-'}',
                  style: TextStyle(color: Colors.grey[700]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Estimated burn: ${entry.estimatedCalories.toStringAsFixed(0)} kcal',
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeDraftEntry(entry),
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.redAccent,
            tooltip: 'Remove activity',
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 180,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWorkoutSummaryCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBF8),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFCFE8D1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Workout Summary',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 18),
          _summaryRow('Activities added', _draftEntries.length.toString()),
          _summaryRow(
            'Estimated total energy burn',
            '${_draftTotalCalories.toStringAsFixed(0)} kcal',
          ),
          const SizedBox(height: 12),
          ..._draftEntries.map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                '- ${entry.exercise} (${entry.category}) • ${entry.estimatedCalories.toStringAsFixed(0)} kcal',
                style: TextStyle(color: Colors.grey[700], height: 1.4),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF2E7D32),
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              onPressed: _confirmWorkout,
              icon: const Icon(Icons.check_circle_outline),
              label: const Text(
                'Confirm and Save Workout',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSavedSessionCard(WorkoutSession session) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Workout with ${session.totalActivities} activities',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Estimated burn: ${session.totalEstimatedCalories.toStringAsFixed(0)} kcal',
            style: const TextStyle(
              color: Color(0xFF2E7D32),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 12),
          ...session.entries.take(3).map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(
                '• ${entry.exercise} (${entry.category})',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final workoutController = context.watch<WorkoutController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
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
                    Icons.assignment_outlined,
                    color: Color(0xFF2E7D32),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'My Plan',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'Track a full workout session by adding as many strength exercises and cardio activities as you want before confirming the final workout.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),

            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildInfoStat(
                  title: 'Saved workouts',
                  value: workoutController.totalSessions.toString(),
                  icon: Icons.library_add_check_rounded,
                ),
                _buildInfoStat(
                  title: 'Tracked activities',
                  value: workoutController.totalActivities.toString(),
                  icon: Icons.fitness_center_rounded,
                ),
                _buildInfoStat(
                  title: 'Estimated calories',
                  value: '${workoutController.totalCaloriesBurned.toStringAsFixed(0)} kcal',
                  icon: Icons.local_fire_department_outlined,
                ),
              ],
            ),

            const SizedBox(height: 40),
            const Text(
              '1. Select Category',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 18),
            AppDropdownField<String>(
              label: 'Training category',
              value: _selectedCategory,
              width: 320,
              items: WorkoutCatalog.categories
                  .map(
                    (category) => DropdownMenuItem<String>(
                      value: category,
                      child: Text(category),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                  _selectedExercise = null;
                  _selectedIntensity = 'Moderate';
                  _showSummary = false;
                  _setsController.clear();
                  _repsController.clear();
                  _weightController.clear();
                  _durationController.clear();
                  _notesController.clear();
                });
              },
            ),

            if (_selectedCategory != null) ...[
              const SizedBox(height: 40),
              const Text(
                '2. Select Exercise or Activity',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              AppDropdownField<String>(
                label: 'Exercise / Activity',
                value: _selectedExercise,
                width: 320,
                items: _exerciseList
                    .map(
                      (exercise) => DropdownMenuItem<String>(
                        value: exercise,
                        child: Text(exercise),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedExercise = value;
                    _showSummary = false;
                  });
                },
              ),
            ],

            if (_selectedExercise != null) ...[
              const SizedBox(height: 40),
              const Text(
                '3. Enter Activity Details',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_selectedCategory == 'Strength')
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _buildFormField(
                            controller: _setsController,
                            label: 'Sets',
                            icon: Icons.format_list_numbered_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter sets';
                              }
                              return null;
                            },
                          ),
                          _buildFormField(
                            controller: _repsController,
                            label: 'Repetitions',
                            icon: Icons.repeat_rounded,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter repetitions';
                              }
                              return null;
                            },
                          ),
                          _buildFormField(
                            controller: _weightController,
                            label: 'Weight (kg)',
                            icon: Icons.monitor_weight_outlined,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          ),
                        ],
                      ),
                    if (_selectedCategory == 'Cardio')
                      Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          _buildFormField(
                            controller: _durationController,
                            label: 'Duration (minutes)',
                            icon: Icons.timer_outlined,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Enter duration';
                              }
                              return null;
                            },
                          ),
                          AppDropdownField<String>(
                            label: 'Intensity',
                            value: _selectedIntensity,
                            width: 260,
                            items: const [
                              DropdownMenuItem(
                                value: 'Light',
                                child: Text('Light'),
                              ),
                              DropdownMenuItem(
                                value: 'Moderate',
                                child: Text('Moderate'),
                              ),
                              DropdownMenuItem(
                                value: 'High',
                                child: Text('High'),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedIntensity = value ?? 'Moderate';
                                _showSummary = false;
                              });
                            },
                          ),
                        ],
                      ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _notesController,
                      maxLines: 3,
                      decoration: _inputDecoration(
                        'Optional notes',
                        Icons.notes_rounded,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2E7D32),
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 22,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      onPressed: _addEntryToWorkout,
                      icon: const Icon(Icons.add_rounded),
                      label: const Text(
                        'Add to Workout',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            if (_draftEntries.isNotEmpty) ...[
              const SizedBox(height: 40),
              const Text(
                'Current Workout Draft',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Column(
                children: _draftEntries
                    .map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildDraftEntryCard(entry),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),
              Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Color(0xFF2E7D32)),
                    padding: const EdgeInsets.symmetric(
                      vertical: 16,
                      horizontal: 22,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _prepareSummary,
                  icon: const Icon(
                    Icons.summarize_outlined,
                    color: Color(0xFF2E7D32),
                  ),
                  label: const Text(
                    'Review Summary',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2E7D32),
                    ),
                  ),
                ),
              ),
            ],

            if (_showSummary) ...[
              const SizedBox(height: 40),
              _buildWorkoutSummaryCard(),
            ],

            if (workoutController.sessions.isNotEmpty) ...[
              const SizedBox(height: 48),
              const Text(
                'Recent Saved Workouts',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 18),
              Column(
                children: workoutController.sessions
                    .take(3)
                    .map(
                      (session) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _buildSavedSessionCard(session),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}