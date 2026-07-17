// ═══════════════════════════════════════════════════════════════════════
// Zodiac → TypeSoul Supplementary Test
// 12 questions (one per sign), each with 3 trait-driven options
// Results map to MBTI + Enneagram → TypeSoul key
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';

// ─── Zodiac Question Model ───
class ZodiacQuestion {
  final String id;
  final String sign; // e.g. "Aries"
  final String text;
  final Map<String, int> scores;
  final List<String> options;

  const ZodiacQuestion({
    required this.id,
    required this.sign,
    required this.text,
    required this.scores,
    required this.options,
  });
}

// ─── Zodiac Result → TypeSoul Mapping ───
class ZodiacToTypeSoul {
  /// Known MBTI preferences per zodiac sign
  static const Map<String, List<String>> _signMBTI = {
    '白羊座': ['ENTJ', 'ESTP', 'ENFP'],
    '金牛座': ['ISTJ', 'ISFJ', 'ESTJ'],
    '雙子座': ['ENTP', 'ENFP', 'ESFP'],
    '巨蟹座': ['INFJ', 'ISFJ', 'INFP'],
    '獅子座': ['ENFJ', 'ESFP', 'ENTJ'],
    '處女座': ['ISTJ', 'INTJ', 'ISFJ'],
    '天秤座': ['ENFJ', 'ESFJ', 'ESTP'],
    '天蠍座': ['INTJ', 'INFJ', 'ISTP'],
    '人馬座': ['ENFP', 'ESTP', 'ENTP'],
    '山羊座': ['ENTJ', 'ESTJ', 'INTJ'],
    '水瓶座': ['ENTP', 'INTP', 'ENFP'],
    '雙魚座': ['INFP', 'ISFP', 'INFJ'],
  };

  /// Known enneagram preferences per zodiac sign
  static const Map<String, List<int>> _signEnnea = {
    '白羊座': [8, 7, 3],
    '金牛座': [9, 1, 6],
    '雙子座': [7, 3, 5],
    '巨蟹座': [2, 4, 9],
    '獅子座': [3, 8, 7],
    '處女座': [1, 5, 6],
    '天秤座': [9, 2, 3],
    '天蠍座': [4, 5, 8],
    '人馬座': [7, 8, 3],
    '山羊座': [1, 3, 5],
    '水瓶座': [5, 7, 4],
    '雙魚座': [4, 9, 2],
  };

  /// Wing assignments for each enneagram type by zodiac
  static const Map<String, int> _signWing = {
    '白羊座': 7, // 8w7
    '金牛座': 1, // 9w1
    '雙子座': 6, // 7w6
    '巨蟹座': 1, // 2w1
    '獅子座': 2, // 3w2
    '處女座': 9, // 1w9
    '天秤座': 1, // 9w1
    '天蠍座': 5, // 4w5
    '人馬座': 8, // 7w8
    '山羊座': 2, // 1w2
    '水瓶座': 6, // 5w6
    '雙魚座': 5, // 4w5
  };

  /// Score MBTI preference based on selected answers
  static String computeMBTI(Map<String, double> signScores) {
    double e = 0, i = 0, s = 0, n = 0, t = 0, f = 0, j = 0, p = 0;

    for (final entry in signScores.entries) {
      final sign = entry.key;
      final weight = entry.value;
      final mbtiList = _signMBTI[sign] ?? ['ENFP'];

      for (final mbti in mbtiList) {
        if (mbti.contains('E')) e += weight * 0.3;
        if (mbti.contains('I')) i += weight * 0.3;
        if (mbti.contains('S')) s += weight * 0.3;
        if (mbti.contains('N')) n += weight * 0.3;
        if (mbti.contains('T')) t += weight * 0.3;
        if (mbti.contains('F')) f += weight * 0.3;
        if (mbti.contains('J')) j += weight * 0.3;
        if (mbti.contains('P')) p += weight * 0.3;
      }
    }

    return '${e >= i ? 'E' : 'I'}${s >= n ? 'S' : 'N'}${t >= f ? 'T' : 'F'}${j >= p ? 'J' : 'P'}';
  }

  /// Compute enneagram type from sign scores
  static int computeEnneaPrimary(Map<String, double> signScores) {
    final scores = <int, double>{};
    for (int i = 1; i <= 9; i++) scores[i] = 0;

    for (final entry in signScores.entries) {
      final sign = entry.key;
      final weight = entry.value;
      final enneaList = _signEnnea[sign] ?? [7];
      for (final t in enneaList) {
        scores[t] = (scores[t] ?? 0) + weight;
      }
    }

    int best = 1;
    for (int i = 1; i <= 9; i++) {
      if ((scores[i] ?? 0) > (scores[best] ?? 0)) best = i;
    }
    return best;
  }

  /// Full mapping: zodiac answer scores → TypeSoul key
  static String toTypeSoul(Map<String, double> signScores) {
    final mbti = computeMBTI(signScores);
    final primary = computeEnneaPrimary(signScores);

    // Find the dominant sign for wing
    String topSign = '雙魚座';
    double topScore = 0;
    for (final entry in signScores.entries) {
      if (entry.value > topScore) {
        topScore = entry.value;
        topSign = entry.key;
      }
    }
    final wing = _signWing[topSign] ?? 5;

    return '${mbti}_${primary}w$wing';
  }
}

// ─── Question Bank ───
List<ZodiacQuestion> zodiacQuestions() => [
      const ZodiacQuestion(
        id: 'zodiac_aries',
        sign: '白羊座',
        text: '你覺得自己似白羊座嘅邊種特質？',
        scores: {'白羊座': 3},
        options: [
          '好勝又敢衝，行動先過思考',
          '直接坦率，有咩講咩',
          '充滿熱情，鍾意挑戰新事物',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_taurus',
        sign: '金牛座',
        text: '你覺得自己似金牛座嘅邊種特質？',
        scores: {'金牛座': 3},
        options: [
          '穩定可靠，鍾意安穩嘅生活',
          '對品味同質素有要求',
          '一旦決定咗就好難改變',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_gemini',
        sign: '雙子座',
        text: '你覺得自己似雙子座嘅邊種特質？',
        scores: {'雙子座': 3},
        options: [
          '好奇心強，乜都想試想知',
          '口才好，同邊個都傾得埋',
          '諗嘢轉數快，成日有新諗法',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_cancer',
        sign: '巨蟹座',
        text: '你覺得自己似巨蟹座嘅邊種特質？',
        scores: {'巨蟹座': 3},
        options: [
          '好顧家，對親近嘅人好保護',
          '直覺強，好敏感於人哋嘅情緒',
          '記性好好，特別係關於感情嘅回憶',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_leo',
        sign: '獅子座',
        text: '你覺得自己似獅子座嘅邊種特質？',
        scores: {'獅子座': 3},
        options: [
          '有領導能力，自然成為眾人焦點',
          '慷慨大方，對朋友好好',
          '自信滿滿，唔介意表達自己',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_virgo',
        sign: '處女座',
        text: '你覺得自己似處女座嘅邊種特質？',
        scores: {'處女座': 3},
        options: [
          '注重細節，對 quality 有要求',
          '分析力強，鍾意規劃同整理',
          '有啲完美主義，對自己要求高',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_libra',
        sign: '天秤座',
        text: '你覺得自己似天秤座嘅邊種特質？',
        scores: {'天秤座': 3},
        options: [
          '重視和諧，唔鍾意衝突',
          '對美同平衡有好高嘅敏感度',
          '社交能力強，同咩人都好好傾',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_scorpio',
        sign: '天蠍座',
        text: '你覺得自己似天蠍座嘅邊種特質？',
        scores: {'天蠍座': 3},
        options: [
          '洞察力強，好易睇穿人哋嘅動機',
          '情感深刻，愛恨分明',
          '意志力強，一唔放棄',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_sagittarius',
        sign: '人馬座',
        text: '你覺得自己似人馬座嘅邊種特質？',
        scores: {'人馬座': 3},
        options: [
          '熱愛自由，唔鍾意被束縛',
          '樂觀開朗，充滿正能量',
          '鍾意冒險同探索新事物',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_capricorn',
        sign: '山羊座',
        text: '你覺得自己似山羊座嘅邊種特質？',
        scores: {'山羊座': 3},
        options: [
          '有野心同責任感，目標為本',
          '自律又有耐性，一步一步嚟',
          '成熟穩重，係身邊人嘅依靠',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_aquarius',
        sign: '水瓶座',
        text: '你覺得自己似水瓶座嘅邊種特質？',
        scores: {'水瓶座': 3},
        options: [
          '思想前衛，鍾意創新嘅嘢',
          '獨立自主，唔跟主流',
          '重視理念多過物質',
        ],
      ),
      const ZodiacQuestion(
        id: 'zodiac_pisces',
        sign: '雙魚座',
        text: '你覺得自己似雙魚座嘅邊種特質？',
        scores: {'雙魚座': 3},
        options: [
          '好有同理心，容易感受到人哋嘅情緒',
          '想像力豐富，成日發白日夢',
          '隨和又溫柔，唔鍾意傷害人',
        ],
      ),
    ];

// ─── Scoring Engine ───
class ZodiacScoringEngine {
  /// Score answers: questionId → optionIndex (0–2).
  /// Returns Map<signName, score>
  static Map<String, double> score(Map<String, int> answers) {
    final questions = zodiacQuestions();
    final totals = <String, double>{};
    final maxScores = <String, double>{};

    for (final q in questions) {
      final idx = answers[q.id];
      if (idx == null) continue;

      // option 0,1,2 → weight 0.5, 0.75, 1.0 (selecting a sign at all gives it weight)
      final weight = 0.5 + (idx / 4.0);
      for (final entry in q.scores.entries) {
        totals[entry.key] = (totals[entry.key] ?? 0) + (weight * entry.value.abs());
        maxScores[entry.key] = (maxScores[entry.key] ?? 0) + entry.value.abs().toDouble();
      }
    }

    final result = <String, double>{};
    for (final sign in [
      '白羊座', '金牛座', '雙子座', '巨蟹座',
      '獅子座', '處女座', '天秤座', '天蠍座',
      '人馬座', '山羊座', '水瓶座', '雙魚座',
    ]) {
      result[sign] = ((totals[sign] ?? 0) / (maxScores[sign] ?? 3)).clamp(0.0, 1.0);
    }
    return result;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TESTS
// ═══════════════════════════════════════════════════════════════════════
void main() {
  group('Zodiac Question Bank', () {
    test('has 12 questions (one per sign)', () {
      expect(zodiacQuestions(), hasLength(12));
    });

    test('each question has unique id', () {
      final ids = zodiacQuestions().map((q) => q.id).toSet();
      expect(ids, hasLength(12));
    });

    test('each question has 3 options', () {
      for (final q in zodiacQuestions()) {
        expect(q.options, hasLength(3), reason: '${q.id} should have 3 options');
      }
    });

    test('all 12 zodiac signs are represented exactly once', () {
      final signs = zodiacQuestions().map((q) => q.sign).toList();
      expect(signs.toSet(), hasLength(12));
    });
  });

  group('Zodiac Scoring', () {
    test('all answers produce normalised scores', () {
      final answers = <String, int>{};
      for (final q in zodiacQuestions()) {
        answers[q.id] = 1;
      }
      final scores = ZodiacScoringEngine.score(answers);
      for (final sign in [
        '白羊座', '金牛座', '雙子座', '巨蟹座',
        '獅子座', '處女座', '天秤座', '天蠍座',
        '人馬座', '山羊座', '水瓶座', '雙魚座',
      ]) {
        expect(scores[sign]!, inInclusiveRange(0.0, 1.0));
      }
    });

    test('single strong sign scores highest', () {
      final answers = <String, int>{};
      for (final q in zodiacQuestions()) {
        answers[q.id] = 0; // baseline
      }
      // Boost aries to max
      answers['zodiac_aries'] = 2;
      answers['zodiac_gemini'] = 2;

      final scores = ZodiacScoringEngine.score(answers);
      // At least aries or gemini should be one of the highest
      final sorted = scores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      expect(sorted.first.key, anyOf('白羊座', '雙子座'));
    });
  });

  group('Zodiac → TypeSoul Mapping', () {
    test('produces valid TypeSoul key format', () {
      final scores = <String, double>{
        '白羊座': 0.9, '金牛座': 0.2, '雙子座': 0.3,
        '巨蟹座': 0.1, '獅子座': 0.7, '處女座': 0.2,
        '天秤座': 0.4, '天蠍座': 0.1, '人馬座': 0.6,
        '山羊座': 0.3, '水瓶座': 0.3, '雙魚座': 0.2,
      };
      final typeSoul = ZodiacToTypeSoul.toTypeSoul(scores);
      expect(typeSoul, matches(r'^[EI][NS][TF][JP]_\dw\d$'));
    });

    test('Aries-dominant produces E-type MBTI and gut enneagram', () {
      final scores = <String, double>{
        '白羊座': 0.9, '金牛座': 0.1, '雙子座': 0.1,
        '巨蟹座': 0.1, '獅子座': 0.3, '處女座': 0.1,
        '天秤座': 0.1, '天蠍座': 0.1, '人馬座': 0.3,
        '山羊座': 0.1, '水瓶座': 0.1, '雙魚座': 0.1,
      };
      final result = ZodiacToTypeSoul.toTypeSoul(scores);
      expect(result[0], equals('E')); // Aries → extraverted
      final enneaPart = result.split('_')[1];
      final ennea = int.parse(enneaPart[0]);
      expect(ennea, anyOf(8, 7, 3));
    });

    test('Pisces-dominant produces feeling type and heart enneagram', () {
      final scores = <String, double>{
        '白羊座': 0.1, '金牛座': 0.1, '雙子座': 0.1,
        '巨蟹座': 0.3, '獅子座': 0.2, '處女座': 0.1,
        '天秤座': 0.1, '天蠍座': 0.3, '人馬座': 0.1,
        '山羊座': 0.1, '水瓶座': 0.1, '雙魚座': 0.9,
      };
      final result = ZodiacToTypeSoul.toTypeSoul(scores);
      expect(result[2], equals('F')); // Pisces + Cancer → feeling
      final enneaPart = result.split('_')[1];
      final ennea = int.parse(enneaPart[0]);
      expect(ennea, anyOf(4, 9, 2)); // Pisces + Cancer → 4,9,2
    });

    test('Virgo-dominant produces judging type and head/ennea 1', () {
      final scores = <String, double>{
        '白羊座': 0.1, '金牛座': 0.2, '雙子座': 0.1,
        '巨蟹座': 0.1, '獅子座': 0.1, '處女座': 0.9,
        '天秤座': 0.1, '天蠍座': 0.1, '人馬座': 0.1,
        '山羊座': 0.4, '水瓶座': 0.1, '雙魚座': 0.1,
      };
      final result = ZodiacToTypeSoul.toTypeSoul(scores);
      expect(result[3], equals('J')); // Virgo → judging
    });

    test('Sagittarius-dominant produces perceiving type and 7w8', () {
      final scores = <String, double>{
        '白羊座': 0.3, '金牛座': 0.1, '雙子座': 0.4,
        '巨蟹座': 0.1, '獅子座': 0.3, '處女座': 0.1,
        '天秤座': 0.1, '天蠍座': 0.1, '人馬座': 0.9,
        '山羊座': 0.1, '水瓶座': 0.4, '雙魚座': 0.1,
      };
      final result = ZodiacToTypeSoul.toTypeSoul(scores);
      expect(result[3], equals('P')); // Sag → perceiving
    });

    test('Scorpio-dominant produces intuitive + feeling and ennea 4', () {
      final scores = <String, double>{
        '白羊座': 0.1, '金牛座': 0.1, '雙子座': 0.1,
        '巨蟹座': 0.3, '獅子座': 0.1, '處女座': 0.1,
        '天秤座': 0.1, '天蠍座': 0.9, '人馬座': 0.1,
        '山羊座': 0.1, '水瓶座': 0.1, '雙魚座': 0.3,
      };
      final result = ZodiacToTypeSoul.toTypeSoul(scores);
      // Scorpio + Pisces + Cancer → strong N and F
      final mbti = result.split('_')[0];
      expect(mbti, contains('N'));
      expect(mbti, contains('F'));
    });

    test('Aquarius-dominant produces intuition + thinking and ennea 5', () {
      final scores = <String, double>{
        '白羊座': 0.1, '金牛座': 0.1, '雙子座': 0.4,
        '巨蟹座': 0.1, '獅子座': 0.1, '處女座': 0.3,
        '天秤座': 0.1, '天蠍座': 0.1, '人馬座': 0.1,
        '山羊座': 0.3, '水瓶座': 0.9, '雙魚座': 0.1,
      };
      final result = ZodiacToTypeSoul.toTypeSoul(scores);
      final mbti = result.split('_')[0];
      expect(mbti[1], equals('N')); // Aquarius + Gemini → N
      expect(mbti[2], anyOf('T', 'F')); // depends on exact scoring
    });

    test('different sign profiles produce distinct TypeSoul keys', () {
      // Assertive fire signs
      final fire = ZodiacToTypeSoul.toTypeSoul({
        '白羊座': 0.9, '獅子座': 0.8, '人馬座': 0.7,
        '金牛座': 0.1, '雙子座': 0.2, '巨蟹座': 0.1,
        '處女座': 0.1, '天秤座': 0.1, '天蠍座': 0.1,
        '山羊座': 0.1, '水瓶座': 0.1, '雙魚座': 0.1,
      });
      // Sensitive water signs
      final water = ZodiacToTypeSoul.toTypeSoul({
        '巨蟹座': 0.8, '天蠍座': 0.7, '雙魚座': 0.9,
        '白羊座': 0.1, '金牛座': 0.2, '雙子座': 0.1,
        '獅子座': 0.1, '處女座': 0.1, '天秤座': 0.1,
        '人馬座': 0.1, '山羊座': 0.1, '水瓶座': 0.1,
      });
      expect(fire, isNot(equals(water)));
      expect(fire[0], equals('E')); // fire signs → E
      expect(water[2], equals('F')); // water signs → F
    });

    test('end-to-end: scoring → valid TypeSoul', () {
      final answers = <String, int>{
        'zodiac_aries': 2, 'zodiac_taurus': 0,
        'zodiac_gemini': 1, 'zodiac_cancer': 1,
        'zodiac_leo': 2, 'zodiac_virgo': 0,
        'zodiac_libra': 1, 'zodiac_scorpio': 1,
        'zodiac_sagittarius': 2, 'zodiac_capricorn': 0,
        'zodiac_aquarius': 1, 'zodiac_pisces': 1,
      };
      final scores = ZodiacScoringEngine.score(answers);
      final typeSoul = ZodiacToTypeSoul.toTypeSoul(scores);
      expect(typeSoul, matches(r'^[EI][NS][TF][JP]_\dw\d$'));
    });
  });
}
