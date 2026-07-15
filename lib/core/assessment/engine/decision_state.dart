// ═══════════════════════════════════════════════════════════════════════
// DecisionState — v2 Decision Tree Core State Machine
// MBTI × 九型人格 雙重編碼 Decision Tree Engine
// ═══════════════════════════════════════════════════════════════════════

/// Phase of the decision tree assessment flow
enum DecisionPhase {
  /// Phase 1: MBTI routing tree (Q1-Q6, dynamic branch per answer)
  mbtiRouting,

  /// Phase 2: MBTI personality mindset verification
  mbtiVerification,

  /// Phase 2b: MBTI fine-tuning (after verification B response)
  mbtiFineTuning,

  /// Phase 2c: MBTI re-routing (after verification C response)
  mbtiReRouting,

  /// Phase 3a: Enneagram center screening
  enneaCenter,

  /// Phase 3b: Enneagram deep type identification
  enneaDeep,

  /// Phase 3c: Enneagram wing + health level confirmation
  enneaWingHealth,

  /// Phase 4: Enneagram mindset verification
  enneaVerification,

  /// Phase 4b: Enneagram adjustment (after B/C response)
  enneaAdjustment,

  /// Complete — results ready
  complete,
}

/// A single answer option in a decision tree question
class DecisionOption {
  final String text;
  final Map<String, double> scores;

  /// Optional: explicit next question ID (for hard routing like Q1→Q2a/Q2b)
  final String? nextQuestionId;

  const DecisionOption({
    required this.text,
    required this.scores,
    this.nextQuestionId,
  });

  Map<String, dynamic> toJson() => {
        'text': text,
        'scores': scores,
        'nextQuestionId': nextQuestionId,
      };
}

/// A single question node in the decision tree
class DecisionQuestion {
  final String id;
  final DecisionPhase phase;
  final String scenario;
  final List<DecisionOption> options;
  final double discriminationPower; // 0.3–1.0, question's diagnostic weight

  /// Which MBTI dimension(s) this question primarily targets
  final List<String> targetDimensions;

  /// Which enneagram types this question collects clues for
  final List<int> targetEnneagramTypes;

  /// Display context for UI (e.g. 'MBTI判定中', '九型分析中')
  final String phaseLabel;

  const DecisionQuestion({
    required this.id,
    required this.phase,
    required this.scenario,
    required this.options,
    this.discriminationPower = 0.7,
    this.targetDimensions = const [],
    this.targetEnneagramTypes = const [],
    this.phaseLabel = '評估中',
  });
}

/// Record of one answered question
class AnswerRecord {
  final String questionId;
  final Map<String, double> scores;
  final DecisionPhase phase;
  final int optionIndex;

  const AnswerRecord({
    required this.questionId,
    required this.scores,
    required this.phase,
    required this.optionIndex,
  });
}

/// Verification result for a personality type
class VerificationResult {
  final String typeCode; // e.g. "ENFJ", "5"
  final VerificationOutcome outcome;
  final double confidence;

  const VerificationResult({
    required this.typeCode,
    required this.outcome,
    required this.confidence,
  });
}

/// Outcome of a verification step
enum VerificationOutcome {
  confirmed, // A: 確認
  adjusted, // B: 微調
  rerouted, // C: 重新route
}

/// Final computed MBTI result
class MBTIResult {
  final String type; // e.g. "ENFJ"
  final double confidence;
  final Map<String, double> dimensionScores; // {E, I, S, N, T, F, J, P}
  final Map<String, double> dimensionConfidences; // {EI, SN, TF, JP}
  final VerificationResult? verification;

  const MBTIResult({
    required this.type,
    required this.confidence,
    required this.dimensionScores,
    required this.dimensionConfidences,
    this.verification,
  });
}

/// Final computed Enneagram result
class EnneaResult {
  final int primaryType; // 1–9
  final int? wing; // wing type
  final String display; // e.g. "5w4"
  final double confidence;
  final Map<int, double> typeScores;
  final String healthLevel; // "healthy", "average", "unhealthy"
  final double healthScore; // 0.0–1.0
  final VerificationResult? verification;

  const EnneaResult({
    required this.primaryType,
    this.wing,
    required this.display,
    required this.confidence,
    required this.typeScores,
    this.healthLevel = 'average',
    this.healthScore = 0.5,
    this.verification,
  });
}

/// Overall assessment result passed to the naming celebration
class AssessmentResult {
  final MBTIResult mbti;
  final EnneaResult ennea;
  final int totalQuestions;
  final String decisionPath; // e.g. "E→Q2a→J→Q3→S→Q4→F→V_OK→Q7→Heart→Q8a→3→V_OK"
  final List<String> cognitiveBiases;

  const AssessmentResult({
    required this.mbti,
    required this.ennea,
    required this.totalQuestions,
    required this.decisionPath,
    this.cognitiveBiases = const [],
  });
}

/// Diagnostic record for analytics
class DiagnosticRecord {
  final String decisionPath;
  final int totalQuestions;
  final String mbtiResult;
  final String enneaResult;
  final bool verificationPassed;
  final DateTime timestamp;

  const DiagnosticRecord({
    required this.decisionPath,
    required this.totalQuestions,
    required this.mbtiResult,
    required this.enneaResult,
    required this.verificationPassed,
    required this.timestamp,
  });
}

/// ─── MAIN STATE MACHINE ───

class DecisionState {
  /// MBTI cumulative scores {E, I, S, N, T, F, J, P}
  Map<String, double> mbtiScores;

  /// Enneagram cumulative scores {1..9}
  Map<int, double> enneagramScores;

  /// Per-dimension confidence {EI, SN, TF, JP}
  Map<String, double> dimensionConfidence;

  /// Cognitive bias markers
  Map<String, double> cognitiveMarkers;

  /// Current phase
  DecisionPhase phase;

  /// Answered question IDs (prevent repeats)
  List<String> answeredQuestions;

  /// Full answer records
  List<AnswerRecord> answerRecords;

  /// Tentative MBTI (set after Phase 1)
  String? tentativeMBTI;

  /// MBTI verification result
  VerificationResult? mbtiVerification;

  /// Top candidate enneagram types with scores
  Map<int, double> topEnneagramTypes;

  /// Identified enneagram center
  String? enneaCenter; // "heart", "head", "gut"

  /// Primary enneagram type (set after Phase 3)
  int? primaryEnneaType;

  /// Wing type
  int? enneaWing;

  /// Enneagram verification result
  VerificationResult? enneaVerification;

  /// Health score (0.0–1.0)
  double healthScore;

  /// Decision path string for analytics
  String decisionPath;

  /// Estimated total questions (for UI progress bar)
  int estimatedTotal;

  /// Whether current MBTI verification is in progress
  bool isMbtiVerificationActive;

  /// Whether current ennea verification is in progress
  bool isEnneaVerificationActive;

  /// Re-routing depth counter (prevents infinite loops)
  int rerouteDepth;

  DecisionState({
    Map<String, double>? mbtiScores,
    Map<int, double>? enneagramScores,
    Map<String, double>? dimensionConfidence,
    Map<String, double>? cognitiveMarkers,
    this.phase = DecisionPhase.mbtiRouting,
    List<String>? answeredQuestions,
    List<AnswerRecord>? answerRecords,
    this.tentativeMBTI,
    this.mbtiVerification,
    Map<int, double>? topEnneagramTypes,
    this.enneaCenter,
    this.primaryEnneaType,
    this.enneaWing,
    this.enneaVerification,
    this.healthScore = 0.5,
    this.decisionPath = '',
    this.estimatedTotal = 14,
    this.isMbtiVerificationActive = false,
    this.isEnneaVerificationActive = false,
    this.rerouteDepth = 0,
  })  : mbtiScores = mbtiScores ??
            {'E': 0.0, 'I': 0.0, 'S': 0.0, 'N': 0.0, 'T': 0.0, 'F': 0.0, 'J': 0.0, 'P': 0.0},
        enneagramScores = enneagramScores ?? {1: 0.0, 2: 0.0, 3: 0.0, 4: 0.0, 5: 0.0, 6: 0.0, 7: 0.0, 8: 0.0, 9: 0.0},
        dimensionConfidence = dimensionConfidence ?? {'EI': 0.0, 'SN': 0.0, 'TF': 0.0, 'JP': 0.0},
        cognitiveMarkers = cognitiveMarkers ?? {},
        answeredQuestions = answeredQuestions ?? [],
        answerRecords = answerRecords ?? [],
        topEnneagramTypes = topEnneagramTypes ?? {};

  /// Record an answer and update state
  void recordAnswer(String questionId, Map<String, double> scores, int optionIndex) {
    if (answeredQuestions.contains(questionId)) return;
    answeredQuestions.add(questionId);

    final record = AnswerRecord(
      questionId: questionId,
      scores: Map.from(scores),
      phase: phase,
      optionIndex: optionIndex,
    );
    answerRecords.add(record);

    // Apply MBTI scores
    for (final entry in scores.entries) {
      if (['E', 'I', 'S', 'N', 'T', 'F', 'J', 'P'].contains(entry.key)) {
        mbtiScores[entry.key] = (mbtiScores[entry.key] ?? 0) + entry.value;
      }
      // Apply enneagram scores
      if (entry.key.startsWith('enneagram_')) {
        final typeNum = int.tryParse(entry.key.split('_').last);
        if (typeNum != null && typeNum >= 1 && typeNum <= 9) {
          enneagramScores[typeNum] = (enneagramScores[typeNum] ?? 0) + entry.value;
        }
      }
      // Apply cognitive bias markers
      if (entry.key.startsWith('bias_')) {
        cognitiveMarkers[entry.key] = (cognitiveMarkers[entry.key] ?? 0) + entry.value;
      }
      // Apply health markers
      if (entry.key == 'health_positive') {
        healthScore = (healthScore + entry.value).clamp(0.0, 1.0);
      }
      if (entry.key == 'health_negative') {
        healthScore = (healthScore - entry.value).clamp(0.0, 1.0);
      }
    }

    // Recalculate dimension confidences after each answer
    _recalculateConfidence();
  }

  /// Recalculate per-dimension confidence based on score gaps
  void _recalculateConfidence() {
    dimensionConfidence['EI'] = _dimConfidence(mbtiScores['E'] ?? 0, mbtiScores['I'] ?? 0);
    dimensionConfidence['SN'] = _dimConfidence(mbtiScores['S'] ?? 0, mbtiScores['N'] ?? 0);
    dimensionConfidence['TF'] = _dimConfidence(mbtiScores['T'] ?? 0, mbtiScores['F'] ?? 0);
    dimensionConfidence['JP'] = _dimConfidence(mbtiScores['J'] ?? 0, mbtiScores['P'] ?? 0);
  }

  /// Calculate confidence for a bipolar dimension
  double _dimConfidence(double a, double b) {
    final diff = (a - b).abs();
    final total = a.abs() + b.abs();
    if (total < 0.001) return 0.0;
    return (diff / total).clamp(0.0, 1.0);
  }

  /// Get dimensions with confidence below threshold
  List<String> getUncertainDimensions({double threshold = 0.35}) {
    final uncertain = <String>[];
    for (final entry in dimensionConfidence.entries) {
      if (entry.value < threshold) {
        uncertain.add(entry.key);
      }
    }
    return uncertain;
  }

  /// Get the single most uncertain dimension
  String? getMostUncertainDimension() {
    String? minKey;
    double minVal = 1.0;
    for (final entry in dimensionConfidence.entries) {
      if (entry.value < minVal) {
        minVal = entry.value;
        minKey = entry.key;
      }
    }
    return (minVal < 0.5) ? minKey : null;
  }

  /// Get the top N uncertain dimensions
  List<String> getTopUncertainDimensions(int n) {
    final sorted = dimensionConfidence.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sorted.take(n).where((e) => e.value < 0.5).map((e) => e.key).toList();
  }

  /// Get current tentative MBTI type string
  String computeTentativeMBTI() {
    return '${mbtiScores['E']! >= mbtiScores['I']! ? 'E' : 'I'}'
        '${mbtiScores['S']! >= mbtiScores['N']! ? 'S' : 'N'}'
        '${mbtiScores['T']! >= mbtiScores['F']! ? 'T' : 'F'}'
        '${mbtiScores['J']! >= mbtiScores['P']! ? 'J' : 'P'}';
  }

  /// Compute dimension-by-dimension MBTI (for fine-tuning after verification)
  Map<String, String> computeDimensionResults() {
    return {
      'EI': mbtiScores['E']! >= mbtiScores['I']! ? 'E' : 'I',
      'SN': mbtiScores['S']! >= mbtiScores['N']! ? 'S' : 'N',
      'TF': mbtiScores['T']! >= mbtiScores['F']! ? 'T' : 'F',
      'JP': mbtiScores['J']! >= mbtiScores['P']! ? 'J' : 'P',
    };
  }

  /// Get the dimension letter from a dimension key
  String getDimensionLetter(String dim) {
    switch (dim) {
      case 'EI':
        return mbtiScores['E']! >= mbtiScores['I']! ? 'E' : 'I';
      case 'SN':
        return mbtiScores['S']! >= mbtiScores['N']! ? 'S' : 'N';
      case 'TF':
        return mbtiScores['T']! >= mbtiScores['F']! ? 'T' : 'F';
      case 'JP':
        return mbtiScores['J']! >= mbtiScores['P']! ? 'J' : 'P';
      default:
        return '?';
    }
  }

  /// Get top N enneagram types sorted by score
  List<int> getTopEnneaTypes(int n) {
    final sorted = enneagramScores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(n).map((e) => e.key).toList();
  }

  /// Get top 2 enneagram types within a specific center
  List<int> getTopEnneaInCenter(String center) {
    final centerTypes = DecisionState.centerTypes(center);
    final filtered = enneagramScores.entries
        .where((e) => centerTypes.contains(e.key))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return filtered.take(2).map((e) => e.key).toList();
  }

  /// Map center name to type list
  static List<int> centerTypes(String center) {
    switch (center) {
      case 'heart':
        return [2, 3, 4];
      case 'head':
        return [5, 6, 7];
      case 'gut':
        return [8, 9, 1];
      default:
        return [];
    }
  }

  /// Get enneagram display string
  String getEnneaDisplay() {
    if (primaryEnneaType == null) return '?';
    return '$primaryEnneaType${enneaWing != null ? 'w$enneaWing' : ''}';
  }

  /// Get phase label for UI display
  String getPhaseLabel() {
    switch (phase) {
      case DecisionPhase.mbtiRouting:
        return 'MBTI 判定中…';
      case DecisionPhase.mbtiVerification:
      case DecisionPhase.mbtiFineTuning:
      case DecisionPhase.mbtiReRouting:
        return '結果驗證中…';
      case DecisionPhase.enneaCenter:
        return '九型分析中…';
      case DecisionPhase.enneaDeep:
        return '九型深入分析…';
      case DecisionPhase.enneaWingHealth:
        return '翼型確認中…';
      case DecisionPhase.enneaVerification:
      case DecisionPhase.enneaAdjustment:
        return '最終驗證…';
      case DecisionPhase.complete:
        return '完成！🎉';
    }
  }

  /// Estimated progress 0.0–1.0
  double getProgress() {
    final answered = answeredQuestions.length;
    final total = estimatedTotal;
    if (total <= 0) return 0.0;
    return (answered / total).clamp(0.0, 1.0);
  }

  /// How many questions answered so far
  int get answeredCount => answeredQuestions.length;
}
