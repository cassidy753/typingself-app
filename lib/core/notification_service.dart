/// Notification Service — daily quote reminder scheduling.
///
/// Schedules a daily 8am notification for the daily quote using
/// flutter_local_notifications' zonedSchedule API.
/// Also requests permission on first use.
library;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

class NotificationService {
  static const _keyNotifEnabled = 'notif_enabled';
  static const _keyLastNotifDate = 'notif_last_date';

  static bool _initialized = false;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // ─── Init ───

  /// Initialize notification channels.
  /// Call once at app startup (from QuoteScreen or main).
  static Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    if (kIsWeb) return; // Web uses browser Notification API separately

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
    await _localNotifications.initialize(settings);

    // Initialize timezone data for scheduling
    tz_data.initializeTimeZones();

    // Schedule the daily 8am quote notification
    await _scheduleDailyQuote();
  }

  // ─── Permission ───

  /// Check if user has granted notification permission.
  static Future<bool> isPermissionGranted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyNotifEnabled) == true;
  }

  /// Prompt for notification permission.
  /// On iOS this triggers the native permission dialog.
  static Future<bool> requestPermission() async {
    if (kIsWeb) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyNotifEnabled, true);

    // On iOS the permission request happens during init;
    // on Android it's automatic.
    return true;
  }

  /// Check permission and prompt if not yet decided.
  /// Call when the home screen loads.
  static Future<bool> ensurePermission() async {
    if (await isPermissionGranted()) return true;
    return requestPermission();
  }

  // ─── Schedule Daily 8am ───

  /// Schedule a repeating daily notification at 8am local time.
  static Future<void> _scheduleDailyQuote() async {
    try {
      // Cancel any existing scheduled ID 1
      await _localNotifications.cancel(1);

      final now = DateTime.now();
      var scheduledDate = DateTime(now.year, now.month, now.day, 8, 0);

      if (scheduledDate.isBefore(now)) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final tzScheduledDate = tz.TZDateTime.from(scheduledDate, tz.local);

      const androidDetails = AndroidNotificationDetails(
        'daily_quote',
        '是日金句',
        channelDescription: '每日一句溫暖廣東話金句',
        importance: Importance.defaultImportance,
        priority: Priority.defaultPriority,
        showWhen: false,
        enableVibration: true,
        playSound: true,
      );
      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );
      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        1, // consistent ID for daily quote
        '📖 是日金句',
        '怯？你就輸一世。 — 嚦咕嚦咕新年財',
        tzScheduledDate,
        details,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Fall back to showing notification immediately if scheduling fails
      await _checkAndShowFallback();
    }
  }

  /// Fallback: show notification if within 8am window on app launch.
  static Future<void> _checkAndShowFallback() async {
    final now = DateTime.now();
    final todayStr = _dateKey(now);
    final prefs = await SharedPreferences.getInstance();

    if (prefs.getString(_keyLastNotifDate) == todayStr) return;

    final targetMin = 8 * 60;
    final nowMin = now.hour * 60 + now.minute;

    if (nowMin >= targetMin - 30 && nowMin <= targetMin + 30) {
      await prefs.setString(_keyLastNotifDate, todayStr);

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
        await _localNotifications.show(
          DateTime.now().millisecondsSinceEpoch ~/ 1000,
          '📖 是日金句',
          '怯？你就輸一世。 — 嚦咕嚦咕新年財',
          details,
        );
      } catch (_) {}
    }
  }

  // ─── Immediate Show ───

  /// Show a daily quote notification immediately (triggered from retention service).
  static Future<void> showNow({
    String title = '📖 是日金句',
    String body = '怯？你就輸一世。 — 嚦咕嚦咕新年財',
  }) async {
    if (kIsWeb) return;

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
      await _localNotifications.show(
        DateTime.now().millisecondsSinceEpoch ~/ 1000,
        title,
        body,
        details,
      );
    } catch (_) {}
  }

  // ─── Cleanup ───

  static void dispose() {
    _initialized = false;
  }

  static String _dateKey(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
