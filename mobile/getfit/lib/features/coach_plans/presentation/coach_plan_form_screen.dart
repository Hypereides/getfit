import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/domain/app_user.dart';
import '../state/coach_plan_controller.dart';

class CoachPlanFormScreen extends StatefulWidget {
  const CoachPlanFormScreen({
    super.key,
    required this.client,
    required this.isUpdate,
  });

  final AppUser client;
  final bool isUpdate;

  @override
  State<CoachPlanFormScreen> createState() => _CoachPlanFormScreenState();
}

class _CoachPlanFormScreenState extends State<CoachPlanFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _weeklyWorkoutsController = TextEditingController();
  final TextEditingController _cardioDaysController = TextEditingController();
  final TextEditingController _durationWeeksController = TextEditingController();
  final TextEditingController _nutritionNotesController = TextEditingController();

  bool _showConfirmation = false;

  @override
  void initState() {
    super.initState();

    if (widget.isUpdate) {
      _titleController.text = 'Updated ${widget.client.profile.goal} Plan';
      _descriptionController.text =
          'Improved plan for ${widget.client.profile.name} based on current progress.';
      _weeklyWorkoutsController.text = '4';
      _cardioDaysController.text = '2';
      _durationWeeksController.text = '8';
      _nutritionNotesController.text = 'Increase protein intake and maintain hydration.';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _weeklyWorkoutsController.dispose();
    _cardioDaysController.dispose();
    _durationWeeksController.dispose();
    _nutritionNotesController.dispose();
    super.dispose();
  }

  InputDecoration _decoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.grey[600]),
      filled: true,
      fillColor: Colors.grey[50],
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

  void _reviewPlan() {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _showConfirmation = true;
    });
  }

  void _confirmPlan() {
    context.read<CoachPlanController>().createOrUpdatePlan(
          client: widget.client,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          weeklyWorkouts: int.parse(_weeklyWorkoutsController.text.trim()),
          cardioDays: int.parse(_cardioDaysController.text.trim()),
          durationWeeks: int.parse(_durationWeeksController.text.trim()),
          nutritionNotes: _nutritionNotesController.text.trim(),
          isUpdate: widget.isUpdate,
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.isUpdate
              ? 'Plan updated and user notified successfully.'
              : 'Plan created and user notified successfully.',
        ),
      ),
    );

    Navigator.of(context).popUntil((route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.isUpdate ? 'Update Plan' : 'Create Plan';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$title for ${widget.client.profile.name}',
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: _decoration('Plan title', Icons.assignment_outlined),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Enter plan title' : null,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _descriptionController,
                      maxLines: 4,
                      decoration: _decoration('Plan description', Icons.notes_rounded),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Enter plan description' : null,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _weeklyWorkoutsController,
                      keyboardType: TextInputType.number,
                      decoration:
                          _decoration('Weekly workouts', Icons.calendar_today_outlined),
                      validator: (value) => value == null || value.trim().isEmpty
                          ? 'Enter weekly workouts'
                          : null,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _cardioDaysController,
                      keyboardType: TextInputType.number,
                      decoration: _decoration(
                        'Cardio days per week',
                        Icons.favorite_border,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Enter cardio days' : null,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _durationWeeksController,
                      keyboardType: TextInputType.number,
                      decoration: _decoration(
                        'Duration in weeks',
                        Icons.schedule_outlined,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty ? 'Enter duration' : null,
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _nutritionNotesController,
                      maxLines: 3,
                      decoration: _decoration(
                        'Nutrition notes',
                        Icons.restaurant_menu_outlined,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Align(
                      alignment: Alignment.centerRight,
                      child: FilledButton.icon(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF2E7D32),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 16,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: _reviewPlan,
                        icon: const Icon(Icons.checklist_rounded),
                        label: const Text('Review and Confirm'),
                      ),
                    ),
                  ],
                ),
              ),
              if (_showConfirmation) ...[
                const SizedBox(height: 32),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FBF8),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: const Color(0xFFCFE8D1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plan Confirmation',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text('Client: ${widget.client.profile.name}'),
                      Text('Title: ${_titleController.text.trim()}'),
                      Text('Weekly workouts: ${_weeklyWorkoutsController.text.trim()}'),
                      Text('Cardio days: ${_cardioDaysController.text.trim()}'),
                      Text('Duration: ${_durationWeeksController.text.trim()} weeks'),
                      const SizedBox(height: 10),
                      Text('Description: ${_descriptionController.text.trim()}'),
                      const SizedBox(height: 10),
                      Text(
                        'Nutrition notes: ${_nutritionNotesController.text.trim().isEmpty ? '-' : _nutritionNotesController.text.trim()}',
                      ),
                      const SizedBox(height: 24),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FilledButton.icon(
                          style: FilledButton.styleFrom(
                            backgroundColor: const Color(0xFF2E7D32),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 22,
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: _confirmPlan,
                          icon: const Icon(Icons.save_outlined),
                          label: Text(
                            widget.isUpdate ? 'Confirm Update' : 'Confirm Create',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}