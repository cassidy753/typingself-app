// ═══════════════════════════════════════════════════════════════════════
// ZodiacCalculator — Sun / Rising / Moon sign calculation engine
// Sun: standard date ranges (same as existing zodiac_service.dart)
// Rising: simplified 2-hour rule with sunrise adjustment (HK latitude)
// Moon: lookup-table approximation (error ±1 sign, for entertainment only)
// ═══════════════════════════════════════════════════════════════════════

class ZodiacCalculator {
  static const List<String> signs = [
    '白羊', '金牛', '雙子', '巨蟹',
    '獅子', '處女', '天秤', '天蠍',
    '人馬', '摩羯', '水瓶', '雙魚',
  ];

  static const Map<String, String> signEmoji = {
    '白羊': '♈', '金牛': '♉', '雙子': '♊', '巨蟹': '♋',
    '獅子': '♌', '處女': '♍', '天秤': '♎', '天蠍': '♏',
    '人馬': '♐', '摩羯': '♑', '水瓶': '♒', '雙魚': '♓',
  };

  static const Map<String, String> signEn = {
    '白羊': 'Aries',
    '金牛': 'Taurus',
    '雙子': 'Gemini',
    '巨蟹': 'Cancer',
    '獅子': 'Leo',
    '處女': 'Virgo',
    '天秤': 'Libra',
    '天蠍': 'Scorpio',
    '人馬': 'Sagittarius',
    '摩羯': 'Capricorn',
    '水瓶': 'Aquarius',
    '雙魚': 'Pisces',
  };

  // ─── Sun sign (standard) ───
  static String getSunSign(int month, int day) {
    if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) return '白羊';
    if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) return '金牛';
    if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) return '雙子';
    if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) return '巨蟹';
    if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) return '獅子';
    if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) return '處女';
    if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) return '天秤';
    if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) return '天蠍';
    if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) return '人馬';
    if ((month == 12 && day >= 22) || (month == 1 && day <= 19)) return '摩羯';
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) return '水瓶';
    return '雙魚';
  }

  // ─── Rising sign (simplified) ───
  // Based on 2-hour rule + sunrise adjustment (HK latitude ~22.3°N)
  static String getRisingSign(
    int hour,
    int minute, {
    int month = 6,
    int day = 15,
    String location = '香港',
  }) {
    // Sunrise hours by month for HK (simplified)
    final sunriseHours = [6.8, 6.7, 6.4, 6.0, 5.7, 5.6, 5.7, 5.9, 6.1, 6.3, 6.5, 6.8];
    final sunriseHour = sunriseHours[(month - 1).clamp(0, 11)];
    final decimalHour = hour + minute / 60.0;
    final adjustedHour = (decimalHour - sunriseHour + 24) % 24;
    final risingIndex = (adjustedHour ~/ 2) % 12;
    return signs[risingIndex];
  }

  // ─── Moon sign (simplified lookup table) ───
  // Uses a tabular approximation: moon cycles ~29.5 days through all 12 signs
  // This is ~2.46 days per sign. We compute an approximate moon longitude
  // from a reference epoch. Error margin: ±1 sign. For entertainment only.
  static String getMoonSign(int year, int month, int day, int hour) {
    // Approximate moon ecliptic longitude using a simplified formula
    // Reference: Jan 1, 2000 = JDE 2451545.0
    final y = year;
    final m = month;
    final d = day;

    // Days since J2000.0
    final double jd = _julianDay(y, m, d) + hour / 24.0;
    final double t = (jd - 2451545.0) / 36525.0;

    // Mean moon longitude (simplified — skips many perturbations)
    final double lPrime = 218.3165 + 481267.8813 * t;
    final double meanPhase = (lPrime % 360 + 360) % 360;

    // Map to zodiac sign (30° per sign)
    final int signIndex = (meanPhase / 30).floor() % 12;
    return signs[signIndex];
  }

  /// Julian Day Number (Meeus algorithm)
  static double _julianDay(int year, int month, int day) {
    int y = year;
    int m = month;
    if (m <= 2) {
      y--;
      m += 12;
    }
    final int a = (y / 100).floor();
    final int b = 2 - a + (a / 4).floor();
    return (365.25 * (y + 4716)).floor() +
        (30.6001 * (m + 1)).floor() +
        day +
        b -
        1524.5;
  }

  /// Get the combo description type based on Sun + Rising + Moon
  static String getComboType(String sun, String rising, String moon) {
    // Simple heuristic: categorize based on element compatibility
    final elements = _signElements;
    final sunEl = elements[sun] ?? '';
    final risingEl = elements[rising] ?? '';
    final moonEl = elements[moon] ?? '';

    if (sunEl == risingEl && risingEl == moonEl) {
      return '元素共鳴型';
    }
    if (sunEl == risingEl || risingEl == moonEl || sunEl == moonEl) {
      return '元素混合型';
    }
    return '元素多元型';
  }

  static String getComboDescription(String sun, String rising, String moon) {
    final type = getComboType(sun, rising, moon);
    final parts = <String>[];
    parts.add('你嘅太陽($sun) + 上升($rising) + 月亮($moon) 形成咗「$type」');

    switch (type) {
      case '元素共鳴型':
        parts.add('三大星座元素一致，你嘅內外相當一致，想法同行動好配合。');
        break;
      case '元素混合型':
        parts.add('部分元素相通，你有時會覺得自己矛盾，但其實係多面性嘅表現。');
        break;
      case '元素多元型':
        parts.add('三大星座元素各異，你係一個複雜嘅人，適應力強但有時內心會打架。');
        break;
    }

    return parts.join('\n');
  }

  static const Map<String, String> _signElements = {
    '白羊': '火', '獅子': '火', '人馬': '火',
    '金牛': '土', '處女': '土', '摩羯': '土',
    '雙子': '風', '天秤': '風', '水瓶': '風',
    '巨蟹': '水', '天蠍': '水', '雙魚': '水',
  };
}
