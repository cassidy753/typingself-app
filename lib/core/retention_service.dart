/// Retention Service — app usage streak counter + daily quote notification trigger.
///
/// Tracks consecutive days the user opens the app and triggers daily quote
/// notifications via the NotificationService (scheduled 8am reminders).
/// Also requests notification permission on first open.
/// Enhanced with streak progress bar data + "come back tomorrow" messaging.
library;

import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// A snapshot of the user's streak state.
class StreakInfo {
  final int currentStreak;
  final int daysUntilNextMilestone;
  final int nextMilestoneDays;
  final String nextMilestoneLabel;
  final String nextMilestoneEmoji;

  const StreakInfo({
    required this.currentStreak,
    required this.daysUntilNextMilestone,
    required this.nextMilestoneDays,
    required this.nextMilestoneLabel,
    required this.nextMilestoneEmoji,
  });

  /// Progress toward next milestone as a 0.0–1.0 fraction.
  double get progressFraction {
    final previousMilestone = _previousMilestone(currentStreak);
    if (nextMilestoneDays <= previousMilestone) return 1.0;
    final total = nextMilestoneDays - previousMilestone;
    final current = (currentStreak - previousMilestone).clamp(0, total);
    return current / total;
  }

  static int _previousMilestone(int streak) {
    if (streak >= 30) return 30;
    if (streak >= 7) return 7;
    if (streak >= 3) return 3;
    return 0;
  }
}

class RetentionService {
  static const _keyStreakStart = 'app_streak_start';
  static const _keyLastOpen = 'app_last_open_date';
  static const _keyQuoteShownToday = 'app_quote_shown_today';

  // ─── Milestones ───

  /// Ordered list of streak milestones (days).
  static const List<int> milestones = [3, 7, 30, 100, 365];

  /// Get label for a milestone.
  static String milestoneLabel(int days) {
    switch (days) {
      case 3: return '💪 好開始';
      case 7: return '🔥 一星期達人';
      case 30: return '⭐ 一個月堅持';
      case 100: return '🏅 忠實用戶';
      case 365: return '👑 一年傳奇';
      default: return '🎯 目標';
    }
  }

  /// Get the next milestone info for a streak value.
  static StreakInfo getStreakInfo(int streak) {
    int? next;
    for (final m in milestones) {
      if (streak < m) {
        next = m;
        break;
      }
    }
    if (next == null) {
      // All milestones reached
      return StreakInfo(
        currentStreak: streak,
        daysUntilNextMilestone: 0,
        nextMilestoneDays: milestones.last,
        nextMilestoneLabel: '👑 滿貫傳奇',
        nextMilestoneEmoji: '👑',
      );
    }

    return StreakInfo(
      currentStreak: streak,
      daysUntilNextMilestone: (next - streak).clamp(0, next),
      nextMilestoneDays: next,
      nextMilestoneLabel: milestoneLabel(next),
      nextMilestoneEmoji: _milestoneEmoji(next),
    );
  }

  static String _milestoneEmoji(int days) {
    switch (days) {
      case 3: return '💪';
      case 7: return '🔥';
      case 30: return '⭐';
      case 100: return '🏅';
      case 365: return '👑';
      default: return '🎯';
    }
  }

  /// Get a "come back tomorrow" message.
  static String getComeBackMessage(int streak) {
    if (streak == 0) {
      return '聽日再嚟，開始你嘅 streak 🔥';
    }
    final info = getStreakInfo(streak);
    if (info.daysUntilNextMilestone <= 0) {
      return '你已經達標！繼續保持 🎉';
    }
    if (info.daysUntilNextMilestone == 1) {
      return '聽日返嚟就可以解鎖「${info.nextMilestoneLabel}」！${info.nextMilestoneEmoji}';
    }
    return '仲有 ${info.daysUntilNextMilestone} 日就解鎖「${info.nextMilestoneLabel}」！${info.nextMilestoneEmoji}';
  }

  // ─── Init ───

  /// Call once at app startup (e.g. from QuoteScreen.initState).
  /// Initializes notification system and tracks the app open.
  static Future<void> init() async {
    // Initialize notification service (sets up daily 8am schedule)
    await NotificationService.init();

    // Request notification permission on first open (non-intrusive)
    await NotificationService.ensurePermission();

    // Track this app open for streak
    await _trackOpen();
  }

  // ─── Streak ───

  /// Track today's app open. Returns current streak length.
  static Future<int> _trackOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now();
    final todayStr = _dateKey(today);

    final lastOpen = prefs.getString(_keyLastOpen);

    if (lastOpen == todayStr) {
      // Already opened today — streak unchanged
      return _getStreak(prefs);
    }

    await prefs.setString(_keyLastOpen, todayStr);

    if (lastOpen == null) {
      // First ever open
      await prefs.setString(_keyStreakStart, todayStr);
      await prefs.setInt('days_used', 1);
      return 1;
    }

    final lastDate = _parseDateKey(lastOpen);
    final diff = today.difference(lastDate).inDays;

    final currentDays = prefs.getInt('days_used') ?? 1;
    await prefs.setInt('days_used', currentDays + 1);

    if (diff == 1) {
      // Consecutive day — streak continues
      return _getStreak(prefs);
    } else if (diff == 0) {
      // Same day — no change
      return _getStreak(prefs);
    } else {
      // Streak broken — start new streak
      await prefs.setString(_keyStreakStart, todayStr);
      return 1;
    }
  }

  /// Get the current streak length.
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return _getStreak(prefs);
  }

  static Future<int> _getStreak(SharedPreferences prefs) async {
    final startStr = prefs.getString(_keyStreakStart);
    final lastOpen = prefs.getString(_keyLastOpen);
    if (startStr == null || lastOpen == null) return 0;

    final lastDate = _parseDateKey(lastOpen);
    final today = DateTime.now();
    final diff = today.difference(lastDate).inDays;

    if (diff > 1) return 0; // Streak broken (didn't open yesterday)

    final start = _parseDateKey(startStr);
    return today.difference(start).inDays + 1;
  }

  // ─── Daily Quote Notification ───

  /// Trigger the daily quote notification.
  /// Now delegates to NotificationService which handles scheduling.
  /// The in-app quote counter is still tracked here.
  static Future<bool> triggerDailyQuoteNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _dateKey(DateTime.now());

    final alreadyShown = prefs.getString(_keyQuoteShownToday);
    if (alreadyShown == todayStr) return false; // Already shown today

    await prefs.setString(_keyQuoteShownToday, todayStr);

    // Increment quote counter
    final seen = prefs.getInt('quotes_seen') ?? 0;
    await prefs.setInt('quotes_seen', seen + 1);

    // Delegate to NotificationService
    await NotificationService.showNow();

    return true;
  }

  // ─── Helpers ───

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  static DateTime _parseDateKey(String key) {
    final parts = key.split('-');
    return DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
  }
}
