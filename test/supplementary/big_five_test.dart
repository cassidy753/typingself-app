// ═══════════════════════════════════════════════════════════════════════
// Big Five (OCEAN) → TypeSoul Supplementary Test
// 12 questions mapping OCEAN dimensions to MBTI + Enneagram → TypeSoul
// ═══════════════════════════════════════════════════════════════════════

import 'package:flutter_test/flutter_test.dart';

// ─── Big Five Question Model ───
class BigFiveQuestion {
  final String id;
  final String text;
  final Map<String, int> scores; // O,C,E,A,N → values
  final List<String> options;

  const BigFiveQuestion({
    required this.id,
    required this.text,
    required this.scores,
    required this.options,
  });
}

// ─── Big Five Result → TypeSoul Mapping ───
class BigFiveToTypeSoul {
  static const _mbtiMapping = {
    // Openness → N/S, Conscientiousness → J/P, Extraversion → E/I, Agreeableness → F/T
    // Neuroticism → enneagram center (high N → head/heart, low N → gut)
    'ENFJ': 'ENFJ',
    'ENFP': 'ENFP',
    'ENTJ': 'ENTJ',
    'ENTP': 'ENTP',
    'ESFJ': 'ESFJ',
    'ESFP': 'ESFP',
    'ESTJ': 'ESTJ',
    'ESTP': 'ESTP',
    'INFJ': 'INFJ',
    'INFP': 'INFP',
    'INTJ': 'INTJ',
    'INTP': 'INTP',
    'ISFJ': 'ISFJ',
    'ISFP': 'ISFP',
    'ISTJ': 'ISTJ',
    'ISTP': 'ISTP',
  };

  /// Map normalised OCEAN scores to MBTI 4-letter type
  static String computeMBTI(
    double openness,
    double conscientiousness,
    double extraversion,
    double agreeableness,
  ) {
    final e = extraversion >= 0.5 ? 'E' : 'I';
    final s = openness >= 0.5 ? 'N' : 'S';
    final t = agreeableness >= 0.5 ? 'F' : 'T';
    final j = conscientiousness >= 0.5 ? 'J' : 'P';
    return '$e$s$t$j';
  }

  /// Map neuroticism score to enneagram type (1–9)
  static int computeEnneaPrimary(double neuroticism, double extraversion) {
    // Low neuroticism → gut types (8, 9, 1)
    if (neuroticism < 0.35) {
      if (extraversion >= 0.6) return 8;
      if (extraversion <= 0.4) return 9;
      return 1;
    }
    // Medium neuroticism → heart types (2, 3, 4)
    if (neuroticism < 0.65) {
      if (extraversion >= 0.6) return 3;
      if (extraversion <= 0.4) return 4;
      return 2;
    }
    // High neuroticism → head types (5, 6, 7)
    if (extraversion >= 0.6) return 7;
    if (extraversion <= 0.4) return 5;
    return 6;
  }

  /// Compute the wing type (adjacent to primary)
  static int computeWing(int primary, Map<int, double> typeScores) {
    final neighbors = primary == 1
        ? [9, 2]
        : primary == 9
            ? [8, 1]
            : [primary - 1, primary + 1];
    final s1 = typeScores[neighbors[0]] ?? 0;
    final s2 = typeScores[neighbors[1]] ?? 0;
    return s1 >= s2 ? neighbors[0] : neighbors[1];
  }

  /// Full mapping: OCEAN scores → TypeSoul key (e.g. "ENFJ_4w5")
  static String toTypeSoul(Map<String, double> oceanScores) {
    final o = oceanScores['O'] ?? 0.5;
    final c = oceanScores['C'] ?? 0.5;
    final e = oceanScores['E'] ?? 0.5;
    final a = oceanScores['A'] ?? 0.5;
    final n = oceanScores['N'] ?? 0.5;

    final mbti = computeMBTI(o, c, e, a);
    final primary = computeEnneaPrimary(n, e);

    // Build secondary type scores for wing calculation
    final typeScores = <int, double>{};
    for (int i = 1; i <= 9; i++) {
      typeScores[i] = _enneaScore(i, n, e, a);
    }
    final wing = computeWing(primary, typeScores);

    return '${mbti}_${primary}w$wing';
  }

  /// Heuristic: how much does each enneagram type score given OCEAN traits
  static double _enneaScore(int type, double n, double e, double a) {
    // Each enneagram type responds differently to OCEAN factors
    const profiles = {
      1: {'N': -0.4, 'E': 0.0, 'C': 0.8, 'A': 0.2, 'O': -0.2},
      2: {'N': 0.1, 'E': 0.6, 'C': 0.2, 'A': 0.9, 'O': 0.1},
      3: {'N': 0.2, 'E': 0.8, 'C': 0.7, 'A': 0.3, 'O': 0.3},
      4: {'N': 0.8, 'E': -0.3, 'C': -0.3, 'A': 0.1, 'O': 0.7},
      5: {'N': 0.4, 'E': -0.8, 'C': 0.5, 'A': -0.3, 'O': 0.6},
      6: {'N': 0.9, 'E': -0.4, 'C': 0.4, 'A': 0.0, 'O': -0.4},
      7: {'N': -0.3, 'E': 0.9, 'C': -0.6, 'A': 0.2, 'O': 0.8},
      8: {'N': -0.6, 'E': 0.7, 'C': 0.3, 'A': -0.8, 'O': 0.0},
      9: {'N': -0.5, 'E': -0.5, 'C': 0.0, 'A': 0.7, 'O': -0.5},
    };
    final p = profiles[type]!;
    var score = 2.0; // base
    score += p['N']! * n;
    score += p['E']! * e;
    score += p['C']! * 0.5; // partial
    score += p['A']! * a;
    score += p['O']! * 0.3;
    return score.clamp(0.0, 5.0);
  }
}

// ─── Question Bank ───
List<BigFiveQuestion> bigFiveQuestions() => [
      // ═══ Openness (O) ═══
      const BigFiveQuestion(
        id: 'bf_o1',
        text: '我鍾意嘗試新嘢，就算未試過都唔怕',
        scores: {'O': 3},
        options: ['完全唔同意', '少少同意', '幾同意', '好同意', '完全同意'],
      ),
      const BigFiveQuestion(
        id: 'bf_o2',
        text: '我成日幻想唔同嘅可能性',
        scores: {'O': 3},
        options: ['完全唔同意', '少少同意', '幾同意', '好同意', '完全同意'],
      ),
      const BigFiveQuestion(
        id: 'bf_o3',
        text: '我對藝術同抽象概念冇乜興趣 (反向)',
        scores: {'O': -3},
        options: ['完全同意', '好同意', '幾同意', '少少同意', '完全唔同意'],
      ),

      // ═══ Conscientiousness (C) ═══
      const BigFiveQuestion(
        id: 'bf_c1',
        text: '我做完嘢會仔細檢查有冇錯',
        scores: {'C': 3},
        options: ['完全唔同意', '少少同意', '幾同意', '好同意', '完全同意'],
      ),
      const BigFiveQuestion(
        id: 'bf_c2',
        text: '我鍾意將啲嘢安排得井井有條',
        scores: {'C': 3},
        options: ['完全唔同意', '少少同意', '幾同意', '好同意', '完全同意'],
      ),
      const BigFiveQuestion(
        id: 'bf_c3',
        text: '我成日拖延到最後一刻先做 (反向)',
        scores: {'C': -3},
        options: ['完全同意', '好同意', '幾同意', '少少同意', '完全唔同意'],
      ),

      // ═══ Extraversion (E) ═══
      const BigFiveQuestion(
        id: 'bf_e1',
        text: '我係人群入面會特別有活力',
        scores: {'E': 3},
        options: ['完全唔同意', '少少同意', '幾同意', '好同意', '完全同意'],
      ),
      const BigFiveQuestion(
        id: 'bf_e2',
        text: '我鍾意成日同人社交',
        scores: {'E': 3},
        options: ['完全唔同意', '少少同意', '幾同意', '好同意', '完全同意'],
      ),
      const BigFiveQuestion(
        id: 'bf_e3',
        text: '我寧願自己一個都唔想去應酬 (反向)',
        scores: {'E': -3},
        options: ['完全同意', '好同意', '幾同意', '少少同意', '完全唔同意'],
      ),

      // ═══ Agreeableness (A) ═══
      const BigFiveQuestion(
        id: 'bf_a1',
        text: '我成日顧及人哋嘅感受',
        scores: {'A': 3},
        options: ['完全唔同意', '少少同意', '幾同意', '好同意', '完全同意'],
      ),
      const BigFiveQuestion(
        id: 'bf_a2',
        text: '我信得過大部分人',
        scores: {'A': 3},
        options: ['完全唔同意', '少少同意', '幾同意', '好同意', '完全同意'],
      ),
      const BigFiveQuestion(
        id: 'bf_a3',
        text: '人哋話我辣火頭/好有攻擊性 (反向)',
        scores: {'A': -3},
        options: ['完全同意', '好同意', '幾同意', '少少同意', '完全唔同意'],
      ),

      // ═══ Neuroticism (N) ═══
      const BigFiveQuestion(
        id: 'bf_n1',
        text: '我好容易感到焦慮同緊張',
        scores: {'N': 3},
        options: ['完全唔同意', '少少同意', '幾同意', '好同意', '完全同意'],
      ),
      const BigFiveQuestion(
        id: 'bf_n2',
        text: '我成日諗太多，擔心啲未發生嘅事',
        scores: {'N': 3},
        options: ['完全唔同意', '少少同意', '幾同意', '好同意', '完全同意'],
      ),
      const BigFiveQuestion(
        id: 'bf_n3',
        text: '我好少因為小事唔開心 (反向)',
        scores: {'N': -3},
        options: ['完全同意', '好同意', '幾同意', '少少同意', '完全唔同意'],
      ),
    ];

// ─── Scoring Engine ───
class BigFiveScoringEngine {
  /// Score a set of answers (questionId → optionIndex 0–4)
  static Map<String, double> score(Map<String, int> answers) {
    final questions = bigFiveQuestions();
    final totals = <String, double>{'O': 0, 'C': 0, 'E': 0, 'A': 0, 'N': 0};
    final maxScores = <String, double>{'O': 0, 'C': 0, 'E': 0, 'A': 0, 'N': 0};

    for (final q in questions) {
      final idx = answers[q.id];
      if (idx == null) continue;

      // Scale 0–4 → 0.0–1.0
      final raw = idx / 4.0;
      for (final entry in q.scores.entries) {
        final dim = entry.key;
        final sign = entry.value.sign;
        final weight = entry.value.abs();
        if (sign >= 0) {
          totals[dim] = (totals[dim] ?? 0) + raw * weight;
        } else {
          totals[dim] = (totals[dim] ?? 0) + (1.0 - raw) * weight;
        }
        maxScores[dim] = (maxScores[dim] ?? 0) + weight;
      }
    }

    // Normalise to 0–1
    final result = <String, double>{};
    for (final dim in totals.keys) {
      final maxVal = maxScores[dim] ?? 1;
      result[dim] = ((totals[dim] ?? 0) / maxVal).clamp(0.0, 1.0);
    }
    return result;
  }
}

// ═══════════════════════════════════════════════════════════════════════
// TESTS
// ═══════════════════════════════════════════════════════════════════════
void main() {
  group('Big Five Question Bank', () {
    test('has 15 questions', () {
      expect(bigFiveQuestions(), hasLength(15));
    });

    test('each question has unique id', () {
      final ids = bigFiveQuestions().map((q) => q.id).toSet();
      expect(ids, hasLength(15));
    });

    test('each dimension has 3 questions', () {
      for (final dim in ['O', 'C', 'E', 'A', 'N']) {
        final count = bigFiveQuestions().where((q) => q.scores.containsKey(dim)).length;
        expect(count, 3, reason: 'Dimension $dim should have 3 questions');
      }
    });
  });

  group('Big Five Scoring', () {
    test('all-min answers produce low OCEAN scores', () {
      final answers = <String, int>{};
      for (final q in bigFiveQuestions()) {
        answers[q.id] = 0; // all "完全唔同意"
      }
      final scores = BigFiveScoringEngine.score(answers);
      for (final dim in ['O', 'C', 'E', 'A', 'N']) {
        // All have at least some reversed scored at 0 → high
        // O: one reversed, C: one reversed, E: one reversed, A: one reversed, N: one reversed
        expect(scores[dim]!,
            lessThan(0.6),
            reason: '$dim should be < 0.6 at min');
      }
    });

    test('all-max answers produce high OCEAN scores', () {
      final answers = <String, int>{};
      for (final q in bigFiveQuestions()) {
        answers[q.id] = 4; // all "完全同意"
      }
      final scores = BigFiveScoringEngine.score(answers);
      for (final dim in ['O', 'C', 'E', 'A', 'N']) {
        // Some reversed at max = low
        expect(scores[dim]!,
            greaterThan(0.4),
            reason: '$dim should be > 0.4 at max');
      }
    });

    test('extreme extravert scores high E, low I mapping', () {
      // Answer E questions high, reversed-E questions low
      final answers = <String, int>{
        'bf_e1': 4, 'bf_e2': 4, 'bf_e3': 0, // all high E
        'bf_o1': 2, 'bf_o2': 2, 'bf_o3': 2,
        'bf_c1': 2, 'bf_c2': 2, 'bf_c3': 2,
        'bf_a1': 2, 'bf_a2': 2, 'bf_a3': 2,
        'bf_n1': 2, 'bf_n2': 2, 'bf_n3': 2,
      };
      final scores = BigFiveScoringEngine.score(answers);
      expect(scores['E']!, greaterThan(0.7));
    });

    test('extreme neurotic scores high N, maps to head enneagram', () {
      final answers = <String, int>{
        'bf_n1': 4, 'bf_n2': 4, 'bf_n3': 0, // all high N
        'bf_o1': 2, 'bf_o2': 2, 'bf_o3': 2,
        'bf_c1': 2, 'bf_c2': 2, 'bf_c3': 2,
        'bf_e1': 0, 'bf_e2': 0, 'bf_e3': 4, // low E
        'bf_a1': 2, 'bf_a2': 2, 'bf_a3': 2,
      };
      final scores = BigFiveScoringEngine.score(answers);
      expect(scores['N']!, greaterThan(0.7));

      // High N + low E → ennea 5 or 6
      final ts = BigFiveToTypeSoul.toTypeSoul(scores);
      expect(ts, contains('_'));
      final enneaPart = ts.split('_').last;
      final primary = int.parse(enneaPart[0]);
      expect(primary, anyOf(5, 6));
    });
  });

  group('Big Five → TypeSoul Mapping', () {
    test('produces valid TypeSoul key format', () {
      final scores = {'O': 0.7, 'C': 0.6, 'E': 0.8, 'A': 0.5, 'N': 0.3};
      final typeSoul = BigFiveToTypeSoul.toTypeSoul(scores);
      // Format: MBTI_enemaWing (e.g. ENFJ_4w5)
      expect(typeSoul, matches(r'^[EI][NS][TF][JP]_\dw\d$'));
    });

    test('high O + low C → N + P type', () {
      final scores = {'O': 0.9, 'C': 0.2, 'E': 0.5, 'A': 0.5, 'N': 0.5};
      final result = BigFiveToTypeSoul.toTypeSoul(scores);
      expect(result[1], equals('N')); // intuition
      expect(result[3], equals('P')); // perceiving
    });

    test('low O + high C → S + J type', () {
      final scores = {'O': 0.2, 'C': 0.9, 'E': 0.5, 'A': 0.5, 'N': 0.5};
      final result = BigFiveToTypeSoul.toTypeSoul(scores);
      expect(result[1], equals('S')); // sensing
      expect(result[3], equals('J')); // judging
    });

    test('high E + high A → extraverted feeling type (EF)', () {
      final scores = {'O': 0.5, 'C': 0.5, 'E': 0.9, 'A': 0.9, 'N': 0.3};
      final result = BigFiveToTypeSoul.toTypeSoul(scores);
      expect(result[0], equals('E'));
      expect(result[2], equals('F'));
    });

    test('low E + low A → introverted thinking type (IT)', () {
      final scores = {'O': 0.5, 'C': 0.5, 'E': 0.1, 'A': 0.1, 'N': 0.5};
      final result = BigFiveToTypeSoul.toTypeSoul(scores);
      expect(result[0], equals('I'));
      expect(result[2], equals('T'));
    });

    test('high N + low E → head enneagram (5/6/7)', () {
      final scores = {'O': 0.5, 'C': 0.5, 'E': 0.2, 'A': 0.5, 'N': 0.9};
      final primary = BigFiveToTypeSoul.computeEnneaPrimary(0.9, 0.2);
      expect(primary, anyOf(5, 6));
    });

    test('low N + high E → gut enneagram (8/9/1)', () {
      final primary = BigFiveToTypeSoul.computeEnneaPrimary(0.2, 0.8);
      expect(primary, anyOf(8, 9, 1));
    });

    test('end-to-end: all answers → valid TypeSoul key', () {
      // Extravert, high O, moderate C, high A, low N → likely ENFJ_?w?
      final answers = <String, int>{
        'bf_o1': 4, 'bf_o2': 4, 'bf_o3': 0,
        'bf_c1': 3, 'bf_c2': 3, 'bf_c3': 1,
        'bf_e1': 4, 'bf_e2': 4, 'bf_e3': 0,
        'bf_a1': 4, 'bf_a2': 3, 'bf_a3': 0,
        'bf_n1': 0, 'bf_n2': 0, 'bf_n3': 4,
      };
      final scores = BigFiveScoringEngine.score(answers);
      final typeSoul = BigFiveToTypeSoul.toTypeSoul(scores);
      expect(typeSoul, matches(r'^[EI][NS][TF][JP]_\dw\d$'));
      expect(typeSoul[0], equals('E')); // high E → E
      expect(typeSoul[1], equals('N')); // high O → N
    });

    test('multiple personality profiles produce distinct TypeSoul keys', () {
      // Profile 1: assertive extravert
      final s1 = BigFiveToTypeSoul.toTypeSoul({'O': 0.8, 'C': 0.2, 'E': 0.9, 'A': 0.3, 'N': 0.2});
      // Profile 2: reserved analyst
      final s2 = BigFiveToTypeSoul.toTypeSoul({'O': 0.7, 'C': 0.8, 'E': 0.2, 'A': 0.3, 'N': 0.6});

      expect(s1[0], equals('E'));
      expect(s2[0], equals('I'));
      expect(s1, isNot(equals(s2)));
    });
  });
}
