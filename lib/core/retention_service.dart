/// Retention Service — app usage streak counter + daily quote notification trigger.
///
/// Tracks consecutive days the user opens the app and triggers daily quote
/// notifications via flutter_local_notifications.
library;

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class RetentionService {
  static const _keyStreakStart = 'app_streak_start';
  static const _keyLastOpen = 'app_last_open_date';
  static const _keyQuoteShownToday = 'app_quote_shown_today';

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // ─── Init ───

  /// Call once at app startup (e.g. from QuoteScreen.initState).
  static Future<void> init() async {
    await _initNotifications();
    await _trackOpen();
  }

  static Future<void> _initNotifications() async {
    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
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

  /// Schedule or show a daily quote notification.
  /// Returns true if notification was triggered.
  static Future<bool> triggerDailyQuoteNotification() async {
    final prefs = await SharedPreferences.getInstance();
    final todayStr = _dateKey(DateTime.now());

    final alreadyShown = prefs.getString(_keyQuoteShownToday);
    if (alreadyShown == todayStr) return false; // Already shown today

    await prefs.setString(_keyQuoteShownToday, todayStr);

    // Increment quote counter
    final seen = prefs.getInt('quotes_seen') ?? 0;
    await prefs.setInt('quotes_seen', seen + 1);

    const androidDetails = AndroidNotificationDetails(
      'daily_quote',
      '是日金句',
      channelDescription: '每日一句溫暖廣東話金句',
      importance: Importance.low,
      priority: Priority.low,
      showWhen: false,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: false,
      presentBadge: false,
      presentSound: false,
    );
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        '📖 是日金句',
        '怯？你就輸一世。 — 嚦咕嚦咕新年財',
        details,
      );
    } catch (_) {
      // Local notifications may fail on some platforms — safe to swallow
    }

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
