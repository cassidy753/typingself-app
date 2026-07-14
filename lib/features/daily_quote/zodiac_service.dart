/// Zodiac service — provides daily horoscope and sun/moon/rising calculation
/// All data is generated locally (no API call) for zero ongoing cost.
class ZodiacService {
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

  static const Map<String, Map<String, String>> signTraits = {
    '白羊': {'element': '火', 'planet': '火星', 'quality': '開創'},
    '金牛': {'element': '土', 'planet': '金星', 'quality': '固定'},
    '雙子': {'element': '風', 'planet': '水星', 'quality': '變動'},
    '巨蟹': {'element': '水', 'planet': '月亮', 'quality': '開創'},
    '獅子': {'element': '火', 'planet': '太陽', 'quality': '固定'},
    '處女': {'element': '土', 'planet': '水星', 'quality': '變動'},
    '天秤': {'element': '風', 'planet': '金星', 'quality': '開創'},
    '天蠍': {'element': '水', 'planet': '冥王星', 'quality': '固定'},
    '人馬': {'element': '火', 'planet': '木星', 'quality': '變動'},
    '摩羯': {'element': '土', 'planet': '土星', 'quality': '開創'},
    '水瓶': {'element': '風', 'planet': '天王星', 'quality': '固定'},
    '雙魚': {'element': '水', 'planet': '海王星', 'quality': '變動'},
  };

  /// Generate a daily horoscope based on the day of year + sign index.
  /// Deterministic — same sign gets same horoscope all day.
  static String dailyHoroscope(String sign, int dayOfYear) {
    final idx = signs.indexOf(sign);
    if (idx == -1) return '';

    // Deterministic seed from day + sign
    final seed = (dayOfYear * 7 + idx * 13) % _horoscopes.length;
    return _horoscopes[seed];
  }

  /// Get the zodiac sign for a given birth date
  static String? signForDate(int month, int day) {
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
    if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) return '雙魚';
    return null;
  }

  static final List<String> _horoscopes = [
    '今日適合低調行事，唔好急著做決定。',
    '你嘅直覺今日特別準，信自己一次。',
    '有舊朋友會突然出現，帶來好消息。',
    '工作上會有突破，但要主動爭取。',
    '今日小心講錯嘢，停一停諗一諗先。',
    '感情方面，坦誠比浪漫更重要。',
    '財運不錯，但唔好衝動消費。',
    '今日適合整理思緒，寫低你嘅諗法。',
    '有人暗中欣賞你，只係未講出口。',
    '今日嘅困難係包裝過嘅機會。',
    '你比自己想像中更有影響力。',
    '放鬆啲，冇嘢係解決唔到嘅。',
    '今日適合開始新習慣，細細哋就得。',
    '傾生意/傾合作，今日係好時機。',
    '注意身體訊號，休息都係生產力。',
    '今日嘅努力，下個月會見到成果。',
    '家人需要你嘅關注，抽時間打個電話。',
    '一個突如其來嘅機會，唔好錯過。',
    '今日適合獨處，充充電。',
    '你嘅直覺係對嘅，跟住行。',
    '有啲嘢放手先會得到更好嘅。',
    '今日你會幫到一個人，雖然對方唔會知道。',
    '唔好同人比較，你行緊自己嘅路。',
    '今日有貴人出現，留意身邊嘅人。',
    '計劃趕不上變化，但變化可能更好。',
    '你值得被好好對待，唔好妥協。',
    '今日適合學習新嘢，開闊視野。',
    '一個舊問題會用新角度解決。',
    '今日要對自己寬容啲。',
    '你嘅努力冇白費，只係 timing 未到。',
  ];
}
