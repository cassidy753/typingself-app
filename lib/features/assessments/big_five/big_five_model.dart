// ═══════════════════════════════════════════════════════════════════════
// BigFiveModel — 大五人格 Data Model
// OCEAN: Openness, Conscientiousness, Extraversion, Agreeableness, Neuroticism
// All scores normalized to 0–100
// ═══════════════════════════════════════════════════════════════════════

class BigFiveResult {
  final double openness;
  final double conscientiousness;
  final double extraversion;
  final double agreeableness;
  final double neuroticism;

  const BigFiveResult({
    required this.openness,
    required this.conscientiousness,
    required this.extraversion,
    required this.agreeableness,
    required this.neuroticism,
  });

  // ─── Level helpers ───
  String get opennessLevel => _getLevel(openness);
  String get conscientiousnessLevel => _getLevel(conscientiousness);
  String get extraversionLevel => _getLevel(extraversion);
  String get agreeablenessLevel => _getLevel(agreeableness);
  String get neuroticismLevel => _getLevel(neuroticism);

  /// 0–24 low, 25–49 belowAverage, 50 average, 51–74 aboveAverage, 75–100 high
  String _getLevel(double score) {
    if (score < 25) return 'low';
    if (score < 50) return 'belowAverage';
    if (score <= 50) return 'average';
    if (score < 75) return 'aboveAverage';
    return 'high';
  }

  // ─── Dimension labels ───
  String get opennessLabel => _levelLabelChinese(openness, '高開放', '低開放');
  String get conscientiousnessLabel =>
      _levelLabelChinese(conscientiousness, '高盡責', '低盡責');
  String get extraversionLabel =>
      _levelLabelChinese(extraversion, '高外向', '低外向');
  String get agreeablenessLabel =>
      _levelLabelChinese(agreeableness, '高親和', '低親和');
  String get neuroticismLabel =>
      _levelLabelChinese(neuroticism, '高敏感', '低敏感');

  String _levelLabelChinese(double score, String highLabel, String lowLabel) {
    if (score >= 65) return highLabel;
    if (score <= 35) return lowLabel;
    return '中等';
  }

  // ─── Interpretation text per dimension ───
  String get opennessInterpretation {
    if (openness >= 65) return '你鍾意新事物，有創造力，對世界充滿好奇';
    if (openness >= 35) return '你平衡咗開放同務實，唔會太極端';
    return '你偏傳統務實，鍾意熟悉嘅嘢，穩陣派';
  }

  String get conscientiousnessInterpretation {
    if (conscientiousness >= 65) return '你好有條理，可靠，答應嘅事一定做到';
    if (conscientiousness >= 35) return '你識得分輕重，唔會太死板';
    return '你隨性自由，唔鍾意被計劃綁住';
  }

  String get extraversionInterpretation {
    if (extraversion >= 65) return '你係社交蝴蝶，喺人群中充滿能量';
    if (extraversion >= 35) return '你平衡社交同獨處時間';
    return '你係內向型，獨處先係充電';
  }

  String get agreeablenessInterpretation {
    if (agreeableness >= 65) return '你好有同理心，合作性強，令人舒服';
    if (agreeableness >= 35) return '你對人友善但有底線';
    return '你直接唔怕衝突，競爭性強';
  }

  String get neuroticismInterpretation {
    if (neuroticism >= 65) return '你對壓力敏感，需要留意情緒管理';
    if (neuroticism >= 35) return '你一般情緒穩定，但都有脆弱時候';
    return '你情緒好穩定，抗壓能力強，冷靜';
  }

  /// Suggested MBTI correlation based on Big Five profile
  String? get suggestedMbtiCorrelation {
    // Very rough heuristic — for entertainment only
    final ei = extraversion >= 50 ? 'E' : 'I';
    final sn = openness >= 50 ? 'N' : 'S';
    final tf = agreeableness >= 50 ? 'F' : 'T';
    final jp = conscientiousness >= 50 ? 'J' : 'P';
    return '$ei$sn$tf$jp';
  }

  /// A single catchy summary in Cantonese
  String get oneLiner {
    final parts = <String>[];
    if (openness >= 65) parts.add('有創意');
    if (openness <= 35) parts.add('務實派');
    if (conscientiousness >= 65) parts.add('靠得住');
    if (conscientiousness <= 35) parts.add('隨性');
    if (extraversion >= 65) parts.add('社交達人');
    if (extraversion <= 35) parts.add('獨行俠');
    if (agreeableness >= 65) parts.add('好相處');
    if (agreeableness <= 35) parts.add('有主見');
    if (neuroticism >= 65) parts.add('敏感');
    if (neuroticism <= 35) parts.add('冷靜');

    if (parts.isEmpty) return '你係一個平衡嘅人';
    if (parts.length == 1) return '你係一個${parts[0]}嘅人';
    return '你係一個${parts.take(2).join('、')}嘅人';
  }
}

/// A single Big Five question
class BigFiveQuestion {
  final String id; // O1, O2, C1, C2, E1, E2, A1, A2, N1, N2
  final String dimension; // O, C, E, A, N
  final String scenario;
  final List<BigFiveOption> options;

  const BigFiveQuestion({
    required this.id,
    required this.dimension,
    required this.scenario,
    required this.options,
  });
}

/// A single Likert option (1–5)
class BigFiveOption {
  final String text;
  final int score; // 1–5

  const BigFiveOption({required this.text, required this.score});
}
