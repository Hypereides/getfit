import 'package:flutter/material.dart';
import '../domain/progress_entry.dart';

class ProgressController extends ChangeNotifier {
  final List<ProgressEntry> _entries = [];

  List<ProgressEntry> get entries => List.unmodifiable(_entries);


  List<ProgressEntry> get sortedEntries {
    final copy = [..._entries];
    copy.sort((a, b) => a.date.compareTo(b.date));
    return copy;
  }

  double? get initialWeight =>
      sortedEntries.isEmpty ? null : sortedEntries.first.weightKg;

  double? get currentWeight =>
      sortedEntries.isEmpty ? null : sortedEntries.last.weightKg;

  double? get weightChange {
    final i = initialWeight;
    final c = currentWeight;
    if (i == null || c == null) return null;
    return c - i;
  }

  double? get currentBodyFat {
    final withFat =
        sortedEntries.where((e) => e.bodyFatPercent != null).toList();
    return withFat.isEmpty ? null : withFat.last.bodyFatPercent;
  }

  int get streak {
    if (_entries.isEmpty) return 0;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final days = _entries
        .map((e) => DateTime(e.date.year, e.date.month, e.date.day))
        .toSet()
        .toList()
      ..sort((a, b) => b.compareTo(a));

    final gapToToday = today.difference(days.first).inDays;
    if (gapToToday > 1) return 0;

    int count = 1;
    for (int i = 1; i < days.length; i++) {
      if (days[i - 1].difference(days[i]).inDays == 1) {
        count++;
      } else {
        break;
      }
    }
    return count;
  }

  double? get dailyTrend {
    final s = sortedEntries;
    if (s.length < 2) return null;
    return s.last.weightKg - s[s.length - 2].weightKg;
  }

  double? get weeklyTrend {
    final s = sortedEntries;
    if (s.isEmpty) return null;

    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final twoWeeksAgo = now.subtract(const Duration(days: 14));

    final thisWeek = s.where((e) => e.date.isAfter(weekAgo)).toList();
    final lastWeek = s
        .where((e) =>
            e.date.isAfter(twoWeeksAgo) && !e.date.isAfter(weekAgo))
        .toList();

    if (thisWeek.isNotEmpty && lastWeek.isNotEmpty) {
      return _avg(thisWeek) - _avg(lastWeek);
    }

    if (s.length >= 2) return s.last.weightKg - s.first.weightKg;
    return null;
  }

  void addEntry(ProgressEntry entry) {
    _entries.add(entry);
    notifyListeners();
  }

  void removeEntry(String id) {
    _entries.removeWhere((e) => e.id == id);
    notifyListeners();
  }
}

double _avg(List<ProgressEntry> entries) =>
    entries.map((e) => e.weightKg).reduce((a, b) => a + b) / entries.length;