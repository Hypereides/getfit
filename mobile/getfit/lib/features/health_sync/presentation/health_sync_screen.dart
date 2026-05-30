import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/session_controller.dart';
import '../../workouts/state/workout_controller.dart';
import '../domain/activity_goal.dart';
import '../state/google_fit_connector.dart';

class HealthSyncScreen extends StatefulWidget {
  const HealthSyncScreen({super.key});

  @override
  State<HealthSyncScreen> createState() => _HealthSyncScreenState();
}

class _HealthSyncScreenState extends State<HealthSyncScreen> {
  final _stepsCtrl       = TextEditingController();
  final _activeMinCtrl   = TextEditingController();
  final _caloriesCtrl    = TextEditingController();
  final _workoutsCtrl    = TextEditingController();
  final _goalFormKey     = GlobalKey<FormState>();

  bool _showGoalForm = false;

  @override
  void dispose() {
    _stepsCtrl.dispose();
    _activeMinCtrl.dispose();
    _caloriesCtrl.dispose();
    _workoutsCtrl.dispose();
    super.dispose();
  }

  void _populateGoalForm(ActivityGoal goal) {
    _stepsCtrl.text     = goal.targetSteps.toString();
    _activeMinCtrl.text = goal.targetActiveMinutes.toString();
    _caloriesCtrl.text  = goal.targetCaloriesBurned.toStringAsFixed(0);
    _workoutsCtrl.text  = goal.targetWorkouts.toString();
  }

  void _requestActivityPlan(GoogleFitConnector ctrl, dynamic profile) {
    final suggestion = ctrl.requestActivityPlan(profile);
    _populateGoalForm(suggestion);
    setState(() => _showGoalForm = true);
  }

  void _confirmActivityPlan(GoogleFitConnector ctrl) {
    if (!_goalFormKey.currentState!.validate()) return;

    final goal = ActivityGoal(
      targetSteps:          int.parse(_stepsCtrl.text.trim()),
      targetActiveMinutes:  int.parse(_activeMinCtrl.text.trim()),
      targetCaloriesBurned: double.parse(_caloriesCtrl.text.trim()),
      targetWorkouts:       int.parse(_workoutsCtrl.text.trim()),
      createdAt:            DateTime.now(),
      isSystemSuggested:    false,
    );

    ctrl.saveActivityPlan(goal);
    setState(() => _showGoalForm = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF2E7D32),
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Weekly goal saved!',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ctrl    = context.watch<GoogleFitConnector>();
    final session = context.watch<SessionController>();
    final workouts = context.watch<WorkoutController>();
    final profile = session.currentUser?.profile;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Google Fit & Weekly Goal'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          if (ctrl.isConnected)
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              tooltip: 'Refresh data',
              onPressed: ctrl.refresh,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _GoogleFitAuthScreen(ctrl: ctrl),
            const SizedBox(height: 24),
            if (ctrl.isConnected && ctrl.snapshot != null) ...[
              _HealthDataSection(snapshot: ctrl.snapshot!),
              const SizedBox(height: 24),
            ],
            if (ctrl.isConnected && ctrl.snapshot != null) ...[
              _DailyProgressCard(
                snapshot: ctrl.snapshot!,
                workoutSessions: workouts.totalSessions,
              ),
              const SizedBox(height: 24),
            ],
            if (ctrl.weeklyGoal != null) ...[
              _SavedGoalCard(
                goal: ctrl.weeklyGoal!,
                workouts: workouts,
                snapshot: ctrl.snapshot,
                onEdit: () {
                  _populateGoalForm(ctrl.weeklyGoal!);
                  setState(() => _showGoalForm = true);
                },
                onClear: ctrl.clearGoal,
              ),
              const SizedBox(height: 24),
            ],
            if (ctrl.isConnected && !_showGoalForm && ctrl.weeklyGoal == null) ...[
              _CreatePlanButton(
                onTap: profile != null
                    ? () => _requestActivityPlan(ctrl, profile)
                    : null,
              ),
              const SizedBox(height: 24),
            ],
            if (_showGoalForm) ...[
              _ActivityPlanScreen(
                formKey: _goalFormKey,
                stepsCtrl: _stepsCtrl,
                activeMinCtrl: _activeMinCtrl,
                caloriesCtrl: _caloriesCtrl,
                workoutsCtrl: _workoutsCtrl,
                isSystemSuggested: ctrl.suggestedGoal?.isSystemSuggested ?? false,
                onConfirm: () => _confirmActivityPlan(ctrl),
                onCancel: () => setState(() => _showGoalForm = false),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GoogleFitAuthScreen extends StatelessWidget {
  const _GoogleFitAuthScreen({required this.ctrl});
  final GoogleFitConnector ctrl;

  @override
  Widget build(BuildContext context) {
    final status = ctrl.status;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF1565C0), Color(0xFF42A5F5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1565C0).withValues(alpha: 0.28),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.monitor_heart_rounded,
                    color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Google Fit',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Sync steps, activity and calories',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              _StatusBadge(status: status),
            ],
          ),

          if (status == FitConnectionStatus.permissionDenied) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.red),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Permission denied. Please enable health access in device settings.',
                      style: TextStyle(color: Colors.red, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (ctrl.snapshot?.isMockData == true) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, color: Colors.white70, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Demo data — no Health Connect on this device',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),

          if (status != FitConnectionStatus.connected)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF1565C0),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                onPressed: status == FitConnectionStatus.connecting
                    ? null
                    : ctrl.requestConnection,
                icon: status == FitConnectionStatus.connecting
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.link_rounded),
                label: Text(
                  status == FitConnectionStatus.connecting
                      ? 'Connecting…'
                      : 'Connect to Google Fit',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ),
            )
          else
            Row(
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  'Connected · last synced ${_timeAgo(ctrl.snapshot!.fetchedAt)}',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ],
            ),
        ],
      ),
    );
  }

  static String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    return '${diff.inHours}h ago';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final FitConnectionStatus status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      FitConnectionStatus.connected      => ('Connected', Colors.greenAccent),
      FitConnectionStatus.connecting     => ('Connecting', Colors.amber),
      FitConnectionStatus.permissionDenied => ('Denied', Colors.red[200]!),
      FitConnectionStatus.error          => ('Error', Colors.red[200]!),
      FitConnectionStatus.disconnected   => ('Not connected', Colors.white38),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.7)),
      ),
      child: Text(
        label,
        style: TextStyle(
            color: color, fontSize: 11, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class _HealthDataSection extends StatelessWidget {
  const _HealthDataSection({required this.snapshot});
  final dynamic snapshot; // HealthSnapshot

  @override
  Widget build(BuildContext context) {
    return _Card(
      title: "Today's Activity",
      subtitle: 'Data from Google Fit / HealthKit',
      icon: Icons.directions_run_rounded,
      child: Wrap(
        spacing: 16,
        runSpacing: 16,
        children: [
          _MetricTile(
            icon: Icons.directions_walk_rounded,
            label: 'Steps',
            value: _fmt(snapshot.steps),
            color: const Color(0xFF1565C0),
          ),
          _MetricTile(
            icon: Icons.timer_outlined,
            label: 'Active minutes',
            value: '${snapshot.activeMinutes} min',
            color: Colors.purple,
          ),
          _MetricTile(
            icon: Icons.local_fire_department_rounded,
            label: 'Calories burned',
            value: '${snapshot.caloriesBurned.toStringAsFixed(0)} kcal',
            color: Colors.orange,
          ),
          if (snapshot.heartRateAvg != null)
            _MetricTile(
              icon: Icons.favorite_rounded,
              label: 'Avg heart rate',
              value: '${snapshot.heartRateAvg!.toStringAsFixed(0)} bpm',
              color: Colors.red,
            ),
          if (snapshot.distanceKm != null)
            _MetricTile(
              icon: Icons.route_rounded,
              label: 'Distance',
              value: '${snapshot.distanceKm!.toStringAsFixed(2)} km',
              color: Colors.teal,
            ),
        ],
      ),
    );
  }

  static String _fmt(int n) {
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }
}

class _DailyProgressCard extends StatelessWidget {
  const _DailyProgressCard(
      {required this.snapshot,
      required this.workoutSessions});

  final dynamic snapshot;
  final int workoutSessions;

  @override
  Widget build(BuildContext context) {
    final stepGoal = 10000;
    final stepPct = (snapshot.steps / stepGoal).clamp(0.0, 1.0);

    return _Card(
      title: 'Daily Progress Updated',
      subtitle: 'Your progress has been refreshed with synced data',
      icon: Icons.trending_up_rounded,
      accentColor: const Color(0xFF2E7D32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${snapshot.steps} / $stepGoal steps',
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14),
              ),
              Text(
                '${(stepPct * 100).toStringAsFixed(0)} %',
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stepPct,
              minHeight: 10,
              backgroundColor: Colors.grey[200],
              valueColor: const AlwaysStoppedAnimation(Color(0xFF2E7D32)),
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 24,
            children: [
              _ProgressStat(
                label: 'Calories burned',
                value:
                    '${snapshot.caloriesBurned.toStringAsFixed(0)} kcal',
              ),
              _ProgressStat(
                label: 'Workouts logged',
                value: workoutSessions.toString(),
              ),
              _ProgressStat(
                label: 'Active time',
                value: '${snapshot.activeMinutes} min',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProgressStat extends StatelessWidget {
  const _ProgressStat({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        Text(value,
            style: const TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _CreatePlanButton extends StatelessWidget {
  const _CreatePlanButton({required this.onTap});
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF2E7D32),
          padding: const EdgeInsets.symmetric(vertical: 20),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: onTap,
        icon: const Icon(Icons.calendar_month_rounded, size: 22),
        label: const Text(
          'Create Weekly Plan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _ActivityPlanScreen extends StatelessWidget {
  const _ActivityPlanScreen({
    required this.formKey,
    required this.stepsCtrl,
    required this.activeMinCtrl,
    required this.caloriesCtrl,
    required this.workoutsCtrl,
    required this.isSystemSuggested,
    required this.onConfirm,
    required this.onCancel,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController stepsCtrl;
  final TextEditingController activeMinCtrl;
  final TextEditingController caloriesCtrl;
  final TextEditingController workoutsCtrl;
  final bool isSystemSuggested;
  final VoidCallback onConfirm;
  final VoidCallback onCancel;

  InputDecoration _dec(String label, IconData icon, String suffix) =>
      InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        suffixText: suffix,
        filled: true,
        fillColor: Colors.grey[50],
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        border:
            OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
      );

  String? _required(String? v, {double min = 1}) {
    if (v == null || v.trim().isEmpty) return 'Required';
    final n = double.tryParse(v.trim());
    if (n == null) return 'Enter a valid number';
    if (n < min) return 'Must be at least $min';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFA5D6A7)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.auto_awesome_rounded,
                      color: Color(0xFF2E7D32), size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Weekly Goal',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        isSystemSuggested
                            ? 'System suggestion based on your profile — adjust freely'
                            : 'Edit your current goal',
                        style: TextStyle(
                            fontSize: 13, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _goalField(
                  ctrl: stepsCtrl,
                  label: 'Target steps / week',
                  icon: Icons.directions_walk_rounded,
                  suffix: 'steps',
                  dec: _dec,
                  validator: (v) => _required(v, min: 1000),
                ),
                _goalField(
                  ctrl: activeMinCtrl,
                  label: 'Active minutes / week',
                  icon: Icons.timer_rounded,
                  suffix: 'min',
                  dec: _dec,
                  validator: (v) => _required(v, min: 10),
                ),
                _goalField(
                  ctrl: caloriesCtrl,
                  label: 'Calorie burn / week',
                  icon: Icons.local_fire_department_rounded,
                  suffix: 'kcal',
                  dec: _dec,
                  validator: (v) => _required(v, min: 50),
                ),
                _goalField(
                  ctrl: workoutsCtrl,
                  label: 'Workouts / week',
                  icon: Icons.fitness_center_rounded,
                  suffix: 'sessions',
                  dec: _dec,
                  validator: (v) => _required(v, min: 1),
                ),
              ],
            ),
            const SizedBox(height: 28),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onConfirm,
                  icon: const Icon(Icons.check_rounded),
                  label: const Text(
                    'Confirm Plan',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey[400]!),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 16),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: onCancel,
                  child:
                      Text('Cancel', style: TextStyle(color: Colors.grey[700])),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _goalField({
    required TextEditingController ctrl,
    required String label,
    required IconData icon,
    required String suffix,
    required InputDecoration Function(String, IconData, String) dec,
    required String? Function(String?) validator,
  }) {
    return SizedBox(
      width: 260,
      child: TextFormField(
        controller: ctrl,
        keyboardType: TextInputType.number,
        decoration: dec(label, icon, suffix),
        validator: validator,
      ),
    );
  }
}

class _SavedGoalCard extends StatelessWidget {
  const _SavedGoalCard({
    required this.goal,
    required this.workouts,
    required this.snapshot,
    required this.onEdit,
    required this.onClear,
  });

  final ActivityGoal goal;
  final dynamic workouts;
  final dynamic snapshot;
  final VoidCallback onEdit;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final currentSteps   = snapshot?.steps ?? 0;
    final currentMinutes = snapshot?.activeMinutes ?? 0;
    final currentCals    = snapshot?.caloriesBurned ?? 0.0;
    final currentWorkouts = workouts.totalSessions as int;

    return _Card(
      title: 'Weekly Goal',
      subtitle: 'Saved on ${_dateFmt(goal.createdAt)}',
      icon: Icons.emoji_events_rounded,
      accentColor: Colors.amber[700]!,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit goal',
            onPressed: onEdit,
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.redAccent,
            tooltip: 'Remove goal',
            onPressed: onClear,
          ),
        ],
      ),
      child: Column(
        children: [
          _GoalProgressRow(
            label: 'Steps',
            icon: Icons.directions_walk_rounded,
            current: currentSteps.toDouble(),
            target: goal.targetSteps.toDouble(),
            unit: 'steps',
            color: const Color(0xFF1565C0),
          ),
          const SizedBox(height: 14),
          _GoalProgressRow(
            label: 'Active Minutes',
            icon: Icons.timer_rounded,
            current: currentMinutes.toDouble(),
            target: goal.targetActiveMinutes.toDouble(),
            unit: 'min',
            color: Colors.purple,
          ),
          const SizedBox(height: 14),
          _GoalProgressRow(
            label: 'Calories Burned',
            icon: Icons.local_fire_department_rounded,
            current: currentCals,
            target: goal.targetCaloriesBurned,
            unit: 'kcal',
            color: Colors.orange,
          ),
          const SizedBox(height: 14),
          _GoalProgressRow(
            label: 'Workouts',
            icon: Icons.fitness_center_rounded,
            current: currentWorkouts.toDouble(),
            target: goal.targetWorkouts.toDouble(),
            unit: 'sessions',
            color: const Color(0xFF2E7D32),
          ),
        ],
      ),
    );
  }

  static String _dateFmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

class _GoalProgressRow extends StatelessWidget {
  const _GoalProgressRow({
    required this.label,
    required this.icon,
    required this.current,
    required this.target,
    required this.unit,
    required this.color,
  });

  final String label;
  final IconData icon;
  final double current;
  final double target;
  final String unit;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final pct = (current / target).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(label,
                style: const TextStyle(
                    fontSize: 13, fontWeight: FontWeight.w600)),
            const Spacer(),
            Text(
              '${_fmt(current)} / ${_fmt(target)} $unit',
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation(color),
          ),
        ),
      ],
    );
  }

  static String _fmt(double v) =>
      v >= 1000 ? '${(v / 1000).toStringAsFixed(1)}k' : v.toStringAsFixed(0);
}

class _Card extends StatelessWidget {
  const _Card({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.accentColor = const Color(0xFF2E7D32),
    this.trailing,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Color accentColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: accentColor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: const TextStyle(
                            fontSize: 17, fontWeight: FontWeight.bold)),
                    Text(subtitle,
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey[600])),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color)),
          const SizedBox(height: 3),
          Text(label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }
}