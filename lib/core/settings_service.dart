// ═══════════════════════════════════════════════════════════════════════
// SettingsService — SharedPreferences wrapper for app settings
// Language style, dark mode, font size, age filter
// ═══════════════════════════════════════════════════════════════════════

import 'package:shared_preferences/shared_preferences.dart';

enum LanguageStyle { writtenCanto, naturalCanto }

class SettingsService {
  static final SettingsService _instance = SettingsService._();
  factory SettingsService() => _instance;
  SettingsService._();

  SharedPreferences? _prefs;

  // ─── Keys ───
  static const _keyDarkMode = 'dark_mode';
  static const _keyFontSize = 'font_size';
  static const _keyLanguageStyle = 'language_style';
  static const _keyAgeFilter = 'age_filter';
  static const _keyBgmEnabled = 'bgm_enabled';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  SharedPreferences get _p {
    assert(_prefs != null, 'SettingsService not initialized. Call init() first.');
    return _prefs!;
  }

  // ─── Dark Mode ───
  bool get darkMode => _p.getBool(_keyDarkMode) ?? false;
  set darkMode(bool v) => _p.setBool(_keyDarkMode, v);

  // ─── Font Size ───
  double get fontSize {
    final val = _p.getDouble(_keyFontSize);
    if (val == null || val <= 0) return 16.0;
    return val;
  }
  set fontSize(double v) => _p.setDouble(_keyFontSize, v.clamp(12.0, 24.0));

  // ─── Language Style ───
  LanguageStyle get languageStyle {
    final val = _p.getString(_keyLanguageStyle);
    return val == 'natural' ? LanguageStyle.naturalCanto : LanguageStyle.writtenCanto;
  }
  set languageStyle(LanguageStyle v) =>
      _p.setString(_keyLanguageStyle, v == LanguageStyle.naturalCanto ? 'natural' : 'written');

  bool get isNaturalCanto => languageStyle == LanguageStyle.naturalCanto;

  // ─── Age Filter ───
  String get ageFilter => _p.getString(_keyAgeFilter) ?? 'all';
  set ageFilter(String v) => _p.setString(_keyAgeFilter, v);

  // ─── Reading Progress ───
  Map<String, dynamic> getReadingProgress() {
    final raw = _p.getString('reading_progress');
    if (raw == null || raw.isEmpty) return {};
    try {
      return Map<String, dynamic>.from(
        (raw as String).split('|').fold<Map<String, String>>({}, (map, entry) {
          final parts = entry.split('=');
          if (parts.length == 2) map[parts[0]] = parts[1];
          return map;
        }),
      );
    } catch (_) {
      return {};
    }
  }

  void saveReadingProgress(String bookId, Map<String, dynamic> progress) {
    final all = getReadingProgress();
    all[bookId] = progress.toString();
    _p.setString('reading_progress', all.entries.map((e) => '${e.key}=${e.value}').join('|'));
  }

  // ─── Bookshelf Completion ───
  Set<String> getCompletedBookIds() {
    final raw = _p.getString('completed_books') ?? '';
    if (raw.isEmpty) return {};
    return raw.split(',').where((s) => s.isNotEmpty).toSet();
  }

  void markBookCompleted(String bookId) {
    final set = getCompletedBookIds();
    set.add(bookId);
    _p.setString('completed_books', set.join(','));
  }

  // ─── Reading Stats ───
  int get totalReadingMinutes => _p.getInt('reading_minutes') ?? 0;
  set totalReadingMinutes(int v) => _p.setInt('reading_minutes', v);

  int get booksStarted => _p.getInt('books_started') ?? 0;
  set booksStarted(int v) => _p.setInt('books_started', v);

  int get booksCompleted => getCompletedBookIds().length;

  // ─── Streak ───
  int get streakDays => _p.getInt('streak_days') ?? 0;
  set streakDays(int v) => _p.setInt('streak_days', v);

  // ─── BGM / Background Music ───
  bool get bgmEnabled => _p.getBool(_keyBgmEnabled) ?? false;
  set bgmEnabled(bool v) => _p.setBool(_keyBgmEnabled, v);
}
