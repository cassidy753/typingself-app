// ═══════════════════════════════════════════════════════════════════════
// Color Personality → TypeSoul Supplementary Test
// 10 questions mapping to 8 color-personality archetypes
// Results map to MBTI + Enneagram → TypeSoul key
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';

// ─── Color Personality Archetypes ───
enum ColorArchetype {
  red('⭕ 紅色 · 行動者'),
  blue('🔵 藍色 · 穩定者'),
  yellow('🟡 黃色 · 樂觀者'),
  green('🟢 綠色 · 成長者'),
  purple('🟣 紫色 · 創造者'),
  orange('🟠 橙色 · 冒險者'),
  pink('🩷 粉紅 · 關懷者'),
  white('⚪ 白色 · 思考者');

  final String label;
  const ColorArchetype(this.label);
}

class ColorQuestion {
  final String id;
  final String text;
  final Map<ColorArchetype, int> scores;
  final List<String> options;

  const ColorQuestion({
    required this.id,
    required this.text,
    required this.scores,
    required this.options,
  });
}

// ─── Color → TypeSoul Mapping ───
class ColorToTypeSoul {
  /// Each color maps to specific MBTI and Enneagram types
  static const Map<ColorArchetype, String> _colorMBTI = {
    ColorArchetype.red: 'ENTJ',
    ColorArchetype.blue: 'ISTJ',
    ColorArchetype.yellow: 'ENFP',
    ColorArchetype.green: 'INFJ',
    ColorArchetype.purple: 'INFP',
    ColorArchetype.orange: 'ESTP',
    ColorArchetype.pink: 'ESFJ',
    ColorArchetype.white: 'INTJ',
  };

  static const Map<ColorArchetype, int> _colorEnnea = {
    ColorArchetype.red: 8,
    ColorArchetype.blue: 1,
    ColorArchetype.yellow: 7,
    ColorArchetype.green: 2,
    ColorArchetype.purple: 4,
    ColorArchetype.orange: 7,
    ColorArchetype.pink: 2,
    ColorArchetype.white: 5,
  };

  static const Map<ColorArchetype, int> _colorWing = {
    ColorArchetype.red: 7,   // 8w7
    ColorArchetype.blue: 9,  // 1w9
    ColorArchetype.yellow: 6, // 7w6
    ColorArchetype.green: 1,  // 2w1
    ColorArchetype.purple: 5, // 4w5
    ColorArchetype.orange: 8, // 7w8
    ColorArchetype.pink: 3,   // 2w3
    ColorArchetype.white: 6,  // 5w6
  };

  /// Compute MBTI from weighted color scores
  static String computeMBTI(Map<ColorArchetype, double> scores) {
    double e = 0, i = 0, s = 0, n = 0, t = 0, f = 0, j = 0, p = 0;
    const weight = 0.5;

    for (final entry in scores.entries) {
      final mbti = _colorMBTI[entry.key]!;
      final w = entry.value * weight;
      if (mbti.contains('E')) e += w;
      if (mbti.contains('I')) i += w;
      if (mbti.contains('S')) s += w;
      if (mbti.contains('N')) n += w;
      if (mbti.contains('T')) t += w;
      if (mbti.contains('F')) f += w;
      if (mbti.contains('J')) j += w;
      if (mbti.contains('P')) p += w;
    }

    return '${e >= i ? 'E' : 'I'}${s >= n ? 'S' : 'N'}${t >= f ? 'T' : 'F'}${j >= p ? 'J' : 'P'}';
  }

  /// Compute primary enneagram from weighted color scores
  static int computeEnneaPrimary(Map<ColorArchetype, double> scores) {
    final enneaScores = <int, double>{};
    for (int i = 1; i <= 9; i++) enneaScores[i] = 0;

    for (final entry in scores.entries) {
      final enneaType = _colorEnnea[entry.key]!;
      enneaScores[enneaType] = (enneaScores[enneaType] ?? 0) + entry.value;
    }

    int best = 1;
    for (int i = 1; i <= 9; i++) {
      if ((enneaScores[i] ?? 0) > (enneaScores[best] ?? 0)) best = i;
    }
    return best;
  }

  /// Get dominant color's wing
  static int getWing(ColorArchetype dominant) {
    return _colorWing[dominant] ?? 5;
  }

  /// Full mapping: color scores → TypeSoul key
  static String toTypeSoul(Map<ColorArchetype, double> scores) {
    final mbti = computeMBTI(scores);
    final primary = computeEnneaPrimary(scores);

    // Find dominant color
    ColorArchetype top = ColorArchetype.white;
    double topScore = 0;
    for (final entry in scores.entries) {
      if (entry.value > topScore) {
        topScore = entry.value;
        top = entry.key;
      }
    }

    final wing = getWing(top);
    return '${mbti}_${primary}w$wing';
  }
}

// ─── Question Bank (10 questions) ───
List<ColorQuestion> colorQuestions() => [
      const ColorQuestion(
        id: 'color_01',
        text: '你去旅行時，邊種描述最似你？',
        scores: {
          ColorArchetype.red: 3,
          ColorArchetype.blue: 1,
          ColorArchetype.yellow: 2,
          ColorArchetype.orange: 2,
        },
        options: [
          'Plan好晒行程，每站都要去到盡',        // red
          '慢慢享受，唔使特登去好多地方',           // blue
          '睇心情即興出發，去到邊玩到邊',          // yellow
          '專攻刺激活動，越冒險越好',               // orange
        ],
      ),
      const ColorQuestion(
        id: 'color_02',
        text: '朋友搵你傾心事嗰陣，你會…',
        scores: {
          ColorArchetype.green: 3,
          ColorArchetype.pink: 3,
          ColorArchetype.purple: 2,
          ColorArchetype.white: 1,
        },
        options: [
          '用心聆聽，支持佢嘅感受',                // green
          '即刻諗辦法幫佢解決問題',                // pink
          '陪佢一齊感受嗰種情緒',                  // purple
          '幫佢分析成件事嘅因果',                   // white
        ],
      ),
      const ColorQuestion(
        id: 'color_03',
        text: '你喺工作/學業上嘅風格係？',
        scores: {
          ColorArchetype.red: 3,
          ColorArchetype.blue: 3,
          ColorArchetype.white: 2,
          ColorArchetype.yellow: 1,
        },
        options: [
          '目標為本，講效率同成果',                // red
          '規規矩矩，按照流程做好',                 // blue
          '深入研究，做到最透徹',                   // white
          '創新方法，唔想跟 dead rules',            // yellow
        ],
      ),
      const ColorQuestion(
        id: 'color_04',
        text: '你面對壓力嘅時候通常會…',
        scores: {
          ColorArchetype.red: 2,
          ColorArchetype.orange: 3,
          ColorArchetype.white: 2,
          ColorArchetype.green: 1,
        },
        options: [
          '更加搏命，用行動解決問題',               // red
          '搵方法發洩，做運動/去玩',                // orange
          '收埋自己，分析壓力來源',                 // white
          '搵人傾訴，放鬆心情',                     // green
        ],
      ),
      const ColorQuestion(
        id: 'color_05',
        text: '你覺得自己最有魅力嘅地方係？',
        scores: {
          ColorArchetype.purple: 3,
          ColorArchetype.yellow: 2,
          ColorArchetype.pink: 2,
          ColorArchetype.blue: 1,
        },
        options: [
          '我嘅獨特氣質同創造力',                   // purple
          '我嘅正能量同樂觀',                       // yellow
          '我嘅溫柔同體貼',                         // pink
          '我嘅穩重同可靠',                         // blue
        ],
      ),
      const ColorQuestion(
        id: 'color_06',
        text: '你點樣形容你嘅社交模式？',
        scores: {
          ColorArchetype.yellow: 3,
          ColorArchetype.pink: 2,
          ColorArchetype.red: 2,
          ColorArchetype.purple: 1,
        },
        options: [
          '人越多我越開心，係派對動物',             // yellow
          '關心身邊每個人，成日約人',               // pink
          '鍾意主導話題同帶領氛圍',                 // red
          '小圈子深度交流，唔鍾意大群人',           // purple
        ],
      ),
      const ColorQuestion(
        id: 'color_07',
        text: '你放假最享受嘅活動係？',
        scores: {
          ColorArchetype.purple: 3,
          ColorArchetype.green: 2,
          ColorArchetype.blue: 2,
          ColorArchetype.white: 2,
        },
        options: [
          '畫畫/寫作/做創作嘅嘢',                  // purple
          '做瑜伽/行山/親近大自然',                 // green
          '整理屋企/整下小手工',                    // blue
          '睇書/上網學新知識',                      // white
        ],
      ),
      const ColorQuestion(
        id: 'color_08',
        text: '你對「成功」嘅定義最接近邊個？',
        scores: {
          ColorArchetype.red: 3,
          ColorArchetype.blue: 2,
          ColorArchetype.white: 2,
          ColorArchetype.pink: 1,
        },
        options: [
          '達到目標，贏過所有人',                    // red
          '有穩定嘅生活同安穩嘅未來',               // blue
          '不斷學習同成長，掌握新技能',             // white
          '身邊嘅人幸福快樂',                       // pink
        ],
      ),
      const ColorQuestion(
        id: 'color_09',
        text: '你覺得自己最似邊種顏色嘅性格？',
        scores: {
          ColorArchetype.red: 3,
          ColorArchetype.blue: 3,
          ColorArchetype.yellow: 3,
          ColorArchetype.green: 3,
          ColorArchetype.purple: 3,
          ColorArchetype.orange: 3,
          ColorArchetype.pink: 3,
          ColorArchetype.white: 3,
        },
        options: [
          '紅色 — 熱情、果斷、有領導力',            // red
          '藍色 — 冷靜、可靠、有條理',              // blue
          '黃色 — 樂觀、創意、愛社交',              // yellow
          '綠色 — 溫柔、成長、同理心',              // green
          '紫色 — 獨特、深度、創造力',               // purple
          '橙色 — 冒險、活力、即興',                 // orange
          '粉紅 — 關懷、溫柔、付出',                 // pink
          '白色 — 理性、獨立、分析',                 // white
        ],
      ),
      const ColorQuestion(
        id: 'color_10',
        text: '你朋友通常會用邊個形容詞嚟形容你？',
        scores: {
          ColorArchetype.red: 2,
          ColorArchetype.blue: 2,
          ColorArchetype.yellow: 2,
          ColorArchetype.green: 2,
          ColorArchetype.purple: 2,
          ColorArchetype.orange: 2,
          ColorArchetype.pink: 2,
          ColorArchetype.white: 2,
        },
        options: [
          '有魄力 / 話得事',                        // red
          '可靠 / 穩陣',                             // blue
          '好玩 / 樂觀',                             // yellow
          '善解人意 / 溫柔',                         // green
          '有深度 / 與眾不同',                       // purple
          '大膽 / 鍾意冒險',                         // orange
          '體貼 / 照顧人',                           // pink
          '聰明 / 冷靜',                             // white
        ],
      ),
    ];

// ─── Scoring Engine ───
class ColorScoringEngine {
  /// Score answers: questionId → optionIndex (0–N).
  /// Returns Map<ColorArchetype, score>
  static Map<ColorArchetype, double> score(Map<String, int> answers) {
    final questions = colorQuestions();
    final totals = <ColorArchetype, double>{};
    final maxScores = <ColorArchetype, double>{};

    for (final q in questions) {
      final idx = answers[q.id];
      if (idx == null) continue;

      // The option index maps to the color archetype order in scores
      final colors = q.scores.entries.toList();
      if (idx >= colors.length) continue;

      final archetype = colors[idx].key;
      final weight = colors[idx].value.toDouble();

      totals[archetype] = (totals[archetype] ?? 0) + weight;
      maxScores[archetype] = (maxScores[archetype] ?? 0) + weight;
    }

    final result = <ColorArchetype, double>{};
    for (final color in ColorArchetype.values) {
      final maxVal = maxScores[color] ?? 1;
      result[color] = ((totals[color] ?? 0) / maxVal).clamp(0.0, 1.0);
    }
    return result;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TESTS
// ═══════════════════════════════════════════════════════════════════════
void main() {
  group('Color Question Bank', () {
    test('has 10 questions', () {
      expect(colorQuestions(), hasLength(10));
    });

    test('each question has unique id', () {
      final ids = colorQuestions().map((q) => q.id).toSet();
      expect(ids, hasLength(10));
    });

    test('each question has 4+ options', () {
      for (final q in colorQuestions()) {
        expect(q.options.length, greaterThanOrEqualTo(4));
      }
    });

    test('each color appears in at least 3 questions', () {
      for (final color in ColorArchetype.values) {
        final count = colorQuestions()
            .where((q) => q.scores.containsKey(color))
            .length;
        expect(count, greaterThanOrEqualTo(3),
            reason: '${color.name} appears in < 3 questions');
      }
    });
  });

  group('Color Scoring', () {
    test('all answers produce normalised scores', () {
      final answers = <String, int>{};
      for (final q in colorQuestions()) {
        answers[q.id] = 0;
      }
      final scores = ColorScoringEngine.score(answers);
      for (final color in ColorArchetype.values) {
        expect(scores[color]!, inInclusiveRange(0.0, 1.0));
      }
    });

    test('selecting red options = highest red score', () {
      // Q1:0=red, Q3:0=red, Q8:0=red, Q9:0=red
      final answers = <String, int>{
        'color_01': 0, // red option
        'color_02': 1, // pink
        'color_03': 0, // red
        'color_04': 0, // red
        'color_05': 0, // purple
        'color_06': 2, // red
        'color_07': 0, // purple
        'color_08': 0, // red
        'color_09': 0, // red
        'color_10': 0, // red
      };
      final scores = ColorScoringEngine.score(answers);
      final sorted = scores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      expect(sorted.first.key, equals(ColorArchetype.red));
    });

    test('selecting blue options = highest blue score', () {
      final answers = <String, int>{
        'color_01': 1, // blue option
        'color_03': 1, // blue
        'color_05': 3, // blue
        'color_07': 2, // blue
        'color_08': 1, // blue
        'color_09': 1, // blue
        'color_10': 1, // blue
        'color_02': 0, // green
        'color_04': 2, // white
        'color_06': 1, // pink
      };
      final scores = ColorScoringEngine.score(answers);
      final sorted = scores.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));
      expect(sorted.first.key, equals(ColorArchetype.blue));
    });
  });

  group('Color → TypeSoul Mapping', () {
    test('produces valid TypeSoul key format', () {
      final scores = <ColorArchetype, double>{
        ColorArchetype.red: 0.9,
        ColorArchetype.blue: 0.3,
        ColorArchetype.yellow: 0.6,
        ColorArchetype.green: 0.4,
        ColorArchetype.purple: 0.2,
        ColorArchetype.orange: 0.5,
        ColorArchetype.pink: 0.3,
        ColorArchetype.white: 0.4,
      };
      final typeSoul = ColorToTypeSoul.toTypeSoul(scores);
      expect(typeSoul, matches(r'^[EI][NS][TF][JP]_\dw\d$'));
    });

    test('Red-dominant → ENTJ-like + gut/ennea 8', () {
      final scores = <ColorArchetype, double>{
        ColorArchetype.red: 0.9,
        ColorArchetype.blue: 0.2,
        ColorArchetype.yellow: 0.3,
        ColorArchetype.green: 0.1,
        ColorArchetype.purple: 0.1,
        ColorArchetype.orange: 0.4,
        ColorArchetype.pink: 0.1,
        ColorArchetype.white: 0.3,
      };
      final result = ColorToTypeSoul.toTypeSoul(scores);
      // Red → ENTJ → E, thinking, judging
      expect(result[0], equals('E')); // E
      expect(result[2], equals('T')); // T
      // Red → ennea 8
      final enneaPart = result.split('_')[1];
      expect(enneaPart.startsWith('8'), isTrue,
          reason: 'Red-dominant should map to ennea 8, got $enneaPart');
    });

    test('Pink-dominant → ESFJ-like + heart/ennea 2', () {
      final scores = <ColorArchetype, double>{
        ColorArchetype.red: 0.2,
        ColorArchetype.blue: 0.3,
        ColorArchetype.yellow: 0.3,
        ColorArchetype.green: 0.5,
        ColorArchetype.purple: 0.2,
        ColorArchetype.orange: 0.1,
        ColorArchetype.pink: 0.9,
        ColorArchetype.white: 0.2,
      };
      final result = ColorToTypeSoul.toTypeSoul(scores);
      // Pink → ESFJ → feeling, judging → E, F, J
      expect(result[0], equals('E')); // E (Pink + Yellow + Green)
      expect(result[2], equals('F')); // F
      // Pink → ennea 2
      final enneaPart = result.split('_')[1];
      expect(enneaPart.startsWith('2'), isTrue,
          reason: 'Pink-dominant should map to ennea 2, got $enneaPart');
    });

    test('White-dominant → INTJ-like + head/ennea 5', () {
      final scores = <ColorArchetype, double>{
        ColorArchetype.red: 0.3,
        ColorArchetype.blue: 0.4,
        ColorArchetype.yellow: 0.1,
        ColorArchetype.green: 0.2,
        ColorArchetype.purple: 0.2,
        ColorArchetype.orange: 0.1,
        ColorArchetype.pink: 0.1,
        ColorArchetype.white: 0.9,
      };
      final result = ColorToTypeSoul.toTypeSoul(scores);
      // White → INTJ → I, N, T, J
      expect(result[0], equals('I')); // I
      expect(result[1], equals('N')); // N (White + Blue)
      expect(result[2], equals('T')); // T
      // White → ennea 5
      final enneaPart = result.split('_')[1];
      expect(enneaPart.startsWith('5'), isTrue,
          reason: 'White-dominant should map to ennea 5, got $enneaPart');
    });

    test('Purple-dominant → INFP-like + heart/ennea 4', () {
      final scores = <ColorArchetype, double>{
        ColorArchetype.red: 0.1,
        ColorArchetype.blue: 0.2,
        ColorArchetype.yellow: 0.3,
        ColorArchetype.green: 0.3,
        ColorArchetype.purple: 0.9,
        ColorArchetype.orange: 0.1,
        ColorArchetype.pink: 0.2,
        ColorArchetype.white: 0.2,
      };
      final result = ColorToTypeSoul.toTypeSoul(scores);
      final mbti = result.split('_')[0];
      expect(mbti[1], equals('N')); // N
      // Purple → ennea 4
      final enneaPart = result.split('_')[1];
      expect(enneaPart.startsWith('4'), isTrue,
          reason: 'Purple-dominant should map to ennea 4, got $enneaPart');
    });

    test('Orange-dominant → ESTP-like + gut/ennea 7w8', () {
      final scores = <ColorArchetype, double>{
        ColorArchetype.red: 0.4,
        ColorArchetype.blue: 0.1,
        ColorArchetype.yellow: 0.4,
        ColorArchetype.green: 0.1,
        ColorArchetype.purple: 0.1,
        ColorArchetype.orange: 0.9,
        ColorArchetype.pink: 0.1,
        ColorArchetype.white: 0.1,
      };
      final result = ColorToTypeSoul.toTypeSoul(scores);
      // Orange → ESTP → E, S, T, P
      expect(result[0], equals('E'));
      expect(result[3], equals('P')); // P
      // Orange → ennea 7w8
      final ts = result.split('_')[1];
      expect(ts.startsWith('7'), isTrue,
          reason: 'Orange should map to ennea 7, got $ts');
    });

    test('Green-dominant → INFJ-like + heart/ennea 2w1', () {
      final scores = <ColorArchetype, double>{
        ColorArchetype.red: 0.1,
        ColorArchetype.blue: 0.2,
        ColorArchetype.yellow: 0.1,
        ColorArchetype.green: 0.9,
        ColorArchetype.purple: 0.3,
        ColorArchetype.orange: 0.1,
        ColorArchetype.pink: 0.4,
        ColorArchetype.white: 0.2,
      };
      final result = ColorToTypeSoul.toTypeSoul(scores);
      // Green → INFJ → I, N, F, J
      final mbti = result.split('_')[0];
      expect(mbti[2], equals('F')); // F
      // Green + Pink → ennea 2
      final enneaPart = result.split('_')[1];
      expect(enneaPart.startsWith('2'), isTrue,
          reason: 'Green-dominant should map to ennea 2, got $enneaPart');
    });

    test('different color profiles produce distinct TypeSoul keys', () {
      // Action-oriented
      final action = ColorToTypeSoul.toTypeSoul({
        ColorArchetype.red: 0.9,
        ColorArchetype.orange: 0.8,
        ColorArchetype.yellow: 0.6,
        ColorArchetype.blue: 0.1,
        ColorArchetype.green: 0.1,
        ColorArchetype.purple: 0.1,
        ColorArchetype.pink: 0.1,
        ColorArchetype.white: 0.1,
      });
      // Analytical
      final analytical = ColorToTypeSoul.toTypeSoul({
        ColorArchetype.white: 0.9,
        ColorArchetype.blue: 0.7,
        ColorArchetype.purple: 0.5,
        ColorArchetype.red: 0.1,
        ColorArchetype.yellow: 0.1,
        ColorArchetype.green: 0.1,
        ColorArchetype.orange: 0.1,
        ColorArchetype.pink: 0.1,
      });
      expect(action, isNot(equals(analytical)));
      expect(action[0], equals('E')); // action → E
      expect(analytical[0], equals('I')); // analytical → I
    });

    test('end-to-end: scoring → valid TypeSoul', () {
      final answers = <String, int>{
        'color_01': 0, 'color_02': 0, 'color_03': 0,
        'color_04': 0, 'color_05': 2, 'color_06': 2,
        'color_07': 3, 'color_08': 0, 'color_09': 0,
        'color_10': 0,
      };
      final scores = ColorScoringEngine.score(answers);
      final typeSoul = ColorToTypeSoul.toTypeSoul(scores);
      expect(typeSoul, matches(r'^[EI][NS][TF][JP]_\dw\d$'));
    });
  });
}
