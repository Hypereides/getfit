import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/session_controller.dart';
import '../../health_sync/presentation/health_sync_screen.dart';
import '../../health_sync/state/health_sync_controller.dart';
import '../../workouts/state/workout_controller.dart';
import '../domain/progress_entry.dart';
import '../state/progress_controller.dart';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  final _weightCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  bool _showForm = false;

  @override
  void dispose() {
    _weightCtrl.dispose();
    _fatCtrl.dispose();
    super.dispose();
  }

  void _submitEntry(ProgressController progress) {
    if (!_formKey.currentState!.validate()) return;

    final weight = double.parse(_weightCtrl.text.trim());
    final fat = _fatCtrl.text.trim().isEmpty
        ? null
        : double.tryParse(_fatCtrl.text.trim());

    progress.addEntry(
      ProgressEntry(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        date: DateTime.now(),
        weightKg: weight,
        bodyFatPercent: fat,
      ),
    );

    _weightCtrl.clear();
    _fatCtrl.clear();
    setState(() => _showForm = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: Color(0xFF2E7D32),
        content: Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text('Measurement saved.',
                style: TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressController>();
    final session = context.watch<SessionController>();
    final workouts = context.watch<WorkoutController>();
    final user = session.currentUser;
    final profile = user?.profile;
    final double profileWeight = profile?.weightKg ?? 0;
    final double heightM = (profile?.heightCm ?? 0) / 100;
    final double displayWeight = progress.currentWeight ?? profileWeight;
    final double bmi = heightM > 0 ? displayWeight / (heightM * heightM) : 0;
    final double tdee = profile?.tdee ?? 0;
    final double waterL = displayWeight * 0.033;
    final sw = MediaQuery.of(context).size.width;
    final isMobile = sw < 600;
    final outerPad = isMobile ? 12.0 : 24.0;
    final innerPad = isMobile ? 20.0 : 48.0;

    return SingleChildScrollView(
      padding: EdgeInsets.all(outerPad),
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
        padding: EdgeInsets.all(innerPad),
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
                    Icons.trending_up_rounded,
                    color: Color(0xFF2E7D32),
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Text(
                    'Progress & Tracking',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: -0.5,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
            _GoogleFitBanner(),
            const SizedBox(height: 40),
            _sectionTitle('Weight Summary'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 24,
              runSpacing: 24,
              children: [
                _SummaryCard(
                  title: 'Initial Weight',
                  value: progress.initialWeight != null
                      ? '${progress.initialWeight!.toStringAsFixed(1)} kg'
                      : '${profileWeight.toStringAsFixed(1)} kg',
                  subtitle: 'from profile / first log',
                  icon: Icons.monitor_weight_outlined,
                ),
                _SummaryCard(
                  title: 'Current Weight',
                  value: '${displayWeight.toStringAsFixed(1)} kg',
                  subtitle: progress.currentWeight != null
                      ? 'latest entry'
                      : 'from profile',
                  icon: Icons.monitor_weight,
                  highlighted: true,
                ),
                _SummaryCard(
                  title: 'Weight Change',
                  value: progress.weightChange != null
                      ? '${progress.weightChange! >= 0 ? '+' : ''}${progress.weightChange!.toStringAsFixed(1)} kg'
                      : '— kg',
                  subtitle: 'since first log',
                  icon: Icons.swap_vert_rounded,
                  changeValue: progress.weightChange,
                ),
                if (progress.currentBodyFat != null)
                  _SummaryCard(
                    title: 'Body Fat',
                    value: '${progress.currentBodyFat!.toStringAsFixed(1)} %',
                    subtitle: 'latest logged',
                    icon: Icons.percent_rounded,
                  ),
              ],
            ),

            const SizedBox(height: 48),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 40),
            _sectionTitle('Detailed Indicators'),
            const SizedBox(height: 4),
            Text(
              'Computed from your profile, latest measurement, and workout history.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _IndicatorTile(
                  icon: Icons.speed_rounded,
                  label: 'BMI',
                  value: bmi > 0 ? bmi.toStringAsFixed(1) : '—',
                  sub: bmi > 0 ? _bmiCategory(bmi) : 'log weight to calculate',
                  iconColor: _bmiColor(bmi),
                ),
                _IndicatorTile(
                  icon: Icons.local_fire_department_outlined,
                  label: 'Daily TDEE',
                  value: tdee > 0 ? '${tdee.toStringAsFixed(0)} kcal' : '—',
                  sub: 'maintenance calories',
                  iconColor: Colors.orange,
                ),
                _IndicatorTile(
                  icon: Icons.water_drop_outlined,
                  label: 'Water Target',
                  value: displayWeight > 0 ? '${waterL.toStringAsFixed(1)} L' : '—',
                  sub: '33 ml / kg bodyweight',
                  iconColor: Colors.blue,
                ),
                _IndicatorTile(
                  icon: Icons.fitness_center_rounded,
                  label: 'Workouts Logged',
                  value: workouts.totalSessions.toString(),
                  sub: '${workouts.totalActivities} total activities',
                  iconColor: const Color(0xFF2E7D32),
                ),
                _IndicatorTile(
                  icon: Icons.local_fire_department_rounded,
                  label: 'Calories Burned',
                  value: '${workouts.totalCaloriesBurned.toStringAsFixed(0)} kcal',
                  sub: 'estimated, all workouts',
                  iconColor: Colors.deepOrange,
                ),
                _IndicatorTile(
                  icon: Icons.calendar_today_rounded,
                  label: 'Tracking Streak',
                  value: '${progress.streak} day${progress.streak == 1 ? '' : 's'}',
                  sub: progress.streak > 0 ? 'keep it up!' : 'log today to start',
                  iconColor: progress.streak > 0 ? Colors.amber[700]! : Colors.grey,
                ),
              ],
            ),

            const SizedBox(height: 48),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 40),
            _sectionTitle('Progress Trends'),
            const SizedBox(height: 4),
            Text(
              'Based on your logged measurements.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),

            progress.entries.length < 2
                ? _emptyTrendCard()
                : Wrap(
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      _TrendCard(
                        label: 'Daily Trend',
                        subtitle: 'vs previous entry',
                        change: progress.dailyTrend,
                        goal: profile?.goal,
                      ),
                      _TrendCard(
                        label: 'Weekly Trend',
                        subtitle: 'this week vs last week',
                        change: progress.weeklyTrend,
                        goal: profile?.goal,
                      ),
                    ],
                  ),

            const SizedBox(height: 48),
            Divider(color: Colors.grey[200]),
            const SizedBox(height: 40),
            Row(
              children: [
                Flexible(child: _sectionTitle('Log a Measurement')),
                const SizedBox(width: 12),
                if (!_showForm)
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: () => setState(() => _showForm = true),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text('Add', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
              ],
            ),

            if (_showForm) ...[
              const SizedBox(height: 24),
              _LogForm(
                formKey: _formKey,
                weightCtrl: _weightCtrl,
                fatCtrl: _fatCtrl,
                onSubmit: () => _submitEntry(progress),
                onCancel: () {
                  _weightCtrl.clear();
                  _fatCtrl.clear();
                  setState(() => _showForm = false);
                },
              ),
            ],
            if (progress.sortedEntries.isNotEmpty) ...[
              const SizedBox(height: 48),
              Divider(color: Colors.grey[200]),
              const SizedBox(height: 40),
              _sectionTitle('Measurement History'),
              const SizedBox(height: 16),
              ...progress.sortedEntries.reversed.take(10).map(
                    (entry) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _HistoryRow(
                        entry: entry,
                        onDelete: () =>
                            context.read<ProgressController>().removeEntry(entry.id),
                      ),
                    ),
                  ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) => Text(
        text,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
      );

  Widget _emptyTrendCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          children: [
            Icon(Icons.info_outline, color: Colors.grey[400]),
            const SizedBox(width: 14),
            Text(
              'Log at least 2 measurements to see trends.',
              style: TextStyle(color: Colors.grey[600], fontSize: 15),
            ),
          ],
        ),
      );

  String _bmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25.0) return 'Normal';
    if (bmi < 30.0) return 'Overweight';
    return 'Obese';
  }

  Color _bmiColor(double bmi) {
    if (bmi <= 0) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25.0) return const Color(0xFF2E7D32);
    if (bmi < 30.0) return Colors.orange;
    return Colors.red;
  }
}


class _LogForm extends StatelessWidget {
  const _LogForm({
    required this.formKey,
    required this.weightCtrl,
    required this.fatCtrl,
    required this.onSubmit,
    required this.onCancel,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController weightCtrl;
  final TextEditingController fatCtrl;
  final VoidCallback onSubmit;
  final VoidCallback onCancel;

  InputDecoration _dec(String label, IconData icon) => InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[700]),
        prefixIcon: Icon(icon, color: Colors.grey[600]),
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

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final fieldWidth = constraints.maxWidth > 560
          ? 260.0
          : double.infinity;

      return Container(
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBF8),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFCFE8D1)),
        ),
        child: Form(
          key: formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'New Measurement',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 20,
                runSpacing: 20,
                children: [
                  SizedBox(
                    width: fieldWidth,
                    child: TextFormField(
                      controller: weightCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dec('Weight (kg) *', Icons.monitor_weight_outlined),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return 'Weight is required';
                        final val = double.tryParse(v.trim());
                        if (val == null) return 'Enter a valid number';
                        if (val <= 0) return 'Weight must be greater than 0';
                        if (val > 500) return 'Weight seems too high';
                        return null;
                      },
                    ),
                  ),
                  SizedBox(
                    width: fieldWidth,
                    child: TextFormField(
                      controller: fatCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: _dec('Body Fat % (optional)', Icons.percent_rounded),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) return null;
                        final val = double.tryParse(v.trim());
                        if (val == null) return 'Enter a valid number';
                        if (val <= 0 || val >= 100) return 'Body fat must be between 0 and 100';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onSubmit,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('Save Measurement', style: TextStyle(fontWeight: FontWeight.w600)),
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey[400]!),
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    onPressed: onCancel,
                    child: Text('Cancel', style: TextStyle(color: Colors.grey[700])),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}


class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    this.highlighted = false,
    this.changeValue,
  });

  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final bool highlighted;
  final double? changeValue;

  @override
  Widget build(BuildContext context) {
    Color? accentColor;
    if (changeValue != null) {
      accentColor = changeValue! < 0
          ? const Color(0xFF2E7D32)
          : changeValue! > 0
              ? Colors.red[400]
              : Colors.grey;
    }

    return Container(
      width: 200,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFFE8F5E9) : Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlighted ? const Color(0xFFA5D6A7) : Colors.grey[200]!,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: highlighted ? const Color(0xFF2E7D32) : Colors.grey[500], size: 26),
          const SizedBox(height: 14),
          Text(title, style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: accentColor ?? const Color(0xFF1B1B1B)),
          ),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
        ],
      ),
    );
  }
}


class _IndicatorTile extends StatelessWidget {
  const _IndicatorTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.sub,
    required this.iconColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final String sub;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;
    final tileWidth = sw < 600 ? double.infinity : 220.0;

    return Container(
      width: tileWidth,
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
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 3),
                Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                Text(sub, style: TextStyle(fontSize: 11, color: Colors.grey[500])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TrendCard extends StatelessWidget {
  const _TrendCard({
    required this.label,
    required this.subtitle,
    required this.change,
    required this.goal,
  });

  final String label;
  final String subtitle;
  final double? change;
  final String? goal;

  @override
  Widget build(BuildContext context) {
    if (change == null) {
      return Container(
        width: 240,
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Text('$label: not enough data', style: TextStyle(color: Colors.grey[500])),
      );
    }
    final isPositive = change! > 0;
    final isGoodChange = goal == 'gain_weight' ? isPositive : !isPositive;
    final isNeutral = change!.abs() < 0.05;

    final Color color = isNeutral
        ? Colors.grey
        : isGoodChange
            ? const Color(0xFF2E7D32)
            : Colors.red[400]!;

    final IconData arrow = isNeutral
        ? Icons.remove_rounded
        : isPositive
            ? Icons.arrow_upward_rounded
            : Icons.arrow_downward_rounded;

    final String sign = change! > 0 ? '+' : '';

    return Container(
      width: 240,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
          Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
                child: Icon(arrow, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                '$sign${change!.toStringAsFixed(2)} kg',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.onDelete});

  final ProgressEntry entry;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final d = entry.date;
    final dateStr =
        '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}  '
        '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          const Icon(Icons.monitor_weight_outlined, color: Color(0xFF2E7D32), size: 20),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${entry.weightKg.toStringAsFixed(1)} kg'
                  '${entry.bodyFatPercent != null ? '  ·  ${entry.bodyFatPercent!.toStringAsFixed(1)} % fat' : ''}',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 3),
                Text(dateStr, style: TextStyle(fontSize: 12, color: Colors.grey[500])),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            color: Colors.redAccent,
            tooltip: 'Delete entry',
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}

class _GoogleFitBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<HealthSyncController>();
    final isConnected = ctrl.isConnected;
    final snapshot = ctrl.snapshot;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const HealthSyncScreen()),
          );
        },
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isConnected
                  ? [const Color(0xFF0D47A1), const Color(0xFF1976D2)]
                  : [Colors.grey[700]!, Colors.grey[600]!],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.monitor_heart_rounded, color: Colors.white, size: 28),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isConnected ? 'Google Fit — Synced' : 'Connect Google Fit',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                    ),
                    Text(
                      isConnected && snapshot != null
                          ? '${snapshot.steps} steps · ${snapshot.activeMinutes} active min today'
                          : 'Tap to sync steps, calories and activity data',
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                  ],
                ),
              ),
              if (isConnected)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.greenAccent),
                  ),
                  child: const Text('Connected',
                      style: TextStyle(color: Colors.greenAccent, fontSize: 11, fontWeight: FontWeight.w700)),
                )
              else
                const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white60, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}