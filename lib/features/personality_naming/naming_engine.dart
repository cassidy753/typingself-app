class PersonalityName {
  final String mbti;
  final String enneagram;
  final String healthLevel;
  final String nameCanto;
  final String tagline;
  final String encourage;
  final String emoji;

  PersonalityName({
    required this.mbti,
    required this.enneagram,
    required this.healthLevel,
    required this.nameCanto,
    required this.tagline,
    this.encourage = '',
    this.emoji = '🧠',
  });
}

class NamingEngine {
  static const List<String> mbtiTypes = [
    'ENFJ', 'ENFP', 'ENTJ', 'ENTP',
    'ESFJ', 'ESFP', 'ESTJ', 'ESTP',
    'INFJ', 'INFP', 'INTJ', 'INTP',
    'ISFJ', 'ISFP', 'ISTJ', 'ISTP',
  ];

  static const List<String> enneagramTypes = [
    '1w9', '1w2',
    '2w1', '2w3',
    '3w2', '3w4',
    '4w3', '4w5',
    '5w4', '5w6',
    '6w5', '6w7',
    '7w6', '7w8',
    '8w7', '8w9',
    '9w8', '9w1',
  ];

  static final Map<String, PersonalityName> _names = {
    // ═══ Phase 1: 16 common MBTI × Enneagram pairings ═══
    // You can change ANY of these — they're placeholders!

    'ENFJ_5w4': PersonalityName(
      mbti: 'ENFJ', enneagram: '5w4', healthLevel: 'healthy',
      nameCanto: '高級KAM L',
      tagline: '你睇到人哋睇唔到嘅 pattern，但唔好收埋自己',
      encourage: '你嘅觀察力係天賦，唔係詛咒',
      emoji: '🧠',
    ),

    'ENFP_7w4': PersonalityName(
      mbti: 'ENFP', enneagram: '7w4', healthLevel: 'healthy',
      nameCanto: '靈感噴泉',
      tagline: '你個腦永遠有新 idea，但都要記得落地',
      encourage: '你嘅創造力係禮物，但都要休息',
      emoji: '🌈',
    ),

    'ENTJ_8w7': PersonalityName(
      mbti: 'ENTJ', enneagram: '8w7', healthLevel: 'healthy',
      nameCanto: '自然領袖',
      tagline: '你唔使大聲都有人跟，因為你值得',
      encourage: '你嘅 vision 係力量，但要記得聆聽',
      emoji: '👑',
    ),

    'ENTP_7w6': PersonalityName(
      mbti: 'ENTP', enneagram: '7w6', healthLevel: 'healthy',
      nameCanto: '辯論機器',
      tagline: '你同空氣都可以拗一餐，但你其實想被明白',
      encourage: '你嘅聰明係禮物，唔好再用嚟激嬲人',
      emoji: '🔥',
    ),

    'ESFJ_2w3': PersonalityName(
      mbti: 'ESFJ', enneagram: '2w3', healthLevel: 'healthy',
      nameCanto: '社區組長',
      tagline: '你搞掂晒所有人嘅事，但自己嗰份呢？',
      encourage: '你值得被照顧，唔好成日淨係照顧人',
      emoji: '🤝',
    ),

    'ESFP_7w6': PersonalityName(
      mbti: 'ESFP', enneagram: '7w6', healthLevel: 'healthy',
      nameCanto: '派對心臟',
      tagline: '你有你喺度就唔會悶，但都要留時間俾自己',
      encourage: '你嘅快樂係感染性嘅，但都要俾自己喊',
      emoji: '🎉',
    ),

    'ESTJ_1w2': PersonalityName(
      mbti: 'ESTJ', enneagram: '1w2', healthLevel: 'healthy',
      nameCanto: '人類閘機',
      tagline: '你把關嚴格到過海關都驚你，但係因為你負責任',
      encourage: '你嘅標準係高，但要記得人都會犯錯',
      emoji: '📋',
    ),

    'ESTP_7w8': PersonalityName(
      mbti: 'ESTP', enneagram: '7w8', healthLevel: 'healthy',
      nameCanto: '行動先鋒',
      tagline: '你諗都唔諗就衝咗出去，有時係好事嚟㗎',
      encourage: '你嘅勇氣係天賦，但都要諗一諗先',
      emoji: '🎯',
    ),

    'INFJ_4w5': PersonalityName(
      mbti: 'INFJ', enneagram: '4w5', healthLevel: 'healthy',
      nameCanto: '靈魂解讀者',
      tagline: '你未出聲佢已經知道你諗咩，但你對自己最陌生',
      encourage: '你嘅直覺係超能力，但都要信自己多啲',
      emoji: '🔮',
    ),

    'INFP_4w5': PersonalityName(
      mbti: 'INFP', enneagram: '4w5', healthLevel: 'healthy',
      nameCanto: '深夜文青',
      tagline: '你嘅內心世界比宇宙仲大，但有時要出嚟透氣',
      encourage: '你嘅情感係深度，唔好覺得自己太敏感',
      emoji: '🌙',
    ),

    'INTJ_5w6': PersonalityName(
      mbti: 'INTJ', enneagram: '5w6', healthLevel: 'healthy',
      nameCanto: '密室策劃師',
      tagline: '你已經諗好未來十年嘅 plan A 到 plan D',
      encourage: '你嘅策略係天賦，但有時都要信個 flow',
      emoji: '♟️',
    ),

    'INTP_5w6': PersonalityName(
      mbti: 'INTP', enneagram: '5w6', healthLevel: 'healthy',
      nameCanto: '理論工程師',
      tagline: '你個腦永遠喺度 build system，但記得食飯',
      encourage: '你嘅分析力係禮物，但都要落地',
      emoji: '⚙️',
    ),

    'ISFJ_9w1': PersonalityName(
      mbti: 'ISFJ', enneagram: '9w1', healthLevel: 'healthy',
      nameCanto: '人肉暖爐',
      tagline: '你靜靜雞照顧晒所有人，但你以為冇人發現',
      encourage: '你嘅溫柔係超級力量，唔好覺得理所當然',
      emoji: '🏡',
    ),

    'ISFP_9w8': PersonalityName(
      mbti: 'ISFP', enneagram: '9w8', healthLevel: 'healthy',
      nameCanto: '低調藝術家',
      tagline: '你嘅作品代表一切，但你唔鍾意出聲',
      encourage: '你嘅美感係天賦，試下多啲俾人睇你嘅作品',
      emoji: '🎨',
    ),

    'ISTJ_1w9': PersonalityName(
      mbti: 'ISTJ', enneagram: '1w9', healthLevel: 'healthy',
      nameCanto: '可靠支柱',
      tagline: '你永遠係最穩陣嗰個，但有時都要放鬆下',
      encourage: '你嘅可靠性係 your superpower，但都要適時放手',
      emoji: '⚖️',
    ),

    'ISTP_5w6': PersonalityName(
      mbti: 'ISTP', enneagram: '5w6', healthLevel: 'healthy',
      nameCanto: '沉默工匠',
      tagline: '你動手做嘅嘢永遠比把口講嘅多',
      encourage: '你嘅手藝係才華，但都要試下講出嚟',
      emoji: '🔧',
    ),
  };

  static PersonalityName? getName(String mbti, String enneagram) {
    return _names['${mbti}_$enneagram'];
  }

  static bool hasName(String mbti, String enneagram) {
    return _names.containsKey('${mbti}_$enneagram');
  }

  static int get totalEntries => _names.length;

  static void addName(PersonalityName name) {
    _names['${name.mbti}_${name.enneagram}'] = name;
  }
}
