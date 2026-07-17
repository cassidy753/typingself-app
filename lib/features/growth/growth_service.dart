/// Growth Plan service — local-only practice tracking using SharedPreferences.
///
/// Stores:
/// - `growth_practice_YYYYMMDD` → {"done": bool, "difficulty": int (1-5), "note": str}
/// - `growth_streak_start` → String (ISO date when current streak began)
/// - `growth_last_practice_date` → String (ISO date of last practice)
/// - `growth_total_practices` → int
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class PracticeEntry {
  final DateTime date;
  final bool done;
  final int difficulty; // 1=easy … 5=very hard
  final String? note;

  const PracticeEntry({
    required this.date,
    this.done = false,
    this.difficulty = 3,
    this.note,
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String().substring(0, 10),
    'done': done,
    'difficulty': difficulty,
    'note': note,
  };

  factory PracticeEntry.fromJson(Map<String, dynamic> json) {
    return PracticeEntry(
      date: DateTime.parse(json['date'] as String),
      done: json['done'] as bool? ?? false,
      difficulty: json['difficulty'] as int? ?? 3,
      note: json['note'] as String?,
    );
  }
}

class GrowthService {
  static const _prefix = 'growth_practice_';
  static const _keyStreakStart = 'growth_streak_start';
  static const _keyLastPractice = 'growth_last_practice_date';
  static const _keyTotalPractices = 'growth_total_practices';

  // ─── Daily practice ───

  /// Get today's practice entry (or a default if none recorded).
  static Future<PracticeEntry> getTodayEntry() async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${_todayKey()}';
    final raw = prefs.getString(key);
    if (raw != null) {
      return PracticeEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    }
    return PracticeEntry(date: DateTime.now(), done: false, difficulty: 3);
  }

  /// Save today's practice entry.
  static Future<void> saveTodayEntry(PracticeEntry entry) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_prefix${_todayKey()}';
    await prefs.setString(key, jsonEncode(entry.toJson()));

    // Track streak
    await _updateStreak(entry, prefs);
  }

  /// Mark today's practice as done (quick shorthand).
  static Future<void> markDone({int difficulty = 3, String? note}) async {
    final entry = PracticeEntry(
      date: DateTime.now(),
      done: true,
      difficulty: difficulty,
      note: note,
    );
    await saveTodayEntry(entry);
  }

  // ─── Streak ───

  /// Get current consecutive practice streak (in days).
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    final lastStr = prefs.getString(_keyLastPractice);
    if (lastStr == null) return 0;

    final last = DateTime.parse(lastStr);
    final today = DateTime.now();
    final diff = today.difference(last).inDays;

    if (diff == 0) {
      // Practiced today — count streak
      final startStr = prefs.getString(_keyStreakStart);
      if (startStr == null) return 1;
      final start = DateTime.parse(startStr);
      return today.difference(start).inDays + 1;
    } else if (diff == 1) {
      // Practiced yesterday but not today — show yesterday's streak
      final startStr = prefs.getString(_keyStreakStart);
      if (startStr == null) return 0;
      final start = DateTime.parse(startStr);
      return last.difference(start).inDays + 1;
    }
    return 0; // Streak broken
  }

  // ─── Week summary ───

  /// Get practice entries for the last 7 days.
  static Future<List<PracticeEntry>> getWeekEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final entries = <PracticeEntry>[];

    for (int i = 6; i >= 0; i--) {
      final date = today.subtract(Duration(days: i));
      final key = '$_prefix${_dateKey(date)}';
      final raw = prefs.getString(key);
      if (raw != null) {
        entries.add(PracticeEntry.fromJson(jsonDecode(raw) as Map<String, dynamic>));
      } else {
        entries.add(PracticeEntry(date: date, done: false, difficulty: 0));
      }
    }
    return entries;
  }

  /// Get total completed practices.
  static Future<int> getTotalPractices() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyTotalPractices) ?? 0;
  }

  // ─── Weekly difficulty trend ───

  /// Average difficulty of completed practices this week (1-5 scale).
  /// Returns null if no completed practices.
  static Future<double?> getWeekAvgDifficulty() async {
    final entries = await getWeekEntries();
    final done = entries.where((e) => e.done && e.difficulty > 0);
    if (done.isEmpty) return null;
    return done.map((e) => e.difficulty).reduce((a, b) => a + b) / done.length;
  }

  /// Completion rate this week (0.0 - 1.0).
  static Future<double> getWeekCompletionRate() async {
    final entries = await getWeekEntries();
    if (entries.isEmpty) return 0.0;
    final done = entries.where((e) => e.done).length;
    return done / entries.length;
  }

  // ─── Private helpers ───

  static String _todayKey() => _dateKey(DateTime.now());

  static String _dateKey(DateTime date) {
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  static Future<void> _updateStreak(PracticeEntry entry, SharedPreferences prefs) async {
    if (!entry.done) return;

    final lastStr = prefs.getString(_keyLastPractice);
    final today = DateTime.now();

    await prefs.setString(_keyLastPractice, today.toIso8601String().substring(0, 10));

    // Mark stage 3 as done when first practice is completed
    if (!(prefs.getBool('stage3_done') ?? false)) {
      await prefs.setBool('stage3_done', true);
    }

    if (lastStr == null) {
      // First practice ever
      await prefs.setString(_keyStreakStart, today.toIso8601String().substring(0, 10));
      await prefs.setInt(_keyTotalPractices, 1);
      return;
    }

    final last = DateTime.parse(lastStr);
    final diff = today.difference(last).inDays;

    if (diff == 1) {
      // Consecutive day — streak continues
      final total = (prefs.getInt(_keyTotalPractices) ?? 0) + 1;
      await prefs.setInt(_keyTotalPractices, total);
    } else if (diff == 0) {
      // Same day — no change
    } else {
      // Streak broken — start new streak
      await prefs.setString(_keyStreakStart, today.toIso8601String().substring(0, 10));
      final total = (prefs.getInt(_keyTotalPractices) ?? 0) + 1;
      await prefs.setInt(_keyTotalPractices, total);
    }
  }

  // ─── Reset for testing ───
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs.getKeys().where((k) => k.startsWith('growth_'));
    for (final k in keys) {
      await prefs.remove(k);
    }
  }
}
