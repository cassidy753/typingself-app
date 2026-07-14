import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class MoodModel {
  final String emoji;
  final String label;
  final String? note;
  final DateTime date;

  MoodModel({
    required this.emoji,
    required this.label,
    this.note,
    DateTime? date,
  }) : date = date ?? DateTime.now();

  Map<String, dynamic> toJson() => {
    'emoji': emoji,
    'label': label,
    'note': note,
    'date': date.toIso8601String(),
  };

  factory MoodModel.fromJson(Map<String, dynamic> json) => MoodModel(
    emoji: json['emoji'],
    label: json['label'],
    note: json['note'],
    date: DateTime.parse(json['date']),
  );
}

class MoodService {
  static const _storageKey = 'mood_logs';

  Future<void> saveMood(MoodModel mood) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getMoods();
    logs.add(mood);
    final jsonStr = json.encode(logs.map((e) => e.toJson()).toList());
    await prefs.setString(_storageKey, jsonStr);
  }

  Future<List<MoodModel>> getMoods({int? limit}) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_storageKey);
    if (jsonStr == null) return [];
    final List<dynamic> data = json.decode(jsonStr);
    final moods = data.map((e) => MoodModel.fromJson(e)).toList();
    moods.sort((a, b) => b.date.compareTo(a.date)); // newest first
    return limit != null ? moods.take(limit).toList() : moods;
  }

  Future<MoodModel?> getTodayMood() async {
    final moods = await getMoods();
    final today = DateTime.now();
    return moods.cast<MoodModel?>().firstWhere(
      (m) =>
          m!.date.year == today.year &&
          m.date.month == today.month &&
          m.date.day == today.day,
      orElse: () => null,
    );
  }

  Future<List<MoodModel>> getRecentWeek() async {
    final moods = await getMoods();
    final weekAgo = DateTime.now().subtract(const Duration(days: 7));
    return moods.where((m) => m.date.isAfter(weekAgo)).toList();
  }

  /// Returns a simple score: 😊=2 😐=1 😔=-1 😡=-1 😰=0 😢=-2
  int moodScore(String emoji) {
    switch (emoji) {
      case '😊': return 2;
      case '😐': return 1;
      case '😰': return 0;
      case '😔': return -1;
      case '😡': return -1;
      case '😢': return -2;
      default: return 0;
    }
  }

  /// 7-day trend: positive = improving, negative = declining
  Future<int> weekTrend() async {
    final week = await getRecentWeek();
    if (week.length < 2) return 0;
    final scores = week.map((m) => moodScore(m.emoji)).toList();
    return scores.first - scores.last; // today vs 7 days ago
  }
}
