/// Analytics Service — local-only event logging to SharedPreferences.
///
/// Logs key user events (app_open, test_started, test_completed,
/// result_viewed, quote_read) to a JSON-encoded list in SharedPreferences.
/// No external service — purely for in-app usage tracking & insight.
library;

import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AnalyticsService {
  static const _key = 'analytics_events';

  // ── Events ──

  static const String appOpen = 'app_open';
  static const String testStarted = 'test_started';
  static const String testCompleted = 'test_completed';
  static const String resultViewed = 'result_viewed';
  static const String quoteRead = 'quote_read';
  static const String shadowReportViewed = 'shadow_report_viewed';
  static const String settingsOpened = 'settings_opened';
  static const String legalViewed = 'legal_viewed';

  // ── Logging ──

  /// Log a single event with optional metadata.
  static Future<void> log(String event, {Map<String, dynamic>? properties}) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    final List<dynamic> events = raw != null ? jsonDecode(raw) as List<dynamic> : [];

    events.add({
      'event': event,
      'ts': DateTime.now().toIso8601String(),
      if (properties != null) 'properties': properties,
    });

    // Keep last 500 events to cap storage
    if (events.length > 500) {
      events.removeRange(0, events.length - 500);
    }

    await prefs.setString(_key, jsonEncode(events));
  }

  // ── Querying ──

  /// Get all logged events.
  static Future<List<Map<String, dynamic>>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return [];
    final list = jsonDecode(raw) as List<dynamic>;
    return list.cast<Map<String, dynamic>>();
  }

  /// Count occurrences of a specific event.
  static Future<int> count(String event) async {
    final events = await getEvents();
    return events.where((e) => e['event'] == event).length;
  }

  /// Check if an event has ever occurred.
  static Future<bool> hasOccurred(String event) async {
    final count = await AnalyticsService.count(event);
    return count > 0;
  }

  // ── Maintenance ──

  /// Clear all logged events.
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
